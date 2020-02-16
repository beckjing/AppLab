//
//  NASCategoryLoadModel.m
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASCategoryLoadModel.h"
#import "NASLocalizedStringModel.h"

@implementation NASCategoryLoadModel

- (void)configureModelWithDictionary:(NSDictionary *)dictionary {
    self.categoryID = [ToValidateDictionary(dictionary) objectForKey:@"categoryID"];
    self.categoryName = [NASLocalizedStringModel modelWithDictionary:ToValidateDictionary([ToValidateDictionary(dictionary) objectForKey:@"categoryName"])].localizeString;
}

@end
