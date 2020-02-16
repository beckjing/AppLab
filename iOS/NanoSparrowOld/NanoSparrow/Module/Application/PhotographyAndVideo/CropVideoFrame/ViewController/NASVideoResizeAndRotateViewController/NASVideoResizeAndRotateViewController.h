//
//  NASVideoResizeAndRotateViewController.h
//  NanoSparrow
//
//  Created by yuecheng on 12/15/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASBaseViewController.h"
#import "NASCropVideoFrameModel.h"
#import <AVFoundation/AVFoundation.h>

@interface NASVideoResizeAndRotateViewController : NASBaseViewController

- (instancetype)initWithAsset:(AVAsset *)asset
                        model:(NASCropVideoFrameModel *)model;

@end
