//
//  UIColor+Hex.h
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end
