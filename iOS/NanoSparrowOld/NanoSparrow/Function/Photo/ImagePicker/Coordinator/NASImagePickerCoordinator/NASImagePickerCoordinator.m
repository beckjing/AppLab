//
//  NASImagePickerCoordinator.m
//  NanoSparrow
//
//  Created by yuecheng on 12/12/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASImagePickerCoordinator.h"
#import "NASImagePickerAlbumViewController.h"
#import "NASImagePickerPhotoGirdViewController.h"
#import "NASPhotoManager.h"

@interface NASImagePickerCoordinator()
<
NASImagePickerAlbumViewControllerDelegate,
NASImagePickerPhotoGirdViewControllerDelegate
>

@end

@implementation NASImagePickerCoordinator

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super initWithNavigationController:navigationController];
    if (self) {
        _imagePickerShowType = NASImagePickerShowType_Present;
    }
    return self;
}

- (void)start {
    
    [NASPhotoManager requestPhotoAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            NASImagePickerAlbumViewController *imagePickerAlbumVC = [[NASImagePickerAlbumViewController alloc] init];
            imagePickerAlbumVC.delegate = self;
            switch (self.imagePickerShowType) {
                case NASImagePickerShowType_Present:{
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerAlbumVC];
                    [self.navigationController presentViewController:navigationController
                                                            animated:YES
                                                          completion:^{
                                                              
                                                          }];
                    break;
                }
                case NASImagePickerShowType_Push:{
                    [self.navigationController pushViewController:imagePickerAlbumVC animated:YES];
                    break;
                }
                default:
                    break;
            }
        }
    }];
}

- (void)didCancelSelectAlbum {
    switch (self.imagePickerShowType) {
        case NASImagePickerShowType_Present:{
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                
            }];
            break;
        }
        case NASImagePickerShowType_Push:{
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)didSelectAssetCollection:(PHAssetCollection *)assetCollection fetchResult:(PHFetchResult<PHAsset *> *)fetchResult{
    NASImagePickerPhotoGirdViewController *photoGridVC = [[NASImagePickerPhotoGirdViewController alloc] initWithAssetCollection:assetCollection fetchResult:fetchResult];
    photoGridVC.delegate = self;
    switch (self.imagePickerShowType) {
        case NASImagePickerShowType_Push: {
            [self.navigationController pushViewController:photoGridVC animated:YES];
            break;
        }
        case NASImagePickerShowType_Present:{
            [((UINavigationController *)self.navigationController.presentedViewController) pushViewController:photoGridVC animated:YES];
            break;
        }
        default:
            break;
    }
    
}

- (void)didSelectAllPhotos:(PHFetchResult<PHAsset *> *)allPhotos {
    [self didSelectAssetCollection:nil fetchResult:allPhotos];
}

- (BOOL)canHandleAsset:(PHAsset *)asset {
    if (self.delegate && [self.delegate respondsToSelector:@selector(canHandleAsset:)]) {
        return [self.delegate canHandleAsset:asset];
    }
    return YES;
}

- (void)didSelectAsset:(PHAsset *)asset {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectAsset:)]) {
        [self.delegate didSelectAsset:asset];
    }
    switch (self.imagePickerCloseType) {
        case NASImagePickerDidSelectCloseType_Close:
            switch (self.imagePickerShowType) {
                case NASImagePickerShowType_Present:{
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                    break;
                }
                case NASImagePickerShowType_Push:{
                    UIViewController *lastViewController = nil;
                    for (UIViewController *viewController in self.navigationController.viewControllers) {
                        if ([viewController isKindOfClass:[NASImagePickerAlbumViewController class]]) {
                            break;
                        }
                        lastViewController = viewController;
                    }
                    if (lastViewController) {
                         [self.navigationController popToViewController:lastViewController animated:YES];
                    }
                }
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}
@end
