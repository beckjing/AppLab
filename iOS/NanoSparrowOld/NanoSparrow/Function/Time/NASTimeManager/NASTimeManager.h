//
//  NASTimeManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/14/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NASTimeManager : NSObject

+ (NSString *)timeStringFromSeconds:(NSTimeInterval)seconds;

@end
