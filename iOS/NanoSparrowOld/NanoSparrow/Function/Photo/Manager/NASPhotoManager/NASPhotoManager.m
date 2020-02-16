//
//  NASPhotoManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/13/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASPhotoManager.h"
#import "NASHeader.h"

@implementation NASPhotoManager

+ (void)requestPhotoAuthorization:(void(^)(PHAuthorizationStatus status))handler {
    switch ([PHPhotoLibrary authorizationStatus]) {
        case PHAuthorizationStatusNotDetermined:{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (handler) {
                    handler(status);
                }
            }];
            break;
        }
        case PHAuthorizationStatusAuthorized:{
            if (handler) {
                handler(PHAuthorizationStatusAuthorized);
            }
            break;
        }
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"NSPhotoLibraryUsageDescription", @"InfoPlist",  @"NSPhotoLibraryUsageDescription")
                                                                                     message:NSLocalizedStringFromTable(@"Photo.authorizationRequestMessage", @"Photo", @"authorizationRequestMessage")
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Operation.confirm", @"Common", @"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [NASOpenSystemSettingManager openSystemSetting:NASOpenSystemSettingType_Privacy_Photos completionHandler:^(BOOL suceess) {
                    if (suceess) {
                        NSLog(@"跳转照片设置成功");
                    }
                    else {
                        NSLog(@"跳转照片设置失败");
                    }
                }];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Operation.cancel", @"Common", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (handler) {
                    handler([PHPhotoLibrary authorizationStatus]);
                }
            }]];
            [appDelegate.window.rootViewController presentViewController:alertController animated:YES completion:^{
                NSLog(@"photo authorize alert show");
            }];
        }
        default:
            break;
    }
}

@end
