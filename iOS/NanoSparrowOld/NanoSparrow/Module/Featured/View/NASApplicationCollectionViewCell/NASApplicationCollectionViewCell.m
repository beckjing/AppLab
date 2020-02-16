//
//  NASApplicationCollectionViewCell.m
//  NanoSparrow
//
//  Created by yuecheng on 12/18/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASApplicationCollectionViewCell.h"

@interface NASApplicationCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *appImageView;
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;

@end

@implementation NASApplicationCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.appNameLabel.text = @"";
    self.appImageView.image = nil;
}

- (void)configureCellWithModel:(NASApplicationLoadModel *)model {
    if (model.appImageName.length > 0) {
        self.appImageView.image = [UIImage imageNamed:model.appImageName];
    }
    self.appNameLabel.text  = model.appName;
}

@end
