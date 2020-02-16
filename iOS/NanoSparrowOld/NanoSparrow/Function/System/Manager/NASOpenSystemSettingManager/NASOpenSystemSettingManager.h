//
//  NASOpenSystemSettingManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/13/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NASOpenSystemSettingType) {
    NASOpenSystemSettingType_Privacy_Photos,
    NASOpenSystemSettingType_Privacy_Location
};

@interface NASOpenSystemSettingManager : NSObject

+ (void)openSystemSetting:(NASOpenSystemSettingType)settingType completionHandler:(void(^)(BOOL suceess))completion;

@end
