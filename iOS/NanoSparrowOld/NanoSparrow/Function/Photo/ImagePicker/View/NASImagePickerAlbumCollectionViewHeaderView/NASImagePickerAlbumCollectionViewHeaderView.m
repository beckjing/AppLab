//
//  NASImagePickerAlbumCollectionViewHeaderView.m
//  NanoSparrow
//
//  Created by yuecheng on 12/13/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASImagePickerAlbumCollectionViewHeaderView.h"

@interface NASImagePickerAlbumCollectionViewHeaderView()

@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;

@end

@implementation NASImagePickerAlbumCollectionViewHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.albumNameLabel.text = @"";
}

- (void)configureAlbumName:(NSString *)albumName {
    self.albumNameLabel.text = albumName;
}

@end
