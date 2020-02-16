//
//  NASDemoViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 1/4/18.
//  Copyright © 2018 nanosparrow.com. All rights reserved.
//

#import "NASDemoViewController.h"
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>

@interface NASDemoViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation NASDemoViewController

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
//    self.playerLayer.frame = self.view.bounds;
//    [self.playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
//    [self.view.layer addSublayer:self.playerLayer];
//    [self.player play];
//    NSArray *testArray = @[@"1",@"2",@"3"];
//    NSString *testObject = [testArray objectAtIndex:0];
//    NSArray *testMuArray = @[testArray, testArray, testArray];
//    NSUInteger indexObject = [testMuArray indexOfObject:testArray];
//    NSLog(@"%lu", indexObject);
    
    NSString *string1 = [NSString stringWithFormat:@"nijino_saki"];
    NSString *string2 = [NSString stringWithFormat:@"nijino_saki"];
    NSLog(@"string1 hash %lu",[string1 hash]);
    NSLog(@"string2 hash %lu",[string2 hash]);
    NSArray *testArray1 = @[@"1",@"2",@"3"];
    NSArray *testArray2 = @[@"1", @"2", @"3", @"4"];
    NSLog(@"testArray1 hash %lu",[testArray1 hash]);
    NSLog(@"testArray2 hash %lu",[testArray2 hash]);
    NSSet *testSet = [NSSet setWithObjects:string1, string2, nil];
    NSLog(@"%@", testSet);
}

//- (AVPlayerLayer *)playerLayer {
//    if (!_playerLayer) {
//        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//    }
//    return _playerLayer;
//}
//
//- (AVPlayer *)player {
//    if (!_player) {
//        _player = [AVPlayer playerWithURL:[NSURL URLWithString:@"http://share.wuta-cam.com/video/VNRfq2.mp4"]];
//    }
//    return _player;
//}

@end
