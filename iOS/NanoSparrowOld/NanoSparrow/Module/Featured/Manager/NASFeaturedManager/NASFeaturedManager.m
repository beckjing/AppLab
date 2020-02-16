//
//  NASFeaturedManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/18/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASFeaturedManager.h"
#import "NASCategoryLoadManager.h"
#import "NASApplicationLoadManager.h"
#import "NASHeader.h"

@interface NASFeaturedManager()

@property (nonatomic, strong) NSArray<NASCategoryModel *> *categoryList;

@end

@implementation NASFeaturedManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static NASFeaturedManager *sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (NSArray<NASCategoryModel *> *)categoryList {
    if (!_categoryList) {
        NSArray *categorys = [self loadArrayFromJSONFile:@"FeaturedVCConfiguration"];
        NSMutableArray *mutableCategorys = [NSMutableArray arrayWithCapacity:categorys.count];
        for (NSDictionary *category in categorys) {
            NASCategoryModel *categoryModel = [NASCategoryModel modelWithDictionary:category];
            if (categoryModel.appIDs.count > 0) {//保证category中有应用才展示
                [mutableCategorys addObject:categoryModel];
            }
        }
        _categoryList = [NSArray arrayWithArray:mutableCategorys];
    }
    return _categoryList;
}

- (NASCategoryLoadModel *)categoryLoadModelAtIndex:(NSUInteger)index {
    NSString *categoryID = [self categoryAtIndex:index].categoryID;
    return [[NASCategoryLoadManager sharedManager].categoryDictionary objectForKey:categoryID];
}

- (NASApplicationLoadModel *)applicationLoadModelAtCategoryIndex:(NSUInteger)categoryIndex
                                                applicationIndex:(NSUInteger)applicationIndex {
    NASCategoryModel *categoryModel = [self categoryAtIndex:categoryIndex];
    NSString *appID = [categoryModel.appIDs safe_objectAtIndex:applicationIndex];
    return [[NASApplicationLoadManager sharedManager].applicationDictionary objectForKey:appID];
}

- (NASCategoryModel *)categoryAtIndex:(NSUInteger)index {
    return [self.categoryList safe_objectAtIndex:index];
}
@end
