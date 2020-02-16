//
//  NASWeatherReportManager.h
//  NanoSparrow
//
//  Created by yuecheng on 2/27/18.
//  Copyright © 2018 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NASHeader.h"

typedef void(^updateWeatherReportBlock)(NSString *weather, CGFloat temperature);

@interface NASWeatherReportManager : NSObject

- (void)updateWeatherWithCallbackBlock:(updateWeatherReportBlock)callbackBlock;

@end
