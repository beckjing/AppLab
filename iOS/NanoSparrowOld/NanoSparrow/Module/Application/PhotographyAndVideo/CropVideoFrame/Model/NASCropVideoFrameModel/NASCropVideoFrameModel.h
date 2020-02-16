//
//  NASCropVideoFrameModel.h
//  NanoSparrow
//
//  Created by yuecheng on 12/11/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>
#import "NASVideoSettingModel.h"

@interface NASCropVideoFrameModel : NSObject

@property (nonatomic, strong) NASVideoSettingModel *videoSettingModel;
@property (nonatomic, assign) CGFloat topRate;
@property (nonatomic, assign) CGFloat leftRate;
@property (nonatomic, assign) CGFloat widthRate;
@property (nonatomic, assign) CGFloat heightRate;
@property (nonatomic, assign) NSInteger transformTimes;
@property (nonatomic, assign) CGAffineTransform transform;

- (instancetype)initWithAsset:(AVAsset *)asset
                 settingModel:(NASVideoSettingModel *)settingModel;

- (void)refreshFrameModel;

- (CGSize)displaySize;

- (CGAffineTransform)actualTransform;

@end
