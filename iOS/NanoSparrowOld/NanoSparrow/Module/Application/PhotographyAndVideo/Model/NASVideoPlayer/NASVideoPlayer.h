//
//  NASVideoPlayer.h
//  NanoSparrow
//
//  Created by yuecheng on 12/15/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface NASVideoPlayer : AVPlayer

- (void)playFrom:(CMTime)startTime to:(CMTime)endTime repeat:(BOOL)repeat;
- (void)playRepeat:(BOOL)repeat;
- (void)stopLoopPlay;

@end
