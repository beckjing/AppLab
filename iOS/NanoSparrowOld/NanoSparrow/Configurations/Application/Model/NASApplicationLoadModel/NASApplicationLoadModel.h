//
//  NASApplicationLoadModel.h
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASBaseModel.h"

@interface NASApplicationLoadModel : NASBaseModel

@property (nonatomic, strong) NSString *appID;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *appImageName;
@property (nonatomic, strong) NSString *OSVersion;
@property (nonatomic, strong) NSString *VCName;

@end
