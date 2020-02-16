//
//  NASCategoryCollectionViewHeaderView.m
//  NanoSparrow
//
//  Created by yuecheng on 12/8/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASCategoryCollectionViewHeaderView.h"

@interface NASCategoryCollectionViewHeaderView()

@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;

@end

@implementation NASCategoryCollectionViewHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configureViewWithModel:(NASCategoryLoadModel *)model {
    self.categoryNameLabel.text = model.categoryName;
}

@end
