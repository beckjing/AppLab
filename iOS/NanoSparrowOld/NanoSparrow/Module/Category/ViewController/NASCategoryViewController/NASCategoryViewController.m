//
//  NASCategoryViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 12/6/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASCategoryViewController.h"
#import "NASCategoryManager.h"
#import "NASApplicationCollectionViewCell.h"
#import "NASCategoryCollectionViewHeaderView.h"

@interface NASCategoryViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>

@property (weak, nonatomic) IBOutlet UICollectionView *categoryCollectionView;

@end

@implementation NASCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setupUI {
    self.title = NSLocalizedStringFromTable(@"CategoryVC.Category", @"CategoryVC", @"Category");
    [self setupCollectionView];
}

- (void)setupCollectionView {
    self.categoryCollectionView.delegate   = self;
    self.categoryCollectionView.dataSource = self;
    self.categoryCollectionView.contentInset = UIEdgeInsetsMake(0,
                                                                SpaceLeftAndRight,
                                                                0,
                                                                SpaceLeftAndRight);
    [self.categoryCollectionView registerNib:[UINib nibWithNibName:@"NASApplicationCollectionViewCell" bundle:nil]
                  forCellWithReuseIdentifier:@"NASApplicationCollectionViewCell"];
    [self.categoryCollectionView registerNib:[UINib nibWithNibName:@"NASCategoryCollectionViewHeaderView" bundle:nil]
                  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                         withReuseIdentifier:@"NASCategoryCollectionViewHeaderView"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [NASCategoryManager sharedManager].categoryList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NASCategoryCollectionViewHeaderView *collectionHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"NASCategoryCollectionViewHeaderView" forIndexPath:indexPath];
        NASCategoryLoadModel *categoryModel = [[NASCategoryManager sharedManager] categoryLoadModelAtIndex:indexPath.section];
        [collectionHeaderView configureViewWithModel:categoryModel];
        return collectionHeaderView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(ApplicationCollectionViewCellWidth, ApplicationCollectionViewCellHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.view.frame.size.width - 2 * SpaceLeftAndRight, NASCategoryCollectionViewHeaderViewHeight);
}


@end
