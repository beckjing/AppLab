//
//  NASCategoryLoadManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASBaseLoadManager.h"
#import "NASCategoryLoadModel.h"

@interface NASCategoryLoadManager : NASBaseLoadManager

@property (nonatomic, readonly) NSDictionary<NSString *, NASCategoryLoadModel *> *categoryDictionary;

@end
