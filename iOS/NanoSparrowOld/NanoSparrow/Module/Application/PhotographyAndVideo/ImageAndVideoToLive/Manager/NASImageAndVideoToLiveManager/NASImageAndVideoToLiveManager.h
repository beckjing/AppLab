//
//  NASImageAndVideoToLiveManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/10/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef void(^CompletionBlock)(BOOL isSuccess, NSError *error);

API_AVAILABLE(ios(9.1))

@interface NASImageAndVideoToLiveManager : NSObject

- (instancetype)initWithImage:(UIImage *)image videoAsset:(AVAsset *)asset;

- (void)transferWithCompletionBlock:(CompletionBlock)completionBlock;

@end
