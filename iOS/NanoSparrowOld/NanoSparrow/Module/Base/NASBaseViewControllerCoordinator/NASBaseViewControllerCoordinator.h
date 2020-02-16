//
//  NASBaseViewControllerCoordinator.h
//  NanoSparrow
//
//  Created by yuecheng on 12/12/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NASBaseViewControllerCoordinator : NSObject

@property (nonatomic, strong) NSMutableArray<NASBaseViewControllerCoordinator *> *childCoordinators;

@property (nonatomic, strong) UINavigationController *navigationController;

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

- (void)start;

@end
