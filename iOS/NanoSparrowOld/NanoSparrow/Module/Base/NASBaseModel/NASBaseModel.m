//
//  NASBaseModel.m
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASBaseModel.h"

@implementation NASBaseModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    return [[[self class] alloc] initWithDictionary:dictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        [self configureModelWithDictionary:dictionary];
    }
    return self;
}

- (void)configureModelWithDictionary:(NSDictionary *)dictionary {
    
}

@end
