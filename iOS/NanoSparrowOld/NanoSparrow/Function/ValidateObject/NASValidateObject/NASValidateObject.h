//
//  NASValidateObject.h
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#ifndef NASValidateObject_h
#define NASValidateObject_h

#import <Foundation/Foundation.h>


static inline BOOL ValidateString(NSString *string) {
    BOOL result = NO;
    if (string && [string isKindOfClass:[NSString class]] && [string length]) {
        result = YES;
    }
    return result;
}

static inline NSString *ToValidateString(NSString *string) {
    return ValidateString(string) ? string : @"";
}

static inline BOOL ValidateArray(NSArray *array) {
    BOOL result = NO;
    if (array && [array isKindOfClass:[NSArray class]] && [array count]) {
        result = YES;
    }
    return result;
}

static inline NSArray *ToValidateArray(NSArray *array) {
    return ValidateArray(array) ? array : @[];
}

static inline BOOL ValidateNumber(NSNumber *number) {
    BOOL result = NO;
    if (number && [number isKindOfClass:[NSNumber class]]) {
        result = YES;
    }
    return result;
}

static inline NSNumber *ToValidateNumber(NSNumber *number) {
    return ValidateNumber(number) ? number : @0;
}

static inline BOOL ValidateDictionary(NSDictionary *dictionary) {
    BOOL result = NO;
    if (dictionary && [dictionary isKindOfClass:[NSDictionary class]]) {
        result = YES;
    }
    return result;
}

static inline NSDictionary *ToValidateDictionary(NSDictionary *dictionary) {
    return ValidateDictionary(dictionary) ? dictionary : @{};
}

#endif /* NASValidateObject_h */
