//
//  NASApplicationLoadModel.m
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASApplicationLoadModel.h"
#import "NASLocalizedStringModel.h"

@implementation NASApplicationLoadModel

- (void)configureModelWithDictionary:(NSDictionary *)dictionary {
    self.appID = ToValidateString([ToValidateDictionary(dictionary) objectForKey:@"appID"]);
    self.appName = [NASLocalizedStringModel modelWithDictionary:ToValidateDictionary([ToValidateDictionary(dictionary) objectForKey:@"appName"])].localizeString;
    self.appImageName = ToValidateString([ToValidateDictionary(dictionary) objectForKey:@"appImageName"]);
    self.OSVersion = ToValidateString([ToValidateDictionary(dictionary) objectForKey:@"OSVersion"]);
    self.VCName = ToValidateString([ToValidateDictionary(dictionary) objectForKey:@"VCName"]);
}

@end
