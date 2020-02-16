//
//  NASApplicationCollectionViewCell.h
//  NanoSparrow
//
//  Created by yuecheng on 12/18/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NASApplicationLoadModel.h"

static CGFloat ApplicationCollectionViewCellWidth  = 96.0f;
static CGFloat ApplicationCollectionViewCellHeight = 128.0f;

@interface NASApplicationCollectionViewCell : UICollectionViewCell

- (void)configureCellWithModel:(NASApplicationLoadModel *)model;

@end
