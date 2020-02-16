//
//  NSMutableArray+Safe.m
//  NanoSparrow
//
//  Created by yuecheng on 12/8/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NSMutableArray+Safe.h"

@implementation NSMutableArray (Safe)

- (void)safe_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (index > self.count) {
        return;
    }
    [self insertObject:anObject atIndex:index];
}

- (void)safe_addObject:(id)anObject {
    if (anObject) {
        [self addObject:anObject];
    }
}

@end
