//
//  NASNetworkRequest.h
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NASNetworkRequest : NSObject

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSMutableDictionary *parameters;

- (instancetype)initWithURLString:(NSString *)url parameters:(NSDictionary *)parameters;

@end
