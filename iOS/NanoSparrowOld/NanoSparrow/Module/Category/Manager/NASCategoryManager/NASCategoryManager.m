//
//  NASCategoryManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/8/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASCategoryManager.h"
#import "NASCategoryLoadManager.h"
#import "NASHeader.h"

@interface NASCategoryManager ()

@property (nonatomic, strong) NSArray<NASCategoryLoadModel *> *categoryList;

@end

@implementation NASCategoryManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static NASCategoryManager *sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (NSArray<NASCategoryLoadModel *> *)categoryList {
    if (!_categoryList) {
        NSArray *categoryIDs = ToValidateArray([ToValidateDictionary([self loadDictionaryFromJSONFile:@"CategoryVCConfiguration"]) objectForKey:@"CategoryIDs"]);
        NSMutableArray *mutableCategorys = [NSMutableArray arrayWithCapacity:categoryIDs.count];
        for (NSString *categoryID in categoryIDs) {
            NASCategoryLoadModel *categoryLoadModel = [[NASCategoryLoadManager sharedManager].categoryDictionary objectForKey:categoryID];
            [mutableCategorys addObject:categoryLoadModel];
        }
        _categoryList = [NSArray arrayWithArray:mutableCategorys];
    }
    return _categoryList;
}

- (NASCategoryLoadModel *)categoryLoadModelAtIndex:(NSUInteger)index {
    NSString *categoryID = [self categoryAtIndex:index].categoryID;
    return [[NASCategoryLoadManager sharedManager].categoryDictionary objectForKey:categoryID];
}

- (NASCategoryModel *)categoryAtIndex:(NSUInteger)index {
    return [self.categoryList safe_objectAtIndex:index];
}
@end
