//
//  NASImagePickerPhotoCollectionViewCell.h
//  NanoSparrow
//
//  Created by yuecheng on 12/14/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat NASImagePickerPhotoCollectionViewCellWidth  = 72.0f;
static CGFloat NASImagePickerPhotoCollectionViewCellHeight = 96.0f;

@interface NASImagePickerPhotoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
