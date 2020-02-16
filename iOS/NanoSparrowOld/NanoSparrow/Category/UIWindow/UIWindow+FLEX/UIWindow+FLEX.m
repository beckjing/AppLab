//
//  UIWindow+FLEX.m
//  NanoSparrow
//
//  Created by yuecheng on 12/11/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "UIWindow+FLEX.h"
#import "NASHeader.h"

@implementation UIWindow (FLEX)

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
#ifdef DEBUG
    if (motion == UIEventSubtypeMotionShake) {
        if ([FLEXManager sharedManager].isHidden) {
            
            NSLog(@"show FLEX");
            [[FLEXManager sharedManager] showExplorer];
        }
        else {
            NSLog(@"hide FLEX");
            [[FLEXManager sharedManager] hideExplorer];
        }
    }
#endif
}

@end
