//
//  NASPhotoFunctionManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/11/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASPhotoFunctionManager.h"
#import <Photos/Photos.h>

@implementation NASPhotoFunctionManager

+ (void)saveImageToSystemPhotosWithImage:(UIImage *)image completionHandler:(void(^)(BOOL success, NSError *error))completionHandler {
    
    __block NSString *assetLocalIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        assetLocalIdentifier = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success == NO) {
            NSLog(@"保存照片失败!");
            NSLog(@"%@", error);
            if (completionHandler) {
                completionHandler(NO, error);
            }
        }
        PHAssetCollection *createdAssetCollection = [[self class] createdAssetCollection];
        if (createdAssetCollection == nil) {
            NSLog(@"创建相簿失败!");
            if (completionHandler) {
                completionHandler(NO, nil);
            }
        }
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetLocalIdentifier] options:nil].lastObject;
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdAssetCollection];
            [request addAssets:@[asset]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success == NO || error) {
                NSLog(@"保存照片失败!");
                if (completionHandler) {
                    completionHandler(NO, error);
                }
            }
            else {
                NSLog(@"保存照片成功!");
                if (completionHandler) {
                    completionHandler(YES, error);
                }
            }
        }];
    }];
    
}

+ (void)saveVideoToSystemPhotosWithURL:(NSURL *)url completionHandler:(void(^)(BOOL success, NSError *error))completionHandler {
    
    __block NSString *assetLocalIdentifier = nil;
    
    
    [[PHPhotoLibrary sharedPhotoLibrary]
     performChanges:^{
         assetLocalIdentifier = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url].placeholderForCreatedAsset.localIdentifier;
     }
     completionHandler:^(BOOL success, NSError * _Nullable error) {
         if (success == NO) {
             NSLog(@"保存视频失败!");
             NSLog(@"%@", error);
             if (completionHandler) {
                 completionHandler(NO, error);
             }
         }
         PHAssetCollection *createdAssetCollection = [[self class] createdAssetCollection];
         if (createdAssetCollection == nil) {
             NSLog(@"创建相簿失败!");
             if (completionHandler) {
                 completionHandler(NO, nil);
             }
         }
         
         [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
             PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetLocalIdentifier] options:nil].lastObject;
             PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdAssetCollection];
             [request addAssets:@[asset]];
         } completionHandler:^(BOOL success, NSError * _Nullable error) {
             if (success == NO || error) {
                 NSLog(@"保存视频失败!");
                 if (completionHandler) {
                     completionHandler(NO, error);
                 }
             }
             else {
                 NSLog(@"保存视频成功!");
                 if (completionHandler) {
                     completionHandler(YES, error);
                 }
             }
         }];
     }
     ];
}

+ (PHAssetCollection *)createdAssetCollection {
    // 从已存在相簿中查找这个应用对应的相簿
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                                                    subtype:PHAssetCollectionSubtypeAlbumRegular
                                                                                                    options:nil];
    NSString *album = @"NanoSparrow";
    for (PHAssetCollection *assetCollection in assetCollections) {
        if ([assetCollection.localizedTitle isEqualToString:album]) {
            return assetCollection;
        }
    }
    
    // 错误信息
    NSError *error = nil;
    
    // PHAssetCollection的标识, 利用这个标识可以找到对应的PHAssetCollection对象(相簿对象)
    __block NSString *assetCollectionLocalIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        // 创建相簿的请求
        assetCollectionLocalIdentifier = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:album].placeholderForCreatedAssetCollection.localIdentifier;
    }
                                                         error:&error];
    
    // 如果有错误信息
    if (error) {
        return nil;
    }
    
    // 获得刚才创建的相簿
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[assetCollectionLocalIdentifier] options:nil].lastObject;
}

@end
