//
//  NSArray+Safe.m
//  NanoSparrow
//
//  Created by yuecheng on 12/8/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NSArray+Safe.h"

@implementation NSArray (Safe)

- (id)safe_objectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        return nil;
    }
    return [self objectAtIndex:index];
}

@end
