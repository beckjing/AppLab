//
//  NASDevice.h
//  NanoSparrow
//
//  Created by yuecheng on 12/11/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#ifndef NASDevice_h
#define NASDevice_h

#define AvailableOSVersion(version) @available(iOS version, *)

#import <UIKit/UIKit.h>
#import "NSArray+Safe.h"

static inline CGFloat DeviceVersion() {
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    CGFloat deviceVersion   = [[[systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] floatValue] + [[[systemVersion componentsSeparatedByString:@"."] objectAtIndex:1] floatValue] / 10.0f;
    return deviceVersion;
}

static inline BOOL DeviceIsEqualOrGreaterThanVersion(NSString *version) {
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    NSArray *systemVersionArray = [systemVersion componentsSeparatedByString:@"."];
    NSArray *versionArray  = [version componentsSeparatedByString:@"."];
    NSUInteger checkPostion = systemVersionArray.count < versionArray.count ? systemVersionArray.count : versionArray.count;
    for (NSUInteger index = 0; index <checkPostion; index++) {
        if ([[systemVersionArray safe_objectAtIndex:index] floatValue] > [[versionArray safe_objectAtIndex:index] floatValue]) {
            return YES;
        }
        else if ([[systemVersionArray safe_objectAtIndex:index] floatValue] < [[versionArray safe_objectAtIndex:index] floatValue]) {
            return NO;
        }
    }
    if (systemVersionArray.count <= versionArray.count) {
        return YES;
    }
    else {
        return NO;
    }
    
}



#endif /* NASDevice_h */
