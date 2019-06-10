//
//  ViewController.m
//  CacheDemo
//
//  Created by yuecheng on 2019/6/5.
//  Copyright © 2019 NanoSparrow. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *paramTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchData];
    // Do any additional setup after loading the view.
}


- (void)fetchData {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://aaac2ac9.ngrok.io/cache_control?param=%@", self.paramTextField.text ? : self.paramTextField.text]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
    [dataTask resume];
}


- (IBAction)clickFetchButton:(UIButton *)sender {
    [self fetchData];
}

@end
