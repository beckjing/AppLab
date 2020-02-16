//
//  NSMutableDictionary+Safe.h
//  NanoSparrow
//
//  Created by yuecheng on 12/14/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Safe)

- (void)safe_setObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end
