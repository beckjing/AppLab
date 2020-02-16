//
//  NASImagePickerPhotoGirdViewController.h
//  NanoSparrow
//
//  Created by yuecheng on 12/14/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASBaseViewController.h"
#import <Photos/Photos.h>

@protocol NASImagePickerPhotoGirdViewControllerDelegate<NSObject>

@optional

- (BOOL)canHandleAsset:(PHAsset *)asset;
- (void)didSelectAsset:(PHAsset *)asset;

@end

@interface NASImagePickerPhotoGirdViewController : NASBaseViewController

@property (weak, nonatomic) id<NASImagePickerPhotoGirdViewControllerDelegate> delegate;

// if assetCollection is nil, will fetch all photos, or you can also use init method, the effect is same.
- (instancetype)initWithAssetCollection:(PHAssetCollection *)assetCollection fetchResult:(PHFetchResult<PHAsset *> *)fetchResult;

@end
