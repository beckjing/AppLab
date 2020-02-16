//
//  NASLongitudeAndLatitudeViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 12/20/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASLongitudeAndLatitudeViewController.h"
#import "NASLocationManager.h"

@interface NASLongitudeAndLatitudeViewController ()

@property (weak,   nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak,   nonatomic) IBOutlet UILabel *latitudeLabel;
@property (strong, nonatomic) RACDisposable *locationDisposable;
@property (strong, nonatomic) RACDisposable *addressDisposable;

@end

@implementation NASLongitudeAndLatitudeViewController

- (void)dealloc {
    [self.locationDisposable dispose];
    [self.addressDisposable dispose];
    [[NASLocationManager sharedManager] stopUpdatingLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    static NSUInteger subscribeNumber = 0;
    [[NASLocationManager sharedManager] startUpdatingLocationWithHandler:^(BOOL success) {
        if (success) {
            @weakify(self)
            self.locationDisposable = [[NASLocationManager sharedManager].locationSignal subscribeNext:^(id  _Nullable x) {
                @strongify(self)
                if (self) {
                    CLLocation *location = (CLLocation *)x;
                    self.longitudeLabel.text = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
                    self.latitudeLabel.text  = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
                }
            }];
            self.addressDisposable = [[NASLocationManager sharedManager].addressSignal subscribeNext:^(id  _Nullable x) {
                CLPlacemark *placemark = [x lastObject];
                NSLog(@"placemark.country is %@", placemark.country);
                NSLog(@"placemark.administrativeArea is %@", placemark.administrativeArea);
                NSLog(@"placemark.subAdministrativeArea is %@", placemark.subAdministrativeArea);
                NSLog(@"placemark.locality is %@", placemark.locality);
                NSLog(@"placemark.subLocality is %@", placemark.subLocality);
                NSLog(@"placemark.thoroughfare is %@", placemark.thoroughfare);
                NSLog(@"placemark.subThoroughfare is %@", placemark.subThoroughfare);
                NSLog(@"placemark.name is %@", placemark.name);
            }];
            subscribeNumber ++;
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
}

@end
