//
//  NASBaseLoadManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/8/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASBaseLoadManager.h"
#import "NASValidateObject.h"

@implementation NASBaseLoadManager

+ (instancetype)sharedManager {
    NSAssert([NSStringFromClass([self class]) isEqualToString:@"NASBaseLoadManager"], @"请重写自己的sharedManager方法");
    static dispatch_once_t onceToken;
    static NASBaseLoadManager *sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (NSArray *)loadArrayFromJSONFile:(NSString *)fileName {
    return ToValidateArray([self loadObjectFromJSONFile:fileName]);
}

- (NSDictionary *)loadDictionaryFromJSONFile:(NSString *)fileName {
    return ToValidateDictionary([self loadObjectFromJSONFile:fileName]);
}

- (id)loadObjectFromJSONFile:(NSString *)fileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    return  [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath]
                                            options:0
                                              error:nil];
}


@end
