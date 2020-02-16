//
//  NASFileSystemManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/11/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NASFileSystemManager : NSObject

+ (NSString *)documentDirectroryPath;
+ (NSString *)libraryDirectroryPath;
+ (NSString *)generateDateTimeString;
+ (BOOL)createFolder:(NSString *)createDirectory;
+ (BOOL)createPath:(NSString *)path;

@end
