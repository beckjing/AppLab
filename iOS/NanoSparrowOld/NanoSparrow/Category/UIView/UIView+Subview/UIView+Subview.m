//
//  UIView+Subview.m
//  NanoSparrow
//
//  Created by yuecheng on 12/18/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "UIView+Subview.h"

@implementation UIView (Subview)

- (void)removeAllSubviews {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

@end
