//
//  NSMutableArray+Safe.h
//  NanoSparrow
//
//  Created by yuecheng on 12/8/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Safe)

- (void)safe_insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)safe_addObject:(id)anObject;

@end
