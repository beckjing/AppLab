//
//  NASMetalCNNViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 3/14/18.
//  Copyright © 2018 nanosparrow.com. All rights reserved.
//

#import "NASMetalCNNViewController.h"
#import <MetalKit/MetalKit.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>

@interface NASMetalCNNViewController ()

@property (nonatomic, strong) MTKView *testView;

@end

@implementation NASMetalCNNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BOOL support = MPSSupportsMTLDevice(MTLCreateSystemDefaultDevice());
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
- (MTKView *)testView {
    if (!_testView) {
        _testView = [[MTKView alloc] init];
    }
    return _testView;
}

@end
