//
//  NASImagePickerPhotoCollectionViewCell.m
//  NanoSparrow
//
//  Created by yuecheng on 12/14/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASImagePickerPhotoCollectionViewCell.h"

@implementation NASImagePickerPhotoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.timeLabel.hidden = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.photoImageView.image = nil;
    self.timeLabel.text = @"";
    self.timeLabel.hidden = YES;
}

@end
