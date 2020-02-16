//
//  NASCategoryCollectionViewHeaderView.h
//  NanoSparrow
//
//  Created by yuecheng on 12/8/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NASCategoryLoadModel.h"

static CGFloat NASCategoryCollectionViewHeaderViewHeight = 50.0f;

@interface NASCategoryCollectionViewHeaderView : UICollectionReusableView

- (void)configureViewWithModel:(NASCategoryLoadModel *)model;

@end
