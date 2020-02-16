//
//  NASMainViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 12/4/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASMainViewController.h"
#import "NASFeaturedViewController.h"
#import "NASCategoryViewController.h"
#import "NASSearchViewController.h"
#import "NASMineViewController.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface NASMainViewController ()
<
UITabBarControllerDelegate
>

@end

@implementation NASMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
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
    self.delegate = self;
   
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
}

@end
