//
//  NASImagePickerAlbumCollectionViewCell.m
//  NanoSparrow
//
//  Created by yuecheng on 12/13/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASImagePickerAlbumCollectionViewCell.h"

@interface NASImagePickerAlbumCollectionViewCell()

@property (weak,   nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak,   nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak,   nonatomic) IBOutlet UILabel *photoNumberLabel;
@property (strong, nonatomic) PHAsset *currentAsset;

@end

@implementation NASImagePickerAlbumCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
    
}

- (void)setupUI {
    self.thumbnailImageView.layer.cornerRadius = 5.0f;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.thumbnailImageView.image = nil;
    self.albumNameLabel.text      = @"";
    self.photoNumberLabel.text    = @"0";
}

- (void)configureCellWithThumbnail:(UIImage *)thumbnail
                         albumName:(NSString *)albumName
                       photoNumber:(NSUInteger)photoNumber {
    self.thumbnailImageView.image = thumbnail;
    self.albumNameLabel.text      = albumName;
    self.photoNumberLabel.text    = [NSString stringWithFormat:@"%lu", (unsigned long)photoNumber];
}

@end
