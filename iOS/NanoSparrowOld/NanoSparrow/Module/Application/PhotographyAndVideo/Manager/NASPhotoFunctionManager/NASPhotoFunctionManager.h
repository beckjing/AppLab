//
//  NASPhotoFunctionManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/11/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NASPhotoFunctionManager : NSObject

+ (void)saveImageToSystemPhotosWithImage:(UIImage *)image completionHandler:(void(^)(BOOL success, NSError *error))completionHandler;
+ (void)saveVideoToSystemPhotosWithURL:(NSURL *)url completionHandler:(void(^)(BOOL success, NSError *error))completionHandler;

@end
