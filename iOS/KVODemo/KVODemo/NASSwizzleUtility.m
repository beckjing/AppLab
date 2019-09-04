//
//  NASSwizzleUtility.m
//  KVODemo
//
//  Created by yuecheng on 2019/8/9.
//  Copyright © 2019 NanoSparrow. All rights reserved.
//

#import "NASSwizzleUtility.h"
#import <objc/runtime.h>

@implementation NASSwizzleUtility

+ (BOOL)swizzleInstanceMethodOriginalClass:(Class)originalClass
                          originalSelector:(SEL)originalSelector
                                  newClass:(Class)newClass
                               newSelector:(SEL)newSelector {
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    if (!originalMethod) {
        return NO;
    }
    
    Method newMethod = class_getInstanceMethod(newClass, newSelector);
    if (!newMethod) {
        return NO;
    }
    
    Method originalNewMethod = class_getInstanceMethod(originalClass, newSelector);
    
    if (originalNewMethod == nil) {
        BOOL addOriginalNewMethod = class_addMethod(originalClass,
                                                    newSelector,
                                                    method_getImplementation(originalMethod),
                                                    method_getTypeEncoding(originalMethod));
        if (addOriginalNewMethod == NO) {
            return NO;
        }
    }
    
    method_exchangeImplementations(originalMethod, newMethod);
    return YES;
}

@end
