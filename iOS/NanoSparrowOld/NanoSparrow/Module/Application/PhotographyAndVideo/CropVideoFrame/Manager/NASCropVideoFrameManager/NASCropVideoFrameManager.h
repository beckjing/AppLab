//
//  NASCropVideoFrameManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/11/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NASHeader.h"
#import "NASCropVideoFrameModel.h"

typedef void(^FinishBlock)(BOOL isSuccess, NSError *error);
typedef void(^UpdateProgressBlock)(NSProgress *progress);

@interface NASCropVideoFrameManager : NSObject

@property (strong,   nonatomic) NSURL *exportFileURL;
@property (assign,   nonatomic) AVFileType exportFileType;
@property (assign,   nonatomic) NSInteger fps;
@property (readonly, nonatomic) NSProgress *totalProgress;

- (instancetype)initWithAsset:(AVAsset *)asset
                        model:(NASCropVideoFrameModel *)model;

- (void)cropWithProgressBlock:(UpdateProgressBlock)progressBlock
                  finishBlock:(FinishBlock)finishBlock;

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

+ (NSString *)exportVideoDirectoryPath;

@end
