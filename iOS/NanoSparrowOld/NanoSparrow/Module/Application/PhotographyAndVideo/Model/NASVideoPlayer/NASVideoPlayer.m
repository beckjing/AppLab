//
//  NASVideoPlayer.m
//  NanoSparrow
//
//  Created by yuecheng on 12/15/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASVideoPlayer.h"
#import <ReactiveObjC.h>

@interface NASVideoPlayer()

@property (nonatomic, assign) CMTime startTime;
@property (nonatomic, assign) CMTime endTime;
@property (nonatomic, assign) CMTime checkFrequency;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) BOOL repeat;
@property (nonatomic, assign) BOOL hasAddEndNotification;

@end

@implementation NASVideoPlayer

- (void)dealloc {
    NSLog(@"remove observer");
    if (self.hasAddEndNotification) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [self stopLoopPlay];
}

- (void)playFrom:(CMTime)startTime to:(CMTime)endTime repeat:(BOOL)repeat {
    if (CMTIME_COMPARE_INLINE(startTime, >=, endTime) ||
        CMTIME_COMPARE_INLINE(startTime, >=, self.currentItem.duration)) {
        return;
    }
    if (CMTIME_COMPARE_INLINE(endTime, >=, CMTimeSubtract(self.currentItem.duration, CMTimeMakeWithSeconds(0.01, self.currentItem.duration.timescale)) )) {
        CGFloat accurate = 10.0f;
        CGFloat endSeconds = ((NSInteger)floor(CMTimeGetSeconds(self.currentItem.duration) * accurate)) / accurate;
        endTime = CMTimeMakeWithSeconds(endSeconds, self.currentItem.duration.timescale);
    }
    self.endTime        = endTime;
    self.startTime      = CMTIME_COMPARE_INLINE(startTime, > , kCMTimeZero) ? startTime : kCMTimeZero;
    self.repeat         = repeat;
    self.checkFrequency = CMTimeMakeWithSeconds(0.1, 1000);
    if (!self.hasAddEndNotification) {
        self.hasAddEndNotification = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.currentItem];
    }
    [self startLoopPlay];
}

- (void)startLoopPlay {
    [self stopLoopPlay];
    [self startPlay];
    [self addPeriodicTimeObserver];
}

- (void)startPlay {
    @weakify(self);
    CMTime toleranceTime = kCMTimeZero;
    CMTime toleranceBefore = CMTIME_COMPARE_INLINE(CMTimeSubtract(self.startTime, toleranceTime), >, kCMTimeZero) ? toleranceTime : self.startTime;
    CMTime toleranceAfter  = CMTIME_COMPARE_INLINE(CMTimeAdd(self.startTime, toleranceTime), <, self.endTime) ? toleranceTime : CMTimeSubtract(self.startTime, self.endTime);
    [self seekToTime:self.startTime toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:^(BOOL finished) {
        @strongify(self);
        if (finished) {
            if (self) {
                [self play];
            }
        }
    }];
}

- (void)addPeriodicTimeObserver {
    @weakify(self);
    self.timeObserver = [self addPeriodicTimeObserverForInterval:self.checkFrequency
                                                           queue:NULL
                                                      usingBlock:^(CMTime time) {
                                                          @strongify(self)
                                                          if (self) {
                                                              if (CMTIME_COMPARE_INLINE(time, >=, CMTimeSubtract(self.endTime, self.checkFrequency))) {
                                                                  if (self.repeat) {
                                                                      [self startLoopPlay];
                                                                  }
                                                              }
                                                          }
                                                      }];
}

- (void)playRepeat:(BOOL)repeat {
    [self playFrom:kCMTimeZero to:self.currentItem.duration repeat:repeat];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    if (self.repeat) {
        [self startLoopPlay];
    }
}

- (void)stopLoopPlay {
    if (self.timeObserver) {
        [self removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    [self pause];
}

@end
