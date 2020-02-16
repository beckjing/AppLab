//
//  NASARCheckManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/20/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASARCheckManager.h"

@implementation NASARCheckManager

+ (BOOL)supportARKit {
    if (@available(iOS 11.0, *)) {
        return [ARWorldTrackingConfiguration isSupported];
    }
    return NO;
}

@end
