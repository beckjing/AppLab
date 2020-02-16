//
//  NASImagePickerAlbumCollectionViewHeaderView.h
//  NanoSparrow
//
//  Created by yuecheng on 12/13/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat NASImagePickerAlbumCollectionViewHeaderViewHeight = 50.0f;

@interface NASImagePickerAlbumCollectionViewHeaderView : UICollectionReusableView

- (void)configureAlbumName:(NSString *)albumName;

@end
