//
//  NASImagePickerAlbumViewController.h
//  NanoSparrow
//
//  Created by yuecheng on 12/13/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASBaseViewController.h"
#import <Photos/Photos.h>

@protocol NASImagePickerAlbumViewControllerDelegate<NSObject>

@optional
- (void)didCancelSelectAlbum;
- (void)didSelectAssetCollection:(PHAssetCollection *)assetCollection fetchResult:(PHFetchResult<PHAsset *> *)fetchResult;
- (void)didSelectAllPhotos:(PHFetchResult<PHAsset *> *)allPhotos;

@end

@interface NASImagePickerAlbumViewController : NASBaseViewController

@property (weak,   nonatomic) id<NASImagePickerAlbumViewControllerDelegate> delegate;

@end
