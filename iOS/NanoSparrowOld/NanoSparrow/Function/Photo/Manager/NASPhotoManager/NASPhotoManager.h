//
//  NASPhotoManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/13/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface NASPhotoManager : NSObject

+ (void)requestPhotoAuthorization:(void(^)(PHAuthorizationStatus status))handler;

@end
