//
//  NASDatabaseDemoViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 1/4/18.
//  Copyright © 2018 nanosparrow.com. All rights reserved.
//

#import "NASDatabaseDemoViewController.h"
#import "NASDatabaseManager.h"

@interface NASDatabaseDemoViewController ()

@property (nonatomic, strong) NASDatabaseManager *databaseManager;

@end

@implementation NASDatabaseDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setupUI {
    [super setupUI];
    BOOL success = [self.databaseManager.database open];
    if (success) {
        success = [self.databaseManager.database executeUpdate:@"CREATE TABLE IF NOT EXISTS t_student (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, age INTEGER DEFAULT 1)"];
        
        if (success) {
            NSLog(@"创建表成功");
        }
        else {
            NSLog(@"创建表失败");
        }
        success = [self.databaseManager.database executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?, ?);", @"jacke", @(11)];
        
        if (success) {
            NSLog(@"插入成功");
        } else {
            NSLog(@"插入失败");
        }
    }
//    FMResultSet *result = [self.databaseManager.database executeQuery:@"select * from t_student"];
    [self.databaseManager.database close];
}

- (NASDatabaseManager *)databaseManager {
    if (!_databaseManager) {
        _databaseManager = [[NASDatabaseManager alloc] initWithDatabaseName:@"test.sqlite"];
    }
    return _databaseManager;
}

@end
