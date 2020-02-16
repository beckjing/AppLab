//
//  UIColor+Hex.m
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    if (hexString == nil || hexString.length != 7 ) {
        return nil;
    }
    unsigned int red, green, blue;
    NSRange range;
    range.length = 2;
    
    range.location = 1;
    [[NSScanner scannerWithString:[hexString substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[hexString substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[hexString substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(CGFloat)(red/255.0f) green:(CGFloat)(green/255.0f) blue:(CGFloat)(blue/255.0f) alpha:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    
    return [UIColor colorWithHexString:hexString alpha:1.0f];
    
}

@end
