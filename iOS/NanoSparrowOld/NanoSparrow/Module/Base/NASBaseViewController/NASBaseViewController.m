//
//  NASBaseViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 12/6/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASBaseViewController.h"

@interface NASBaseViewController ()

@end

@implementation NASBaseViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithApplicationModel:(NASApplicationLoadModel *)applicationModel {
    self = [super init];
    if (self) {
        _applicationModel = applicationModel;
        [self addApplicationStatusObserver];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureUserActivity];
    [self setupUI];
    [self setupRAC];
    [self fetchData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addApplicationStatusObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    
}

- (void)setupUI {
    self.title = self.applicationModel.appName;
}

- (void)fetchData {
    
}

- (void)configureNavigationBar {
    
}

- (void)configureUserActivity {
    
}

- (void)setupRAC {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
