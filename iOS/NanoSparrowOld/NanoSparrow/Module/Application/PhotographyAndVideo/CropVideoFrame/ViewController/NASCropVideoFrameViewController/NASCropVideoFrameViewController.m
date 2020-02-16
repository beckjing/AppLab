//
//  NASCropVideoFrameViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 12/11/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASCropVideoFrameViewController.h"
#import "NASVideoResizeAndRotateCoordinator.h"

@interface NASCropVideoFrameViewController ()


@property (weak,   nonatomic) IBOutlet UIButton *addVideoButton;
@property (strong, nonatomic) NASVideoResizeAndRotateCoordinator *videoResizeAndRotateCoordinator;

@end

@implementation NASCropVideoFrameViewController

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
}

- (IBAction)clickAddPhoto:(UIButton *)sender {
    [self.videoResizeAndRotateCoordinator start];
}

- (NASVideoResizeAndRotateCoordinator *)videoResizeAndRotateCoordinator {
    if (!_videoResizeAndRotateCoordinator) {
        _videoResizeAndRotateCoordinator = [[NASVideoResizeAndRotateCoordinator alloc] initWithNavigationController:self.navigationController];
    }
    return _videoResizeAndRotateCoordinator;
}

@end
