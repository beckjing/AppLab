//
//  NASVideoSettingModel.m
//  NanoSparrow
//
//  Created by yuecheng on 12/11/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASVideoSettingModel.h"

@implementation NASVideoSettingModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _aspectRatioType = NASVideoAspectRatioType_1_1;
    }
    return self;
}

- (CGSize)videoContentSize {
    switch (self.aspectRatioType) {
        case NASVideoAspectRatioType_1_1:{
            return CGSizeMake(768, 768);
            break;
        }
        case NASVideoAspectRatioType_4_3:{
            return CGSizeMake(1024, 768);
            break;
        }
        case NASVideoAspectRatioType_3_4:{
            return CGSizeMake(768, 1024);
            break;
        }
        case NASVideoAspectRatioType_9_16:{
            return CGSizeMake(900, 1600);
            break;
        }
        case NASVideoAspectRatioType_16_9:{
            return CGSizeMake(1600, 900);
            break;
        }
        default:
            break;
    }
    //默认zero
    return CGSizeZero;
}

+ (NSString *)descriptionOfAspectRatioType:(NASVideoAspectRatioType)aspectRatioType {
    switch (aspectRatioType) {
        case NASVideoAspectRatioType_1_1:{
            return NSLocalizedStringFromTable(@"AspectRatio_1_1", @"VideoFunction", @"AspectRatio_1_1");
            break;
        }
        case NASVideoAspectRatioType_4_3:{
            return NSLocalizedStringFromTable(@"AspectRatio_4_3", @"VideoFunction", @"AspectRatio_4_3");
            break;
        }
        case NASVideoAspectRatioType_3_4:{
            return NSLocalizedStringFromTable(@"AspectRatio_3_4", @"VideoFunction", @"AspectRatio_3_4");
            break;
        }
        case NASVideoAspectRatioType_16_9:{
            return NSLocalizedStringFromTable(@"AspectRatio_16_9", @"VideoFunction", @"AspectRatio_16_9");
            break;
        }
        case NASVideoAspectRatioType_9_16:{
            return NSLocalizedStringFromTable(@"AspectRatio_9_16", @"VideoFunction", @"AspectRatio_9_16");
            break;
        }
        default:
            break;
    }
    return @"";
}
@end
