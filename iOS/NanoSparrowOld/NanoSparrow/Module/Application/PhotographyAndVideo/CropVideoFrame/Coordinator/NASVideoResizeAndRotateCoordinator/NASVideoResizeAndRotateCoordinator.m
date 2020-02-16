//
//  NASVideoResizeAndRotateCoordinator.m
//  NanoSparrow
//
//  Created by yuecheng on 12/15/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASVideoResizeAndRotateCoordinator.h"
#import "NASVideoResizeAndRotateViewController.h"
#import "NASImagePickerCoordinator.h"

@interface NASVideoResizeAndRotateCoordinator()
<
NASImagePickerCoordinatorDelegate
>

@property (nonatomic, strong) NASImagePickerCoordinator *imagePickerCoordinator;

@end

@implementation NASVideoResizeAndRotateCoordinator

- (void)start {
    [self.imagePickerCoordinator start];
}

- (NASImagePickerCoordinator *)imagePickerCoordinator {
    if (!_imagePickerCoordinator) {
        _imagePickerCoordinator = [[NASImagePickerCoordinator alloc] initWithNavigationController:self.navigationController];
        _imagePickerCoordinator.imagePickerCloseType = NASImagePickerDidSelectCloseType_None;
        _imagePickerCoordinator.delegate = self;
    }
    return _imagePickerCoordinator;
}

- (BOOL)canHandleAsset:(PHAsset *)asset {
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        return YES;
    }
    return NO;
}

- (void)didSelectAsset:(PHAsset *)asset {
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NASVideoResizeAndRotateViewController *videoResizeAndRotateVC = [[NASVideoResizeAndRotateViewController alloc] initWithAsset:asset model:nil];
            [((UINavigationController *)self.navigationController.presentedViewController) pushViewController:videoResizeAndRotateVC animated:YES];
        });
        
    }];
   
}

@end
