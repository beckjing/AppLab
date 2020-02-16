//
//  NASLocationManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASLocationManager.h"
#import "NASHeader.h"


@interface NASLocationManager()

@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) RACSignal *locationSignal;
@property (strong, nonatomic) RACSubject *addressSignal;
@property (assign, nonatomic) BOOL isUpdatingLocation;

@end

@implementation NASLocationManager

+ (instancetype)sharedManager {
    
    static NASLocationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        sharedManager.isUpdatingLocation = NO;
    });
    return sharedManager;
}


- (void)startUpdatingLocationWithHandler:(void(^)(BOOL success))handler {
    if (self.isUpdatingLocation) {
        if (handler) {
            handler(YES);
        }
        return;
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    }
    else if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted &&
             [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways &&
             [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"NSLocationUsageDescription", @"InfoPlist",  @"NSLocationUsageDescription")
                                                                       message:NSLocalizedStringFromTable(@"Location.authorizationRequestMessage", @"Location", @"authorizationRequestMessage") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Operation.confirm", @"Common", @"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [NASOpenSystemSettingManager openSystemSetting:NASOpenSystemSettingType_Privacy_Location completionHandler:^(BOOL suceess) {
                if (suceess) {
                    NSLog(@"跳转地理位置设置成功");
                }
                else {
                    NSLog(@"跳转地理位置设置失败");
                }
            }];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Operation.cancel", @"Common", @"Cancel")
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    if (handler) {
                                                        handler(NO);
                                                    }
                                                }]];
        [appDelegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    else {
        [self.locationManager startUpdatingLocation];
        self.isUpdatingLocation = YES;
        @weakify(self)
        [self.locationSignal subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            if (self) {
                CLLocation *location = (CLLocation *)x;
                CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
                @weakify(self)
                if (AvailableOSVersion(11.0)) {
                    [geoCoder reverseGeocodeLocation:location preferredLocale:[NSLocale currentLocale] completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                        @strongify(self)
                        if (self) {
                            [self.addressSignal sendNext:placemarks];
                        }
                    }];
                }
                else {
                    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                        @strongify(self)
                        if (self) {
                            [self.addressSignal sendNext:placemarks];
                        }
                    }];
                }
            }
        }];
        if (handler) {
            handler(YES);
        }
    }
}

- (void)stopUpdatingLocation {
    
    [self.locationManager stopUpdatingLocation];
    self.isUpdatingLocation = NO;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

- (RACSubject *)addressSignal {
    if (!_addressSignal) {
        _addressSignal = [RACSubject subject];
    }
    return _addressSignal;
}

- (RACSignal *)locationSignal {
    if (!_locationSignal) {
        RACDelegateProxy *proxy = [[RACDelegateProxy alloc] initWithProtocol:@protocol(CLLocationManagerDelegate)];
        objc_setAssociatedObject(self, _cmd, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        proxy.rac_proxiedDelegate = self;
        _locationSignal = [[[proxy rac_signalForSelector:@selector(locationManager:didUpdateLocations:)] map:^id _Nullable(RACTuple * _Nullable value) {
            NSArray *locations = [value objectAtIndex:1];
            CLLocation *lastLocation = nil;
            if (locations.count > 0) {
                lastLocation = [locations lastObject];
            }
            return lastLocation;
        }] distinctUntilChanged];
        self.locationManager.delegate = (id<CLLocationManagerDelegate>)proxy;
    }
    return _locationSignal;
}

@end
