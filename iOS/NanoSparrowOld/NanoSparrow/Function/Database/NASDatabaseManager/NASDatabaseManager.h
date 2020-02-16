//
//  NASDatabaseManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/28/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@interface NASDatabaseManager : NSObject

@property (nonatomic, readonly) FMDatabase *database;

- (instancetype)initWithDatabaseName:(NSString *)databaseName;

@end
