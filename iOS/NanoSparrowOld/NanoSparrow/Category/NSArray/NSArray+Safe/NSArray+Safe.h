//
//  NSArray+Safe.h
//  NanoSparrow
//
//  Created by yuecheng on 12/8/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Safe)

- (id)safe_objectAtIndex:(NSUInteger)index;

@end
