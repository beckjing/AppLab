//
//  NASCropVideoFrameModel.m
//  NanoSparrow
//
//  Created by yuecheng on 12/11/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASCropVideoFrameModel.h"
#import "AVAsset+Display.h"

@interface NASCropVideoFrameModel()

@property (strong, nonatomic) AVAsset *asset;

@end

@implementation NASCropVideoFrameModel

- (instancetype)initWithAsset:(AVAsset *)asset
                 settingModel:(NASVideoSettingModel *)settingModel {
    self = [self init];
    if (self) {
        _asset             = asset;
        _videoSettingModel = settingModel ? settingModel : [[NASVideoSettingModel alloc] init];
        [self refreshFrameModel];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _leftRate       = 0.0f;
        _topRate        = 0.0f;
        _widthRate      = 0.0f;
        _heightRate     = 0.0f;
        _transformTimes = 0;
        _transform      = CGAffineTransformIdentity;
    }
    return self;
}

- (NASVideoSettingModel *)videoSettingModel {
    if (!_videoSettingModel) {
        _videoSettingModel = [[NASVideoSettingModel alloc] init];
    }
    return _videoSettingModel;
}

- (void)setTransformTimes:(NSInteger)transformTimes {
    _transformTimes = transformTimes % 4;
    self.transform = CGAffineTransformMakeRotation(_transformTimes * M_PI_2);
    [self refreshFrameModel];
}

- (void)refreshFrameModel {
    CGSize aspectRatio = [self.videoSettingModel videoContentSize];
    CGSize assetDisplaySize = [self displaySize];
    if ((assetDisplaySize.width / assetDisplaySize.height) > (aspectRatio.width / aspectRatio.height)) { //宽长
        self.heightRate = 1.0f;
        self.topRate    = 0.0f;
        self.widthRate  = (assetDisplaySize.height / aspectRatio.height * aspectRatio.width) / assetDisplaySize.width;
        self.leftRate   = (assetDisplaySize.width - assetDisplaySize.height / aspectRatio.height * aspectRatio.width) / assetDisplaySize.width / 2.0;
    }
    else {//高长
        self.widthRate  = 1.0f;
        self.leftRate   = 0.0f;
        self.topRate    = (assetDisplaySize.height - assetDisplaySize.width / aspectRatio.width * aspectRatio.height) / assetDisplaySize.height / 2.0;
        self.heightRate = (assetDisplaySize.width / aspectRatio.width * aspectRatio.height) / assetDisplaySize.height;
    }
}

- (CGSize)displaySize {
    return [self.asset displaySizeWithTransfrom:self.transform];
}

- (CGAffineTransform)actualTransform {
    return CGAffineTransformConcat(self.asset.displayPreferredTransform, self.transform);
}

@end
