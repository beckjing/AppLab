//
//  NASApplicationLoadManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASBaseLoadManager.h"
#import "NASApplicationLoadModel.h"

@interface NASApplicationLoadManager : NASBaseLoadManager

@property (nonatomic, readonly) NSDictionary<NSString *, NASApplicationLoadModel *> *applicationDictionary;

@end
