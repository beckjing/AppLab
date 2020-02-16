//
//  NASARDemoViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 12/28/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASARDemoViewController.h"
#import "NASARCheckManager.h"


@interface NASARDemoViewController ()

@property (weak, nonatomic) IBOutlet ARSCNView *sceneView;

@end

@implementation NASARDemoViewController

- (void)viewDidLoad {
    if ([NASARCheckManager supportARKit]) {
        [super viewDidLoad];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"暂不支持AR"
                                                                       message:@"抱歉，目前的系统版本或者硬件不支持AR，请尝试升级设备，或者购买较新的iOS设备"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        @weakify(self)
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Operation.ok", @"Common", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self)
            if (self) {
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    
                }];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }];
        [alert addAction:confirm];
        [self.navigationController presentViewController:alert animated:YES completion:^{
            
        }];
    }
    
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

@end
