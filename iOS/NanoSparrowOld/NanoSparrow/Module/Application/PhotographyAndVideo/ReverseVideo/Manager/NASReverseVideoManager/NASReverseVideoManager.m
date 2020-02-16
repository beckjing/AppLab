//
//  NASReverseVideoManager.m
//  NanoSparrow
//
//  Created by yuecheng on 2/26/18.
//  Copyright © 2018 nanosparrow.com. All rights reserved.
//

#import "NASReverseVideoManager.h"
#import "NASHeader.h"

static NSString* const AVAssetTracksKey   = @"tracks";
static NSString* const AVAssetDurationKey = @"duration";

@interface NASReverseVideoManager()

@property (strong, nonatomic) AVAsset *asset;
@property (assign, nonatomic) CMTime durationTime;
@property (assign, nonatomic) CMTime writenTime;
@property (strong, nonatomic) dispatch_queue_t appendQueue;
@property (strong, nonatomic) NSProgress *totalProgress;
@property (copy,   nonatomic) UpdateProgressBlock progressBlock;
@property (copy,   nonatomic) FinishBlock finishBlock;


@end

@implementation NASReverseVideoManager

- (instancetype)initWithAsset:(AVAsset *)asset {
    self = [super init];
    if (self) {
        _asset = asset;
    }
    return self;
}

- (void)reverseVideoByAVFoundationWithProgressBlock:(UpdateProgressBlock)progressBlock
                                        finishBlock:(FinishBlock)finishBlock {
    self.totalProgress.completedUnitCount = 0;
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
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finishBlock) {
                self.finishBlock(NO, nil);
            }
        });
        return;
    }
    
    [self.asset loadValuesAsynchronouslyForKeys:@[AVAssetTracksKey, AVAssetDurationKey] completionHandler:^{
        @strongify(self)
        if (self) {
            AVAssetTrack *videoTrack = [[self.asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
            CMTimeScale timeScale = videoTrack.naturalTimeScale;
            float nominalFrameRate = videoTrack.nominalFrameRate;
            NSError *error = nil;
            AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:self.exportFileURL
                                                              fileType:self.exportFileType
                                                                 error:&error];
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (finishBlock) {
                        self.finishBlock(NO, error);
                    }
                });
                return;
            }
            NSDictionary *videoCompressionProps = @{
                                                    AVVideoAverageBitRateKey : @(videoTrack.estimatedDataRate),
                                                    };
            
            NSDictionary *writerOutputSettings = @{
                                                   AVVideoCodecKey : AVVideoCodecH264,
                                                   AVVideoWidthKey : @(videoTrack.naturalSize.width),
                                                   AVVideoHeightKey : @(videoTrack.naturalSize.height),
                                                   AVVideoCompressionPropertiesKey : videoCompressionProps,
                                                   };
            AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                                                             outputSettings:writerOutputSettings];
            [writerInput setExpectsMediaDataInRealTime:NO];
            [writerInput setTransform:videoTrack.preferredTransform];
            
            AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:writerInput
                                                                                                                  sourcePixelBufferAttributes:nil];
            
            [writer addInput:writerInput];
            [writer startWriting];
            CMTime startTime = kCMTimeZero;
            [writer startSessionAtSourceTime:startTime];
            
            CMTimeRange videoTimeRange = videoTrack.timeRange;
            
            CMTime durationTime = videoTimeRange.duration;
            
            CFTimeInterval duration = CMTimeGetSeconds(durationTime);
            
            CGSize naturalSize = videoTrack.naturalSize;
            
            size_t frameSize = (naturalSize.width * naturalSize.height) * 3 / 2;
            size_t framePerSecondSize = frameSize * nominalFrameRate;
            
            size_t maxSize = 1024 * 1024 * 100;
            size_t maxDuration = floorl(maxSize / framePerSecondSize);
            maxDuration = MAX(1.0, maxDuration);
            
            CFTimeInterval clipDuration = maxDuration;
            NSUInteger clipCount = ceil(duration / clipDuration);
            
            self.durationTime = durationTime;
            self.writenTime   = kCMTimeZero;
            
            CMTime clipTime = CMTimeMakeWithSeconds(clipDuration, timeScale);
            
            CMTimeRange *timeRanges = malloc(clipCount * sizeof(CMTimeRange));
            CMTime endTime = CMTimeRangeGetEnd(videoTimeRange);
            for (NSUInteger i = 0; i < clipCount ; i++) {
                CMTime startTime = CMTimeSubtract(endTime, clipTime);
                CMTime durationTime = clipTime;
                if (CMTIME_COMPARE_INLINE(startTime, <, videoTimeRange.start)) {
                    startTime = videoTimeRange.start;
                    durationTime = CMTimeSubtract(endTime, startTime);
                }
                CMTimeRange r = CMTimeRangeMake(startTime, durationTime);
                timeRanges[i] = r;
                endTime = startTime;
            }
            CFMutableArrayRef samples = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
            dispatch_async(self.appendQueue, ^{
                for (NSUInteger i = 0; i < clipCount; i++) {
                    self.totalProgress.completedUnitCount = (CGFloat)i / (CGFloat)clipCount * 100.0;
                    @autoreleasepool {
                        AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:self.asset error:nil];
                        CMTime clipStartTime = CMTimeMakeWithSeconds(clipDuration * i, timeScale);
                        CMTimeRange range = timeRanges[i];
                        reader.timeRange = range;
                        NSDictionary *readerOutputSettings = @{(__bridge id) kCVPixelBufferPixelFormatTypeKey :@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange), };
                        AVAssetReaderTrackOutput *readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack
                                                                                                            outputSettings:readerOutputSettings];
                        [reader addOutput:readerOutput];
                        [reader startReading];
                        
                        CMSampleBufferRef sample;
                        
                        while ((sample = [readerOutput copyNextSampleBuffer])) {
                            CFArrayAppendValue(samples, sample);
                        }
                        CFIndex count = CFArrayGetCount(samples);
                        
                        for (NSUInteger i = 0;  i < count; i++) {
                            CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp((CMSampleBufferRef)CFArrayGetValueAtIndex(samples, i));
                            CMTime newPresentationTime = CMTimeAdd(clipStartTime, CMTimeSubtract(presentationTime, range.start));
                            CVPixelBufferRef imageBufferRef = CMSampleBufferGetImageBuffer((CMSampleBufferRef)CFArrayGetValueAtIndex(samples, count - i - 1));
                            while (!writerInput.readyForMoreMediaData) {
                                [NSThread sleepForTimeInterval:0.05];
                            }
                            [pixelBufferAdaptor appendPixelBuffer:imageBufferRef
                                             withPresentationTime:newPresentationTime];
                            self.writenTime = newPresentationTime;
                        }
                        
                        for (CFIndex i = 0 ; i < count; i++) {
                            CFRelease(CFArrayGetValueAtIndex(samples, i));
                        }
                        CFArrayRemoveAllValues(samples);
                    }
                }
                
                free(timeRanges);
                CFRelease(samples);
                while (!writerInput.readyForMoreMediaData) {
                    [NSThread sleepForTimeInterval:0.1];
                }
                [writerInput markAsFinished];
                [writer finishWritingWithCompletionHandler:^{
                    BOOL success = NO;
                    NSError *error = nil;
                    if (writer.status == AVAssetWriterStatusCompleted && !writer.error) {
                        success = YES;
                    }
                    else {
                        error = writer.error;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.finishBlock) {
                            self.finishBlock(success, error);
                        }
                    });
                }];
            });
        }
    }];
}

+ (NSString *)exportVideoDirectoryPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/reverseVideo/exportVideo/"];
}

#pragma mark - Initialize -

- (NSProgress *)totalProgress {
    if (!_totalProgress) {
        _totalProgress = [NSProgress progressWithTotalUnitCount:100];
    }
    return _totalProgress;
}

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
        NSString *videoPath = [videoDirectoryPath stringByAppendingPathComponent:[[NASFileSystemManager generateDateTimeString] stringByAppendingString:@"_reversedVideo.mp4"]];
        [NASFileSystemManager createPath:videoPath];
        _exportFileURL = [NSURL fileURLWithPath:videoPath];
    }
    return _exportFileURL;
}

- (dispatch_queue_t)appendQueue {
    if (!_appendQueue) {
        _appendQueue = dispatch_queue_create("com.nanosparrow.reversevideo", NULL);
    }
    return _appendQueue;
}

@end
