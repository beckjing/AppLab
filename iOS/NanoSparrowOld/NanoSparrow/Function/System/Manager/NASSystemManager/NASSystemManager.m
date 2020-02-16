//
//  NASSystemManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/13/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASSystemManager.h"
#import <UIKit/UIKit.h>

@implementation NASSystemManager

+ (void)openURL:(NSURL *)url completionHandler:(void(^)(BOOL suceess))completion {
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"跳转成功");
                }
                else {
                    NSLog(@"跳转失败");
                }
                if (completion) {
                    completion(success);
                }
            }];
        }
        else {
            BOOL openResult = [[UIApplication sharedApplication] openURL:url];
            if (openResult) {
                NSLog(@"跳转成功");
            }
            else {
                NSLog(@"跳转失败");
            }
            if (completion) {
                completion(openResult);
            }
        }
    }
    else {
        NSLog(@"跳转失败");
        if (completion) {
            completion(NO);
        }
    }
}

@end
