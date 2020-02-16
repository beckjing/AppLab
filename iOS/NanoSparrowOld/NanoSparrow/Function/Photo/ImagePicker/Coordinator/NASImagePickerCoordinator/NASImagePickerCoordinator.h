//
//  NASImagePickerCoordinator.h
//  NanoSparrow
//
//  Created by yuecheng on 12/12/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASBaseViewControllerCoordinator.h"
#import <Photos/Photos.h>

typedef NS_ENUM(NSInteger, NASImagePickerShowType) {
    NASImagePickerShowType_Present,
    NASImagePickerShowType_Push,
    NASImagePickerShowType_None,
};

typedef NS_ENUM(NSInteger, NASImagePickerDidSelectCloseType) {
    NASImagePickerDidSelectCloseType_Close,
    NASImagePickerDidSelectCloseType_None,
};

@protocol NASImagePickerCoordinatorDelegate<NSObject>

@optional

- (BOOL)canHandleAsset:(PHAsset *)asset;
- (void)didSelectAsset:(PHAsset *)asset;

@end

@interface NASImagePickerCoordinator : NASBaseViewControllerCoordinator

@property (assign, nonatomic) NASImagePickerShowType imagePickerShowType;
@property (assign, nonatomic) NASImagePickerDidSelectCloseType imagePickerCloseType;
@property (weak,   nonatomic) id<NASImagePickerCoordinatorDelegate> delegate;

@end
