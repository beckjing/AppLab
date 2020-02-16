//
//  NASCategoryLoadManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASCategoryLoadManager.h"

@interface NASCategoryLoadManager()

@property (nonatomic, strong) NSDictionary<NSString *, NASCategoryLoadModel *> *categoryDictionary;

@end

@implementation NASCategoryLoadManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static NASCategoryLoadManager *sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (NSDictionary<NSString *, NASCategoryLoadModel *> *)categoryDictionary {
    if (!_categoryDictionary) {
        NSArray  *categorys = [self loadArrayFromJSONFile:@"CategoryConfiguration"];
        NSMutableDictionary *categoryDictionary = [NSMutableDictionary dictionaryWithCapacity:categorys.count];
        for (NSDictionary *category in categorys) {
            NASCategoryLoadModel *categoryModel = [NASCategoryLoadModel modelWithDictionary:category];
            [categoryDictionary setObject:categoryModel forKey:categoryModel.categoryID];
        }
        _categoryDictionary = [NSDictionary dictionaryWithDictionary:categoryDictionary];
    }
    return _categoryDictionary;
}

@end
