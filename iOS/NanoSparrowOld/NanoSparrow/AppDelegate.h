//
//  AppDelegate.h
//  NanoSparrow
//
//  Created by yuecheng on 12/4/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer NS_AVAILABLE_IOS(10.0);

- (void)saveContext NS_AVAILABLE_IOS(10.0);


@end

