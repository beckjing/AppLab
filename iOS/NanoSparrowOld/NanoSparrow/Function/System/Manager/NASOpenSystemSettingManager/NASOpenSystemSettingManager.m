//
//  NASOpenSystemSettingManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/13/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASOpenSystemSettingManager.h"
#import "NASSystemManager.h"
#import <UIKit/UIKit.h>

@implementation NASOpenSystemSettingManager


+ (void)openSystemSetting:(NASOpenSystemSettingType)settingType completionHandler:(void(^)(BOOL suceess))completion {
    NSURL *openURL = [[self class] urlWithSettingType:settingType];
    if (openURL) {
        [NASSystemManager openURL:openURL completionHandler:^(BOOL suceess) {
            if (suceess) {
                completion(YES);
            }
            else {
                NSURL *applicationSettingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [NASSystemManager openURL:applicationSettingURL completionHandler:completion];
            }
        }];
    }
    else {
        if (completion) {
            completion(NO);
        }
    }
}

+ (NSURL *)urlWithSettingType:(NASOpenSystemSettingType)settingType {
    switch (settingType) {
        case NASOpenSystemSettingType_Privacy_Photos:{
            return [NSURL URLWithString:@"App-Prefs:root=Privacy&path=PHOTOS"];
            break;
        }
        case NASOpenSystemSettingType_Privacy_Location:{
            return [NSURL URLWithString:@"App-Prefs:root=Privacy&path=LOCATION"];
            break;
        }
        default:
            break;
    }
    return nil;
}
@end
