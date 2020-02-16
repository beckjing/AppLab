//
//  NASFeaturedManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/18/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASBaseLoadManager.h"
#import "NASCategoryModel.h"
#import "NASCategoryLoadModel.h"
#import "NASApplicationLoadModel.h"

@interface NASFeaturedManager : NASBaseLoadManager

@property (nonatomic, readonly) NSArray<NASCategoryModel *> *categoryList;

- (NASCategoryLoadModel *)categoryLoadModelAtIndex:(NSUInteger)index;

- (NASApplicationLoadModel *)applicationLoadModelAtCategoryIndex:(NSUInteger)categoryIndex
                                                applicationIndex:(NSUInteger)applicationIndex;

@end
