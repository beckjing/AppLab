//
//  NASBaseLoadManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/8/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NASBaseLoadManager : NSObject

+ (instancetype)sharedManager;

- (id)loadObjectFromJSONFile:(NSString *)fileName;
- (NSArray *)loadArrayFromJSONFile:(NSString *)fileName;
- (NSDictionary *)loadDictionaryFromJSONFile:(NSString *)fileName;

@end
