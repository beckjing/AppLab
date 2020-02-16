//
//  NASDatabaseManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/28/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASDatabaseManager.h"
#import "NASHeader.h"

@interface NASDatabaseManager()

@property (nonatomic, strong) NSString *databaseName;
@property (nonatomic, strong) FMDatabase *database;

@end

@implementation NASDatabaseManager

- (instancetype)initWithDatabaseName:(NSString *)databaseName {
    self = [super init];
    if (self) {
        _databaseName = databaseName;
    }
    return self;
}


- (FMDatabase *)database {
    if (!_database) {
        NSString *documentPath = [NASFileSystemManager documentDirectroryPath];
        NSString *databasePath = [[documentPath stringByAppendingPathComponent:@"sqlite"] stringByAppendingPathComponent:self.databaseName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
             [NASFileSystemManager createPath:databasePath];
        }
        _database = [FMDatabase databaseWithPath:databasePath];
    }
    return _database;
}

@end
