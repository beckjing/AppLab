//
//  NASBaseModel.h
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NASValidateObject.h"

@interface NASBaseModel : NSObject

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;

- (void)configureModelWithDictionary:(NSDictionary *)dictionary;

@end
