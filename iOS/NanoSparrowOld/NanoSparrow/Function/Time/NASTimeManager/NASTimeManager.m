//
//  NASTimeManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/14/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASTimeManager.h"

@implementation NASTimeManager

+ (NSString *)timeStringFromSeconds:(NSTimeInterval)seconds {
    if (seconds < 3600.0f) {
        return [[self class] minuteAndSecondStringFromSeconds:seconds];
    }
    else {
        return [[self class] hourAndMinuteAndSecondStringFromSeconds:seconds];
    }
    
}

+ (NSString *)minuteAndSecondStringFromSeconds:(NSTimeInterval)seconds {
    NSInteger integerSeconds = ceil(seconds);
    NSString *secondString = [NSString stringWithFormat:@"%02ld", (long)integerSeconds % 60];
    NSString *minuteString = [NSString stringWithFormat:@"%02ld", (long)integerSeconds / 60];
    return [NSString stringWithFormat:@"%@:%@", minuteString, secondString];
}

+ (NSString *)hourAndMinuteAndSecondStringFromSeconds:(NSTimeInterval)seconds {
    NSInteger integerSeconds = ceil(seconds);
    NSString *secondString = [NSString stringWithFormat:@"%02ld", (long)integerSeconds % 60];
    NSString *minuteString = [NSString stringWithFormat:@"%02ld", (long)(integerSeconds / 60) % 60];
    NSString *hourString   = [NSString stringWithFormat:@"%ld", (long)integerSeconds / 3600];
    return [NSString stringWithFormat:@"%@:%@:%@", hourString, minuteString, secondString];
}
@end
