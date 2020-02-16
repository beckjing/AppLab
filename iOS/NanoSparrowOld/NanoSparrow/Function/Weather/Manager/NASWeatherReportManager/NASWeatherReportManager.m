//
//  NASWeatherReportManager.m
//  NanoSparrow
//
//  Created by yuecheng on 2/27/18.
//  Copyright © 2018 nanosparrow.com. All rights reserved.
//

#import "NASWeatherReportManager.h"
#import "NASLocationManager.h"

@interface NASWeatherReportManager()

@property (strong, nonatomic) RACDisposable *locationDisposable;
@property (strong, nonatomic) RACDisposable *addressDisposable;

@end

@implementation NASWeatherReportManager

- (void)updateWeatherWithCallbackBlock:(updateWeatherReportBlock)callbackBlock {
    [[NASLocationManager sharedManager] startUpdatingLocationWithHandler:^(BOOL success) {
        
    }];
}

@end
