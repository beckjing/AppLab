//
//  NASCategoryModel.h
//  NanoSparrow
//
//  Created by yuecheng on 12/8/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASBaseModel.h"

@interface NASCategoryModel : NASBaseModel

@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, strong) NSArray<NSString *> *appIDs;

@end
