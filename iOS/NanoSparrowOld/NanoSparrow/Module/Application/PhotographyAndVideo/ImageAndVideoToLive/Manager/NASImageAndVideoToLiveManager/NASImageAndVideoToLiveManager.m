//
//  NASImageAndVideoToLiveManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/10/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASImageAndVideoToLiveManager.h"
#import <Photos/Photos.h>
#import <ImageIO/ImageIO.h>
#import "NASHeader.h"

static const NSString *kFigAppleMakerNote_AssetIdentifier = @"17";
//static const NSString *kKeyContentIdentifier =  @"com.apple.quicktime.content.identifier";
static const NSString *kKeyStillImageTime = @"com.apple.quicktime.still-image-time";
//static const NSString *kKeySpaceQuickTimeMetadata = @"mdta";

@interface NASImageAndVideoToLiveManager()

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) AVAsset *videoAsset;
@property (assign, nonatomic) CMTimeRange dummyTimeRange;
@property (strong, nonatomic) AVAssetWriterInput *audioWriterInput;
@property (strong, nonatomic) AVAssetWriterInput *videoWriterInput;
@property (strong, nonatomic) AVAssetReaderTrackOutput *audioReaderOutput;
@property (strong, nonatomic) AVAssetReaderTrackOutput *videoReaderOutput;
@property (strong, nonatomic) AVAssetReader *assetReader;
@property (strong, nonatomic) AVAssetWriter *assetWriter;
@property (strong, nonatomic) dispatch_group_t videoGroup;
@property (strong, nonatomic) dispatch_group_t transGroup;
@property (strong, nonatomic) dispatch_queue_t videoQueue;
@property (strong, nonatomic) dispatch_queue_t audioQueue;
@property (strong, nonatomic) dispatch_queue_t saveQueue;
@property (strong, nonatomic) dispatch_queue_t mainQueue;
@property (assign, nonatomic) BOOL imageWriteResult;
@property (assign, nonatomic) BOOL videoWriteResult;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSString *videoPath;

@end

@implementation NASImageAndVideoToLiveManager

- (void)dealloc {
    
}

- (instancetype)initWithImage:(UIImage *)image videoAsset:(AVAsset *)videoAsset {
    self = [super init];
    if (self) {
        _image = image;
        _videoAsset = videoAsset;
        _dummyTimeRange = CMTimeRangeMake(CMTimeMake(0, 1000), CMTimeMake(200, 3000));
    }
    return self;
}


- (void)transferWithCompletionBlock:(CompletionBlock)completionBlock {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if (paths.count == 0) {
        if (completionBlock) {
            completionBlock(NO, nil);
        }
    }
    NSString *tempCategory = [[paths objectAtIndex:0] stringByAppendingString:@"/LivePhoto/"];
    NSString *imagePath = [[tempCategory stringByAppendingString:[NASFileSystemManager generateDateTimeString]] stringByAppendingString:@"_liveImage.jpeg"];
    NSString *videoPath = [[tempCategory stringByAppendingString:[NASFileSystemManager generateDateTimeString]] stringByAppendingString:@"_liveMovie.mov"];
    if (![NASFileSystemManager createPath:imagePath]) {
        if (completionBlock) {
            completionBlock(NO, nil);
        }
        return;
    }
    if (![NASFileSystemManager createPath:videoPath]) {
        if (completionBlock) {
            completionBlock(NO, nil);
        }
        return;
    }
    self.imagePath = imagePath;
    self.videoPath = videoPath;
    self.transGroup = dispatch_group_create();
    NSString *assetIdentifier = [NSUUID UUID].UUIDString;
    @weakify(self)
    dispatch_group_enter(self.transGroup);
    [self writeImageToPath:imagePath assetIdentifier:assetIdentifier completionBlock:^(BOOL success, NSError *error) {
        @strongify(self)
        if (self) {
            if (success && !error) {
                self.imageWriteResult = YES;
            }
            else {
                self.imageWriteResult = NO;
            }
            
        }
        dispatch_group_leave(self.transGroup);
    }];
    dispatch_group_enter(self.transGroup);
    [self writeVideoToPath:videoPath assetIdentifier:assetIdentifier completionBlock:^(BOOL success, NSError *error) {
        @strongify(self)
        if (self) {
            if (success && !error) {
                self.videoWriteResult = YES;
            }
            else {
                self.videoWriteResult = NO;
            }
        }
        dispatch_group_leave(self.transGroup);
    }];
    self.saveQueue = dispatch_queue_create("saveQueue", NULL);
    dispatch_group_notify(self.transGroup, self.saveQueue, ^{
        @strongify(self)
        if (self) {
            if (self.videoWriteResult && self.imageWriteResult) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAsset];
                    PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                    [creationRequest addResourceWithType:PHAssetResourceTypePairedVideo fileURL:[NSURL fileURLWithPath:self.videoPath] options:options];
                    [creationRequest addResourceWithType:PHAssetResourceTypePhoto fileURL:[NSURL fileURLWithPath:self.imagePath] options:options];
                }
                                                  completionHandler:^(BOOL success, NSError * _Nullable error) {
                                                      if (success) {
                                                          if (completionBlock) {
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  completionBlock(YES, nil);
                                                              });
                                                          }
                                                      }
                                                      else {
                                                          if (completionBlock) {
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  completionBlock(NO, error);
                                                              });
                                                          }
                                                          NSLog(@"%@", error);
                                                      }
                                                  }];
            }
            else {
                if (completionBlock) {
                    completionBlock(NO, nil);
                }
            }
        }
       
    });
}


- (void)writeImageToPath:(NSString *)imagePath
         assetIdentifier:(NSString *)assetIdentifier
         completionBlock:(void (^)(BOOL success, NSError *error))completionBlock {
    
    CGImageDestinationRef destinationRef = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:imagePath], kUTTypeJPEG, 1, nil);
    if (!destinationRef) {
        if (completionBlock) {
            completionBlock(NO, nil);
        }
        return;
    }
    NSData *data = [self imageDataWithImage:self.image];
    CGImageSourceRef imageSource = [self imageSourceWithData:data];
    NSMutableDictionary *metadata = [[self metadataFromImageSource:imageSource] mutableCopy];
    if (!metadata) {
        if (completionBlock) {
            completionBlock(NO, nil);
        }
        return;
    }
    NSMutableDictionary *makerNote = [NSMutableDictionary dictionary];
    [makerNote setObject:assetIdentifier forKey:kFigAppleMakerNote_AssetIdentifier];
    [metadata setObject:makerNote forKey:(__bridge_transfer  NSString *)kCGImagePropertyMakerAppleDictionary];
    CGImageDestinationAddImageFromSource(destinationRef, imageSource, 0, (__bridge CFDictionaryRef)metadata);
    
    if (CGImageDestinationFinalize(destinationRef)) {
        if (completionBlock) {
            completionBlock(YES, nil);
        }
    }
    else {
        if (completionBlock) {
            completionBlock(NO, nil);
        }
    }
    
}

- (void)writeVideoToPath:(NSString *)videoPath
         assetIdentifier:(NSString *)assetIdentifier
         completionBlock:(void (^)(BOOL success, NSError *error))completionBlock {

    
    AVAssetTrack *track = [self trackWithMediaType:AVMediaTypeVideo];
    if (!track) {
        if (completionBlock) {
            completionBlock(NO, nil);
        }
        return;
    }
    NSArray *readerAndOutput = [self readerWithTrack:track settings:@{(__bridge_transfer  NSString *)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]}];
    if (readerAndOutput.count < 2) {
        if (completionBlock) {
            completionBlock(NO, nil);
        }
        return;
    }
    self.assetReader = [readerAndOutput safe_objectAtIndex:0];
    self.videoReaderOutput = [readerAndOutput safe_objectAtIndex:1];
    NSError *localError = nil;
    self.assetWriter = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:videoPath] fileType:AVFileTypeQuickTimeMovie error:&localError];
    if (localError || !self.assetWriter) {
        if (completionBlock) {
            completionBlock(NO, localError);
        }
        return;
    }
    
    self.assetWriter.metadata = @[[self metadataForAssetIdentifier:assetIdentifier],];
    
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                   outputSettings:[self videoSettingsWithSize:track.naturalSize]];
    
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    self.videoWriterInput.transform = track.preferredTransform;
    if ([self.assetWriter canAddInput:self.videoWriterInput]) {
        [self.assetWriter addInput:self.videoWriterInput];
    }
    else {
        if (completionBlock) {
            completionBlock(NO, nil);
        }
        return;
    }
    
    if ([self trackWithMediaType:AVMediaTypeAudio]) {
        self.audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:nil];
        self.audioWriterInput.expectsMediaDataInRealTime = NO;
        if ([self.assetWriter canAddInput:self.audioWriterInput]) {
            [self.assetWriter addInput:self.audioWriterInput];
        }
        AVAssetTrack *audioTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeAudio] safe_objectAtIndex:0];
        if (audioTrack) {
            self.audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
            if ([self.assetReader canAddOutput:self.audioReaderOutput]) {
                [self.assetReader addOutput:self.audioReaderOutput];
            }
        }
    }
    
    AVAssetWriterInputMetadataAdaptor *adapter = [self metadataAdapter];
    if ([self.assetWriter canAddInput:adapter.assetWriterInput]) {
        [self.assetWriter addInput:adapter.assetWriterInput];
        
    }
    else {
        if (completionBlock) {
            completionBlock(NO, nil);
        }
        return;
    }
    BOOL success = [self.assetWriter startWriting];
    if (!success) {
        if (completionBlock) {
            completionBlock(success, [self.assetWriter error]);
        }
        return;
    }
    success =  [self.assetReader startReading];
    if (!success) {
        if (completionBlock) {
            completionBlock(success, [self.assetReader error]);
        }
        return;
    }
    [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
    [adapter appendTimedMetadataGroup:[[AVTimedMetadataGroup alloc] initWithItems:@[[self metadataForStillImageTime]] timeRange:self.dummyTimeRange]];
    self.videoGroup = dispatch_group_create();
    if (self.videoWriterInput) {
        
        dispatch_group_enter(self.videoGroup);
        self.videoQueue = dispatch_queue_create("assetVideoWriterQueue", NULL);
        @weakify(self)
        [self.videoWriterInput requestMediaDataWhenReadyOnQueue:self.videoQueue usingBlock:^{
            @strongify(self)
            if (self) {
                BOOL completedOrFailed = NO;
                while(self.videoWriterInput.isReadyForMoreMediaData && !completedOrFailed) {
                    @autoreleasepool {
                        CMSampleBufferRef buffer = [self.videoReaderOutput copyNextSampleBuffer];
                        if (buffer != NULL) {
                            if (![self.videoWriterInput appendSampleBuffer:buffer]) {
                                completedOrFailed = YES;
                            }
                            CFRelease(buffer);
                            buffer = NULL;
                        }
                        else {
                            completedOrFailed = YES;
                        }
                        
                    }
                }
                if (completedOrFailed) {
                    [self.videoWriterInput markAsFinished];
                    dispatch_group_leave(self.videoGroup);
                }
            }
        }];
    }
    if (self.audioWriterInput) {
        dispatch_group_enter(self.videoGroup);
        self.audioQueue = dispatch_queue_create("assetAudioWriterQueue", NULL);
        @weakify(self)
        [self.audioWriterInput requestMediaDataWhenReadyOnQueue:self.audioQueue usingBlock:^{
            @strongify(self)
            if (self) {
                BOOL completedOrFailed = NO;
                
                while ([self.audioWriterInput isReadyForMoreMediaData] && !completedOrFailed) {
                    @autoreleasepool {
                        CMSampleBufferRef sampleBuffer = [self.audioReaderOutput copyNextSampleBuffer];
                        if (sampleBuffer != NULL) {
                            if (![self.audioWriterInput appendSampleBuffer:sampleBuffer]) {
                                completedOrFailed = YES;
                            }
                            CFRelease(sampleBuffer);
                            sampleBuffer = NULL;
                        }
                        else {
                            completedOrFailed = YES;
                        }
                    }
                    
                }
                if (completedOrFailed) {
                    [self.audioWriterInput markAsFinished];
                    dispatch_group_leave(self.videoGroup);
                }
            }
            
        }];
    }
    self.mainQueue = dispatch_queue_create("mainCropQueue", NULL);
    dispatch_group_notify(self.videoGroup, self.mainQueue, ^{
        BOOL finalSuccess = YES;
        NSError *finalReaderError = nil;
        
        if ([self.assetReader status] == AVAssetReaderStatusFailed) {
            finalSuccess = NO;
            finalReaderError = [self.assetReader error];
            if (completionBlock) {
                completionBlock(finalSuccess, finalReaderError);
            }
        }
        else {
            @weakify(self)
            [self.assetWriter finishWritingWithCompletionHandler:^{
                @strongify(self)
                if (self) {
                    NSError *finalWriterError = [self.assetWriter error];
                    if (finalWriterError) {
                        [self.assetReader cancelReading];
                        [self.assetWriter cancelWriting];
                        if (completionBlock) {
                            completionBlock(NO, finalWriterError);
                        }
                    }
                    else {
                        if (completionBlock) {
                            completionBlock(YES, finalWriterError);
                        }
                    }
                    
                }
            }];
        }
    });
    
    
}
     

- (NSDictionary *)videoSettingsWithSize:(CGSize)size {
    
    return @{AVVideoCodecKey: AVVideoCodecH264 ,
             AVVideoWidthKey: [NSNumber numberWithInt:size.width],
             AVVideoHeightKey: [NSNumber numberWithInt:size.height]};
    
}

- (AVMetadataItem *)metadataForAssetIdentifier:(NSString *)assetIdentifier {
    
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.key = AVMetadataQuickTimeMetadataKeyContentIdentifier;
    item.keySpace = AVMetadataKeySpaceQuickTimeMetadata;
    item.value = assetIdentifier;
    item.dataType = (__bridge_transfer NSString *)kCMMetadataBaseDataType_UTF8;
    return item;
    
}

- (AVMetadataItem *)metadataForStillImageTime {
    
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.key = kKeyStillImageTime;
    item.keySpace = AVMetadataKeySpaceQuickTimeMetadata;
    item.value = @0;
    item.dataType = (__bridge_transfer NSString *)kCMMetadataBaseDataType_SInt8;
    return item;
    
}

- (AVAssetWriterInputMetadataAdaptor *)metadataAdapter {
    NSString *identifier = [NSString stringWithFormat:@"%@/%@", AVMetadataKeySpaceQuickTimeMetadata, kKeyStillImageTime];
    NSDictionary *spec = @{(__bridge_transfer NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier : identifier,
                           (__bridge_transfer NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType : (__bridge_transfer NSString *)kCMMetadataBaseDataType_SInt8,};
    CMFormatDescriptionRef desc = nil;
    CMMetadataFormatDescriptionCreateWithMetadataSpecifications(kCFAllocatorDefault, kCMMetadataFormatType_Boxed, (__bridge CFArrayRef)[NSArray arrayWithObject:spec], &desc);
    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeMetadata outputSettings:nil sourceFormatHint:desc];
    AVAssetWriterInputMetadataAdaptor *inputAdaptor = [AVAssetWriterInputMetadataAdaptor assetWriterInputMetadataAdaptorWithAssetWriterInput:input];
    return inputAdaptor;
}

- (AVAssetTrack *)trackWithMediaType:(NSString *)mediaType {
    return [[self.videoAsset tracksWithMediaType:mediaType] safe_objectAtIndex:0];
}

- (NSArray *)readerWithTrack:(AVAssetTrack *)track settings:(NSDictionary *)settings {
    AVAssetReaderTrackOutput *output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:settings];
    NSError *error = nil;
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:self.videoAsset error:&error];
    if(error) {
        return @[];
    }
    if ([reader canAddOutput:output]) {
        [reader addOutput:output];
        return @[reader, output];
    }
    else {
        return @[reader];
    }
}


- (NSDictionary *)metadataFromImageSource:(CGImageSourceRef)imageSource {
    
    NSDictionary *metadata = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil);
    return metadata;
    
}

- (NSData *)imageDataWithImage:(UIImage *)image {
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    return data;
}

- (CGImageSourceRef)imageSourceWithData:(NSData *)data {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
    return imageSource;
}


@end
