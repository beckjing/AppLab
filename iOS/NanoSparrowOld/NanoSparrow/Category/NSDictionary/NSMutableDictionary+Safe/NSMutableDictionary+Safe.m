//
//  NSMutableDictionary+Safe.m
//  NanoSparrow
//
//  Created by yuecheng on 12/14/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NSMutableDictionary+Safe.h"

@implementation NSMutableDictionary (Safe)

- (void)safe_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
}

@end
