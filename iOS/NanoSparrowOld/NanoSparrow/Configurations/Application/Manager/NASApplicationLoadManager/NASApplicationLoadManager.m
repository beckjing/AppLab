//
//  NASApplicationLoadManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASApplicationLoadManager.h"
#import "NASDevice.h"

@interface NASApplicationLoadManager()

@property (nonatomic, strong) NSDictionary<NSString *, NASApplicationLoadModel *> *applicationDictionary;

@end

@implementation NASApplicationLoadManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static NASApplicationLoadManager *sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (NSDictionary<NSString *, NASApplicationLoadModel *> *)applicationDictionary {
    if (!_applicationDictionary) {
        NSArray *applications = [self loadArrayFromJSONFile:@"ApplicationConfiguration"];
        NSMutableDictionary *applicationDictionary = [NSMutableDictionary dictionaryWithCapacity:applications.count];
        for (NSDictionary *application in applications) {
            NASApplicationLoadModel *applicationModel = [NASApplicationLoadModel modelWithDictionary:application];
            if (DeviceIsEqualOrGreaterThanVersion(applicationModel.OSVersion)) {
                [applicationDictionary setObject:applicationModel forKey:applicationModel.appID];
            }
        }
        _applicationDictionary = [NSDictionary dictionaryWithDictionary:applicationDictionary];
    }
    return _applicationDictionary;
}

@end
