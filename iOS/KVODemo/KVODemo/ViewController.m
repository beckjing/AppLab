//
//  ViewController.m
//  KVODemo
//
//  Created by yuecheng on 2019/8/9.
//  Copyright © 2019 NanoSparrow. All rights reserved.
//

#import "ViewController.h"
#import "NASPerson.h"

@interface ViewController ()

@property (nonatomic, strong) NASPerson *person;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.person = [[NASPerson alloc] init];
    NSLog(@"%s", object_getClassName(self.person));
    [self.person addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    NSLog(@"%s", object_getClassName(self.person));
}


@end
