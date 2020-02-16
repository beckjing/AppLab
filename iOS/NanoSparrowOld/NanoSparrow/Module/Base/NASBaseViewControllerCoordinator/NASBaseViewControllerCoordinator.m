//
//  NASBaseViewControllerCoordinator.m
//  NanoSparrow
//
//  Created by yuecheng on 12/12/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASBaseViewControllerCoordinator.h"

@implementation NASBaseViewControllerCoordinator

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        _navigationController = navigationController;
    }
    return self;
}

- (void)start {
    NSAssert(YES, @"%@没有重写start方法", NSStringFromClass([self class]));
}

- (NSMutableArray<NASBaseViewControllerCoordinator *> *)childCoordinators {
    if (!_childCoordinators) {
        _childCoordinators = [NSMutableArray array];
    }
    return _childCoordinators;
}

@end
