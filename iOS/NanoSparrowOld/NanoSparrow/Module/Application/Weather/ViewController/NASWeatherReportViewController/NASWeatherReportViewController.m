//
//  NASWeatherReportViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 2/27/18.
//  Copyright © 2018 nanosparrow.com. All rights reserved.
//

#import "NASWeatherReportViewController.h"
#import "NASHeader.h"

@interface NASWeatherReportViewController ()

@end

@implementation NASWeatherReportViewController

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
    self.edgesForExtendedLayout = UIRectEdgeNone;
//    NSArray *fontFamilys = [UIFont familyNames];
//    for (NSString *familyName in fontFamilys) {
//        NSLog(@"%@", familyName);
//        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
//            NSLog(@"%@", fontName);
//        }sh
//    }
    [self requestWeatherData];
}

- (void)requestWeatherData {
    NASNetworkRequest *request = [[NASNetworkRequest alloc] initWithURLString:@"https://free-api.heweather.com/s6/air/now?parameters"
                                                                   parameters:@{@"location" : @"121.40,31.9",
                                                                                @"key" : @"cdf28ed5526042efaf12c43f99a29638"}];
    [[NASNetworkManager sharedManager] startNetworkWithRequest:request success:^(id response) {
        
    } failure:^(id response, NSError *error) {
        
    }];
}

@end
