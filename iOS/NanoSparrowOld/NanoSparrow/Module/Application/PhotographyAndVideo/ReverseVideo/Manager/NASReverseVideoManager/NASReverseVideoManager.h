//
//  NASReverseVideoManager.h
//  NanoSparrow
//
//  Created by yuecheng on 2/26/18.
//  Copyright © 2018 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^FinishBlock)(BOOL isSuccess, NSError *error);
typedef void(^UpdateProgressBlock)(NSProgress *progress);

@interface NASReverseVideoManager : NSObject

@property (strong,   nonatomic) NSURL *exportFileURL;
@property (assign,   nonatomic) AVFileType exportFileType;
@property (assign,   nonatomic) NSInteger fps;
@property (readonly, nonatomic) NSProgress *totalProgress;

- (instancetype)initWithAsset:(AVAsset *)asset;

- (void)reverseVideoByAVFoundationWithProgressBlock:(UpdateProgressBlock)progressBlock
                                        finishBlock:(FinishBlock)finishBlock;

+ (NSString *)exportVideoDirectoryPath;

@end
