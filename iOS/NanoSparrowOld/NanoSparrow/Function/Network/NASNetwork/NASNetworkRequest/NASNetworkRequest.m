//
//  NASNetworkRequest.m
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASNetworkRequest.h"

@implementation NASNetworkRequest

- (instancetype)initWithURLString:(NSString *)url parameters:(NSDictionary *)parameters {
    self = [super init];
    if (self) {
        _url = url;
        _parameters = [parameters mutableCopy];
    }
    return self;
}

@end
