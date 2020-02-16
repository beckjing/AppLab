//
//  NASBaseFlowLayout.m
//  NanoSparrow
//
//  Created by yuecheng on 12/14/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASBaseFlowLayout.h"

@implementation NASBaseFlowLayout

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureFlowLayout];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configureFlowLayout];
    }
    return self;
}

- (void)configureFlowLayout {
    
}

@end
