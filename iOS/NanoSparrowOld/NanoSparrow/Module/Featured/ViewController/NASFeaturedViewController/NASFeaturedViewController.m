//
//  NASFeaturedViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 12/6/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASFeaturedViewController.h"
#import "NASApplicationCollectionViewCell.h"
#import "NASCategoryCollectionViewHeaderView.h"
#import "NASFeaturedManager.h"

@interface NASFeaturedViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>
@property (weak, nonatomic) IBOutlet UICollectionView *featuredCollectionView;

@end

@implementation NASFeaturedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    self.title = NSLocalizedStringFromTable(@"FeaturedVC.Featured", @"FeaturedVC", @"Featured");
    [self setupCollectionView];
}

- (void)setupCollectionView {
    self.featuredCollectionView.delegate   = self;
    self.featuredCollectionView.dataSource = self;
    self.featuredCollectionView.contentInset = UIEdgeInsetsMake(0, SpaceLeftAndRight, 0, SpaceLeftAndRight);
    [self.featuredCollectionView registerNib:[UINib nibWithNibName:@"NASApplicationCollectionViewCell" bundle:nil]
                  forCellWithReuseIdentifier:@"NASApplicationCollectionViewCell"];
    [self.featuredCollectionView registerNib:[UINib nibWithNibName:@"NASCategoryCollectionViewHeaderView" bundle:nil]
                  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                         withReuseIdentifier:@"NASCategoryCollectionViewHeaderView"];
    [self.featuredCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [NASFeaturedManager sharedManager].categoryList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NASCategoryModel *categoryModel = [[NASFeaturedManager sharedManager].categoryList objectAtIndex:section];
    return categoryModel.appIDs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NASApplicationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NASApplicationCollectionViewCell" forIndexPath:indexPath];
    NASApplicationLoadModel *appModel = [[NASFeaturedManager sharedManager] applicationLoadModelAtCategoryIndex:indexPath.section applicationIndex:indexPath.row];
    [cell configureCellWithModel:appModel];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NASCategoryCollectionViewHeaderView *collectionHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"NASCategoryCollectionViewHeaderView" forIndexPath:indexPath];
        NASCategoryLoadModel *categoryModel = [[NASFeaturedManager sharedManager] categoryLoadModelAtIndex:indexPath.section];
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

#pragma mark - UICollectionViewDelegate -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NASApplicationLoadModel *loadModel = [[NASFeaturedManager sharedManager] applicationLoadModelAtCategoryIndex:indexPath.section applicationIndex:indexPath.row];
    Class viewControllerClass = NSClassFromString(loadModel.VCName);
    if (viewControllerClass) {
        NASBaseViewController *vc = [[viewControllerClass alloc] initWithApplicationModel:loadModel];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
