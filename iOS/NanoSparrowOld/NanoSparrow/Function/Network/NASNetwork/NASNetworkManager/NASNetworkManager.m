//
//  NASNetworkManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//


#import "NASHeader.h"

@implementation NASNetworkManager

+ (instancetype)sharedManager {
    
    static NASNetworkManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
    
}

- (void)startNetworkWithRequest:(NASNetworkRequest *)request success:(successBlock)success failure:(failureBlock)failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO//如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    manager.securityPolicy  = securityPolicy;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:request.url
       parameters:request.parameters
         progress:^(NSProgress * _Nonnull uploadProgress) {
             
         }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSError *error = nil;
              NSDictionary* json = [NSJSONSerialization
                                    JSONObjectWithData:responseObject
                                    options:kNilOptions
                                    error:&error];
              if (error) {
                  if (failure) {
                      failure(nil, error);
                  }
              }
              else {
                  if (success) {
                      success(json);
                  }
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (failure) {
                  failure(nil, error);
              }
          }
     ];
}

@end
