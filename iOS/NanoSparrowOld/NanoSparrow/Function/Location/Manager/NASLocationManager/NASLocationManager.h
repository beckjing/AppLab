//
//  NASLocationManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <ReactiveObjC.h>

@interface NASLocationManager : NSObject

@property (readonly, nonatomic) CLLocation *currentLocation;

@property (readonly, nonatomic) RACSignal *locationSignal;

@property (readonly, nonatomic) RACSubject *addressSignal;

+ (instancetype)sharedManager;

- (void)startUpdatingLocationWithHandler:(void(^)(BOOL success))handler;

- (void)stopUpdatingLocation;

@end
