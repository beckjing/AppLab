//
//  NASImagePickerAlbumCollectionViewCell.h
//  NanoSparrow
//
//  Created by yuecheng on 12/13/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

static CGFloat NASImagePickerAlbumCollectionViewCellWdith  = 96.0f;
static CGFloat NASImagePickerAlbumCollectionViewCellHeight = 128.0f;

@interface NASImagePickerAlbumCollectionViewCell : UICollectionViewCell

- (void)configureCellWithThumbnail:(UIImage *)thumbnail
                         albumName:(NSString *)albumName
                       photoNumber:(NSUInteger)photoNumber;

@end
