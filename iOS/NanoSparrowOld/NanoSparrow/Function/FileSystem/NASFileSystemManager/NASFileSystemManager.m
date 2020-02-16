//
//  NASFileSystemManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/11/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASHeader.h"

@implementation NASFileSystemManager

+ (NSString *)documentDirectroryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
    return [paths safe_objectAtIndex:0];
}

+ (NSString *)libraryDirectroryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [paths safe_objectAtIndex:0];
}

+ (NSString *)generateDateTimeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}


+ (BOOL)createFolder:(NSString *)createDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL existed = [fileManager fileExistsAtPath:createDirectory isDirectory:&isDirectory];
    if (existed && isDirectory) {
        return YES;
    }
    else {
        return [fileManager createDirectoryAtPath:createDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (BOOL)createPath:(NSString *)path {
    NSURL *pathURL = [NSURL URLWithString:path];
    NSString *directory = [path stringByReplacingOccurrencesOfString:[pathURL lastPathComponent] withString:@""];
    if (![[self class] createFolder:directory]) {
        return NO;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    return YES;
}

@end
