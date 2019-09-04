//
//  NASSwizzleUtility.h
//  KVODemo
//
//  Created by yuecheng on 2019/8/9.
//  Copyright © 2019 NanoSparrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NASSwizzleUtility : NSObject

+ (BOOL)swizzleInstanceMethodOriginalClass:(Class)originalClass
                          originalSelector:(SEL)originalSelector
                                  newClass:(Class)newClass
                               newSelector:(SEL)newSelector;

@end
