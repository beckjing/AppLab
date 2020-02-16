//
//  NASBaseViewController.h
//  NanoSparrow
//
//  Created by yuecheng on 12/6/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASHeader.h"
#import "NASApplicationLoadModel.h"

@interface NASBaseViewController : UIViewController

@property (strong, nonatomic) NASApplicationLoadModel *applicationModel;

- (instancetype)initWithApplicationModel:(NASApplicationLoadModel *)applicationModel;

- (void)setupUI;
- (void)setupRAC;
- (void)fetchData;
- (void)configureUserActivity;
- (void)configureNavigationBar;
- (void)applicationWillResignActive:(NSNotification *)notification;
- (void)applicationDidBecomeActive:(NSNotification *)notification;

@end
