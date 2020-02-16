//
//  NASCropVideoFrameManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/11/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASCropVideoFrameManager.h"
#import "NASFileSystemManager.h"

static NSString *loadKeyTracks = @"tracks";

@interface NASCropVideoFrameManager()

@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) NASCropVideoFrameModel *videoFrameModel;
@property (strong, nonatomic) NSProgress *videoProgress;
@property (strong, nonatomic) NSProgress *audioProgress;
@property (strong, nonatomic) NSProgress *totalProgress;

@property (strong, nonatomic) dispatch_queue_t mainCropQueue;
@property (strong, nonatomic) dispatch_queue_t audioCropQueue;
@property (strong, nonatomic) dispatch_queue_t videoCropQueue;
@property (strong, nonatomic) dispatch_group_t cropQueueGroup;
@property (strong, nonatomic) AVAssetReader *assetReader;
@property (strong, nonatomic) AVAssetWriter *assetWriter;
@property (strong, nonatomic) AVAssetReaderTrackOutput *assetReaderAudioOutput;
@property (strong, nonatomic) AVAssetReaderTrackOutput *assetReaderVideoOutput;
@property (strong, nonatomic) AVAssetWriterInputPixelBufferAdaptor *assetWriterVideoInputAdaptor;
@property (strong, nonatomic) AVAssetWriterInput *assetWriterAudioInput;
@property (strong, nonatomic) AVAssetWriterInput *assetWriterVideoInput;
@property (assign, nonatomic) BOOL audioFinished;
@property (assign, nonatomic) BOOL videoFinished;
@property (copy,   nonatomic) UpdateProgressBlock progressBlock;
@property (copy,   nonatomic) FinishBlock finishBlock;

@end

@implementation NASCropVideoFrameManager

- (instancetype)initWithAsset:(AVAsset *)asset
                        model:(NASCropVideoFrameModel *)model {
    self = [super init];
    if (self) {
        _asset           = asset;
        _videoFrameModel = model;
        _fps             = 0;
    }
    return self;
}

- (void)cropWithProgressBlock:(UpdateProgressBlock)progressBlock
                  finishBlock:(FinishBlock)finishBlock {
    self.videoProgress.completedUnitCount = 0;
    self.audioProgress.completedUnitCount = 0;
    self.progressBlock = progressBlock;
    self.finishBlock   = finishBlock;
    RACSignal *progressSignal = RACObserve(self, totalProgress.fractionCompleted);
    @weakify(self)
    [progressSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self && self.progressBlock) {
            self.progressBlock(self.totalProgress);
        }
    }];
    if (![NASFileSystemManager createPath:self.exportFileURL.path]) {
        if (finishBlock) {
            self.finishBlock(NO, nil);
        }
        return;
    }
    [self.asset loadValuesAsynchronouslyForKeys:@[loadKeyTracks] completionHandler:^{
        @strongify(self)
        if (self) {
            BOOL success = YES;
            NSError *localError = nil;
            success = ([self.asset statusOfValueForKey:loadKeyTracks error:&localError] == AVKeyValueStatusLoaded);
            if (success && localError == nil) {
                success = [self setupAssetReaderAndAssetWriter:&localError];
                if (success && localError == nil) {
                    success = [self startAssetReaderAndWriter:&localError];
                }
                else {
                    if (self.finishBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.finishBlock(NO, localError);
                        });
                    }
                }
            }
            else {
                if (self.finishBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.finishBlock(NO, localError);
                    });
                }
            }
        }
    }];
}

- (BOOL)setupAssetReaderAndAssetWriter:(NSError **)outError {
    self.assetReader = [[AVAssetReader alloc] initWithAsset:self.asset error:outError];
    if (*outError || !self.assetReader || self.assetReader.error) {
        *outError = self.assetReader.error ? self.assetReader.error : *outError;
        return NO;
    }
    self.assetWriter = [[AVAssetWriter alloc] initWithURL:self.exportFileURL fileType:self.exportFileType error:outError];
    if (*outError || !self.assetWriter || self.assetWriter.error) {
        *outError = self.assetWriter.error ? self.assetWriter.error : *outError;
        return NO;
    }
    AVAssetTrack *assetAudioTrack = nil, *assetVideoTrack = nil;
    NSArray *audioTracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
    if ([audioTracks count] > 0) {
        assetAudioTrack = [audioTracks objectAtIndex:0];
    }
    NSArray *videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
    if ([videoTracks count] > 0) {
        assetVideoTrack = [videoTracks objectAtIndex:0];
    }
    
    if (assetAudioTrack) {
        // If there is an audio track to read, set the decompression settings to Linear PCM and create the asset reader output.
        NSDictionary *decompressionAudioSettings = @{ AVFormatIDKey : [NSNumber numberWithUnsignedInt:kAudioFormatLinearPCM] };
        self.assetReaderAudioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:assetAudioTrack outputSettings:decompressionAudioSettings];
        [self.assetReader addOutput:self.assetReaderAudioOutput];
        // Then, set the compression settings to 128kbps AAC and create the asset writer input.
        AudioChannelLayout stereoChannelLayout = {
            .mChannelLayoutTag = kAudioChannelLayoutTag_Stereo,
            .mChannelBitmap = 0,
            .mNumberChannelDescriptions = 0
        };
        NSData *channelLayoutAsData = [NSData dataWithBytes:&stereoChannelLayout length:offsetof(AudioChannelLayout, mChannelDescriptions)];
        NSDictionary *compressionAudioSettings = @{
                                                   AVFormatIDKey         : [NSNumber numberWithUnsignedInt:kAudioFormatMPEG4AAC],
                                                   AVEncoderBitRateKey   : [NSNumber numberWithInteger:128000],
                                                   AVSampleRateKey       : [NSNumber numberWithInteger:44100],
                                                   AVChannelLayoutKey    : channelLayoutAsData,
                                                   AVNumberOfChannelsKey : [NSNumber numberWithUnsignedInteger:2]
                                                   };
        self.assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:[assetAudioTrack mediaType] outputSettings:compressionAudioSettings];
        [self.assetWriter addInput:self.assetWriterAudioInput];
    }
    
    if (assetVideoTrack) {
        // If there is a video track to read, set the decompression settings for YUV and create the asset reader output.
  

        NSDictionary *decompressionVideoSettings = @{
                                                     (id)kCVPixelBufferPixelFormatTypeKey      : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_422YpCbCr8],
                                                     (id)kCVPixelBufferIOSurfacePropertiesKey  : [NSDictionary dictionary]
                                                     };
        
        self.assetReaderVideoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:assetVideoTrack outputSettings:decompressionVideoSettings];
        self.assetReaderVideoOutput.alwaysCopiesSampleData = NO;
        [self.assetReader addOutput:self.assetReaderVideoOutput];
//        CMFormatDescriptionRef formatDescription = NULL;
//        // Grab the video format descriptions from the video track and grab the first one if it exists.
//        NSArray *videoFormatDescriptions = [assetVideoTrack formatDescriptions];
//        if ([videoFormatDescriptions count] > 0)
//            formatDescription = (__bridge CMFormatDescriptionRef)[videoFormatDescriptions objectAtIndex:0];
//        CGSize trackDimensions = {
//            .width = 0.0,
//            .height = 0.0,
//        };
//        // If the video track had a format description, grab the track dimensions from there. Otherwise, grab them direcly from the track itself.
//        if (formatDescription)
//            trackDimensions = CMVideoFormatDescriptionGetPresentationDimensions(formatDescription, false, false);
//        else
//            trackDimensions = [assetVideoTrack naturalSize];
//        NSDictionary *compressionSettings = nil;
        // If the video track had a format description, attempt to grab the clean aperture settings and pixel aspect ratio used by the video.
//        if (cleanAperture)
//        {
//            NSMutableDictionary *mutableCompressionSettings = [NSMutableDictionary dictionary];
//            [mutableCompressionSettings setObject:cleanAperture forKey:AVVideoCleanApertureKey];
//            compressionSettings = [NSDictionary dictionaryWithDictionary:mutableCompressionSettings];
//        }
     
        // Create the video settings dictionary for H.264.
        NSMutableDictionary *videoSettings = [NSMutableDictionary dictionary];
        [videoSettings safe_setObject:AVVideoCodecH264                   forKey:AVVideoCodecKey];
        [videoSettings safe_setObject:AVVideoScalingModeResizeAspectFill forKey:AVVideoScalingModeKey];
        [videoSettings safe_setObject:[NSNumber numberWithFloat:self.videoFrameModel.videoSettingModel.videoContentSize.width]  forKey:AVVideoWidthKey];
        [videoSettings safe_setObject:[NSNumber numberWithFloat:self.videoFrameModel.videoSettingModel.videoContentSize.height] forKey:AVVideoHeightKey];
        [videoSettings safe_setObject:@{AVVideoMaxKeyFrameIntervalKey : [NSNumber numberWithInteger:self.fps]} forKey:AVVideoCompressionPropertiesKey];
        // Put the compression settings into the video settings dictionary if we were able to grab them.
//        if (compressionSettings)
//            [videoSettings setObject:compressionSettings forKey:AVVideoCompressionPropertiesKey];
        // Create the asset writer input and add it to the asset writer.
        self.assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:[assetVideoTrack mediaType] outputSettings:videoSettings];
        NSDictionary *pixelBufferSettings = @{
                                              (id)kCVPixelBufferCGImageCompatibilityKey : @YES,
                                              (id)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                                              (id)kCVPixelBufferWidthKey  : [NSNumber numberWithInt:self.videoFrameModel.videoSettingModel.videoContentSize.width],
                                              (id)kCVPixelBufferHeightKey : [NSNumber numberWithInt:self.videoFrameModel.videoSettingModel.videoContentSize.height]
                                              };
        
        self.assetWriterVideoInputAdaptor = [AVAssetWriterInputPixelBufferAdaptor
                                             assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.assetWriterVideoInput
                                             sourcePixelBufferAttributes:pixelBufferSettings];
        [self.assetWriter addInput:self.assetWriterVideoInput];
    }
    
    return YES;
}

- (BOOL)startAssetReaderAndWriter:(NSError **)outError {
    
    BOOL success = YES;
    // Attempt to start the asset reader.
    success = [self.assetReader startReading];
    if (!success) {
        *outError = [self.assetReader error];
    }
    if (success) {
        // If the reader started successfully, attempt to start the asset writer.
        success = [self.assetWriter startWriting];
        if (!success)
            *outError = [self.assetWriter error];
    }
    
    if (success) {
        // If the asset reader and writer both started successfully, create the dispatch group where the reencoding will take place and start a sample-writing session.
        [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
        self.audioFinished = NO;
        self.videoFinished = NO;
        
        if (self.assetWriterAudioInput) {
            // If there is audio to reencode, enter the dispatch group before beginning the work.
            dispatch_group_enter(self.cropQueueGroup);
            // Specify the block to execute when the asset writer is ready for audio media data, and specify the queue to call it on.
            [self.assetWriterAudioInput requestMediaDataWhenReadyOnQueue:self.audioCropQueue usingBlock:^{
                // Because the block is called asynchronously, check to see whether its task is complete.
                if (self.audioFinished)
                    return;
                BOOL completedOrFailed = NO;
                // If the task isn't complete yet, make sure that the input is actually ready for more media data.
                while ([self.assetWriterAudioInput isReadyForMoreMediaData] && !completedOrFailed) {
                    @autoreleasepool {
                        // Get the next audio sample buffer, and append it to the output file.
                        CMSampleBufferRef sampleBuffer = [self.assetReaderAudioOutput copyNextSampleBuffer];
                        if (sampleBuffer != NULL) {
                            CMTime presentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                            BOOL success = [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
                            CFRelease(sampleBuffer);
                            sampleBuffer = NULL;
                            completedOrFailed = !success;
                            self.audioProgress.completedUnitCount = (int64_t)(CMTimeGetSeconds(presentTime) * 100 / CMTimeGetSeconds(self.asset.duration));
                        }
                        else {
                            completedOrFailed = YES;
                        }
                        
                    }
                }
                if (completedOrFailed) {
                    // Mark the input as finished, but only if we haven't already done so, and then leave the dispatch group (since the audio work has finished).
                    BOOL oldFinished = self.audioFinished;
                    self.audioFinished = YES;
                    if (oldFinished == NO)  {
                        [self.assetWriterAudioInput markAsFinished];
                    }
                    dispatch_group_leave(self.cropQueueGroup);
                }
            }];
        }
        
        if (self.assetWriterVideoInput)
        {
            // If we had video to reencode, enter the dispatch group before beginning the work.
            dispatch_group_enter(self.cropQueueGroup);
            // Specify the block to execute when the asset writer is ready for video media data, and specify the queue to call it on.
            [self.assetWriterVideoInput requestMediaDataWhenReadyOnQueue:self.videoCropQueue usingBlock:^{
                // Because the block is called asynchronously, check to see whether its task is complete.
                if (self.videoFinished)
                    return;
                BOOL completedOrFailed = NO;
                // If the task isn't complete yet, make sure that the input is actually ready for more media data.
                CIContext *context = [CIContext contextWithOptions:nil];
                
                while ([self.assetWriterVideoInput isReadyForMoreMediaData] && !completedOrFailed) {
                    @autoreleasepool {
                        // Get the next video sample buffer, and append it to the output file.
                        CMSampleBufferRef sampleBuffer = [self.assetReaderVideoOutput copyNextSampleBuffer];
                        if (sampleBuffer != NULL) {
                            CMTime presentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                            CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                            CGAffineTransform videoTransform = CGAffineTransformInvert(self.videoFrameModel.actualTransform);
                            CIImage *imageCI = [[CIImage imageWithCVImageBuffer:pixelBuffer] imageByApplyingTransform:videoTransform];
                            CGImageRef imageCG = [context createCGImage:imageCI
                                                               fromRect:imageCI.extent];
                            
                            CVPixelBufferRef newPixelBuffer = [self pixelBufferFromImage:imageCG
                                                                             contentSize:[self.videoFrameModel.videoSettingModel videoContentSize]
                                                                               cropModel:self.videoFrameModel];
                            BOOL success = [self appendToAdapter:self.assetWriterVideoInputAdaptor
                                                     pixelBuffer:newPixelBuffer
                                                          atTime:presentTime
                                                       withInput:self.assetWriterVideoInput];
                            if (newPixelBuffer != NULL) {
                                CFRelease(newPixelBuffer);
                            }
                            CGImageRelease(imageCG);
                            imageCI = nil;
                            CMSampleBufferInvalidate(sampleBuffer);
                            CFRelease(sampleBuffer);
                            completedOrFailed = !success;
                            self.videoProgress.completedUnitCount = (int64_t)(CMTimeGetSeconds(presentTime) * 100 / CMTimeGetSeconds(self.asset.duration));
                        }
                        else {
                            completedOrFailed = YES;
                        }
                    }
                }
                if (completedOrFailed) {
                    // Mark the input as finished, but only if we haven't already done so, and then leave the dispatch group (since the video work has finished).
                    BOOL oldFinished = self.videoFinished;
                    self.videoFinished = YES;
                    if (oldFinished == NO) {
                        [self.assetWriterVideoInput markAsFinished];
                    }
                    dispatch_group_leave(self.cropQueueGroup);
                }
            }];
        }
        // Set up the notification that the dispatch group will send when the audio and video work have both finished.
        dispatch_group_notify(self.cropQueueGroup, self.mainCropQueue, ^{
            BOOL finalSuccess = YES;
            NSError *finalError = nil;
            // Check to see if the work has finished due to cancellation.
            
            // If cancellation didn't occur, first make sure that the asset reader didn't fail.
            if ([self.assetReader status] == AVAssetReaderStatusFailed)
            {
                finalSuccess = NO;
                finalError = [self.assetReader error];
            }
            // If the asset reader didn't fail, attempt to stop the asset writer and check for any errors.
            if (finalSuccess)
            {
                @weakify(self)
                [self.assetWriter finishWritingWithCompletionHandler:^{
                    @strongify(self)
                    if (self) {
                       NSError *finalError = [self.assetWriter error];
                        // Call the method to handle completion, and pass in the appropriate parameters to indicate whether reencoding was successful.
                        if (finalError) {
                            [self.assetReader cancelReading];
                            [self.assetWriter cancelWriting];
                            if (self.finishBlock) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    self.finishBlock(NO, finalError);
                                });
                            }
                        }
                        else {
                            if (self.finishBlock) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    self.finishBlock(YES, nil);
                                });
                            }
                        }
                    }
                }];
            }
            else {
                if (self.finishBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.finishBlock(NO, finalError);
                    });
                }
            }
            
            
        });
    }
    // Return success here to indicate whether the asset reader and writer were started successfully.
    return success;
}

- (BOOL)appendToAdapter:(AVAssetWriterInputPixelBufferAdaptor*)adaptor
            pixelBuffer:(CVPixelBufferRef)buffer
                 atTime:(CMTime)presentTime
              withInput:(AVAssetWriterInput*)writerInput {
    while (!writerInput.readyForMoreMediaData) {
        usleep(0.5);
    }
    return [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
}

- (CVPixelBufferRef)pixelBufferFromImage:(CGImageRef)image
                             contentSize:(CGSize)contentSize
                               cropModel:(NASCropVideoFrameModel *)cropModel {
    
    CVPixelBufferRef pixelBuffer = NULL;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    CGRect subRect = CGRectMake(imageSize.width * cropModel.leftRate, imageSize.height * cropModel.topRate, imageSize.width * cropModel.widthRate, imageSize.height * cropModel.heightRate);
    CGImageRef transformedCGImage = CGImageCreateWithImageInRect(image, subRect);
    CVReturn status = CVPixelBufferPoolCreatePixelBuffer (NULL, [self.assetWriterVideoInputAdaptor pixelBufferPool], &pixelBuffer);
    NSParameterAssert(status == kCVReturnSuccess && pixelBuffer != NULL);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *pixelData = CVPixelBufferGetBaseAddress(pixelBuffer);
    NSParameterAssert(pixelData != NULL);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(pixelData,
                                                    (size_t)contentSize.width,
                                                    (size_t)contentSize.height,
                                                    8,
                                                    CVPixelBufferGetBytesPerRow(pixelBuffer),
                                                    rgbColorSpace,
                                                    kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(newContext);
    CGContextDrawImage(newContext,
                       CGRectMake(0,
                                  0,
                                  (size_t)contentSize.width,
                                  (size_t)contentSize.height),
                       transformedCGImage);
    CGContextRelease(newContext);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CGColorSpaceRelease(rgbColorSpace);
    CGImageRelease(transformedCGImage);
    return pixelBuffer;
}

+ (NSString *)exportVideoDirectoryPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/cropVideoFrame/exportVideo/"];
}

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress,
                                                 width,
                                                 height,
                                                 8,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return image;
}

#pragma mark - Initialize -

- (NSInteger)fps {
    if (_fps == 0) {
        _fps = 30;
    }
    return _fps;
}

- (AVFileType)exportFileType {
    if (!_exportFileType) {
        _exportFileType = AVFileTypeMPEG4;
    }
    return _exportFileType;
}

- (NSURL *)exportFileURL {
    if (!_exportFileURL) {
        NSString *videoDirectoryPath = [[self class] exportVideoDirectoryPath];
        NSString *videoPath = [videoDirectoryPath stringByAppendingPathComponent:[[NASFileSystemManager generateDateTimeString] stringByAppendingString:@"_exportVideo.mp4"]];
        [NASFileSystemManager createPath:videoPath];
        _exportFileURL = [NSURL fileURLWithPath:videoPath];
    }
    return _exportFileURL;
}

- (NSProgress *)totalProgress {
    if (!_totalProgress) {
        _totalProgress = [NSProgress progressWithTotalUnitCount:100];
    }
    return _totalProgress;
}

- (NSProgress *)videoProgress {
    if (!_videoProgress) {
        _videoProgress = [NSProgress progressWithTotalUnitCount:100 parent:self.totalProgress pendingUnitCount:95];
    }
    return _videoProgress;
}

- (NSProgress *)audioProgress {
    if (!_audioProgress) {
        _audioProgress = [NSProgress progressWithTotalUnitCount:100 parent:self.totalProgress pendingUnitCount:5];
    }
    return _audioProgress;
}

#pragma mark -
#pragma mark 创建剪辑用的dispatchQueue
#pragma mark -

- (dispatch_queue_t)mainCropQueue {
    if (!_mainCropQueue) {
        _mainCropQueue = dispatch_queue_create("mainCropQueue", NULL);
    }
    return _mainCropQueue;
}

- (dispatch_queue_t)audioCropQueue {
    if (!_audioCropQueue) {
        _audioCropQueue = dispatch_queue_create("audioCropQueue", NULL);
    }
    return _audioCropQueue;
}

- (dispatch_queue_t)videoCropQueue {
    if (!_videoCropQueue) {
        _videoCropQueue = dispatch_queue_create("videoCropQueue", NULL);
    }
    return _videoCropQueue;
}

- (dispatch_group_t)cropQueueGroup {
    if (!_cropQueueGroup) {
        _cropQueueGroup = dispatch_group_create();
    }
    return _cropQueueGroup;
}

@end
