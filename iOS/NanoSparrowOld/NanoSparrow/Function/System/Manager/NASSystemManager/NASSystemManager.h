//
//  NASSystemManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/13/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NASSystemManager : NSObject

+ (void)openURL:(NSURL *)url completionHandler:(void(^)(BOOL suceess))completion;

@end
