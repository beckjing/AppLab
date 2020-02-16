//
//  NASCategoryManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/8/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASBaseLoadManager.h"
#import "NASCategoryModel.h"
#import "NASCategoryLoadModel.h"

@interface NASCategoryManager : NASBaseLoadManager

@property (nonatomic, readonly) NSArray<NASCategoryLoadModel *> *categoryList;

- (NASCategoryLoadModel *)categoryLoadModelAtIndex:(NSUInteger)index;


@end
