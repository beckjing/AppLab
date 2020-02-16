//
//  NASWifiManager.m
//  NanoSparrow
//
//  Created by 景悦诚 on 2018/5/2.
//  Copyright © 2018 nanosparrow.com. All rights reserved.
//

#import "NASWifiManager.h"

@implementation NASWifiManager

+ (instancetype)sharedManager {
    
    static NASWifiManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
    
}

@end
