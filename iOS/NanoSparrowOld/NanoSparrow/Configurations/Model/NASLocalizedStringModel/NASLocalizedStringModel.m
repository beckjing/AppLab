//
//  NASLocalizedStringModel.m
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASLocalizedStringModel.h"
#import "NASHeader.h"

@interface NASLocalizedStringModel()

@property (strong, nonatomic) NSString *localizedTable;
@property (strong, nonatomic) NSString *localizedKey;

@end

@implementation NASLocalizedStringModel

- (void)configureModelWithDictionary:(NSDictionary *)dictionary {
    self.localizedTable = ToValidateString([ToValidateDictionary(dictionary) objectForKey:@"localizedTable"]);
    self.localizedKey   = ToValidateString([ToValidateDictionary(dictionary) objectForKey:@"localizedKey"]);
}

- (NSString *)localizeString {
    return ToValidateString(NSLocalizedStringFromTable(self.localizedKey, self.localizedTable, self.localizedKey));
}

@end
