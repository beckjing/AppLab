//
//  NASNetworkManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NASNetworkRequest;

typedef void(^successBlock)(id response);
typedef void(^failureBlock)(id response, NSError *error);

@interface NASNetworkManager : NSObject

+ (instancetype)sharedManager;

- (void)startNetworkWithRequest:(NASNetworkRequest *)request success:(successBlock)success failure:(failureBlock)failure;

@end
