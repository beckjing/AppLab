//
//  NASVideoSettingModel.h
//  NanoSparrow
//
//  Created by yuecheng on 12/11/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSInteger, NASVideoAspectRatioType) {
    NASVideoAspectRatioType_1_1 = 0,
    NASVideoAspectRatioType_4_3,
    NASVideoAspectRatioType_3_4,
    NASVideoAspectRatioType_16_9,
    NASVideoAspectRatioType_9_16,
    NASVideoAspectRatioType_None
};

@interface NASVideoSettingModel : NSObject

@property (nonatomic, assign) NASVideoAspectRatioType aspectRatioType;

+ (NSString *)descriptionOfAspectRatioType:(NASVideoAspectRatioType)aspectRatioType;
- (CGSize)videoContentSize;

@end
