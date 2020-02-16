//
//  NASCategoryModel.m
//  NanoSparrow
//
//  Created by yuecheng on 12/8/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASCategoryModel.h"
#import "NASDevice.h"
#import "NASApplicationLoadManager.h"


@implementation NASCategoryModel

- (void)configureModelWithDictionary:(NSDictionary *)dictionary {
    self.categoryID = ToValidateString([ToValidateDictionary(dictionary) objectForKey:@"categoryID"]);
    NSMutableArray *appIDs = [NSMutableArray array];
    for (NSString *appID in ToValidateArray([ToValidateDictionary(dictionary) objectForKey:@"appIDs"])) {
        NSString *validateAppID = ToValidateString(appID);
        NASApplicationLoadModel *applicationModel = [[NASApplicationLoadManager sharedManager].applicationDictionary objectForKey:validateAppID];
        if (applicationModel && DeviceIsEqualOrGreaterThanVersion(applicationModel.OSVersion)) {
            [appIDs addObject:validateAppID];
        }
    }
    self.appIDs = [NSArray arrayWithArray:appIDs];
}

@end
