//
//  NASImagePickerPhotoGirdViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 12/14/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASImagePickerPhotoGirdViewController.h"
#import "NASImagePickerPhotoCollectionViewCell.h"
#import "NASTimeManager.h"
#import "NASPhotoConstant.h"
#import "NASHeader.h"

@interface NASImagePickerPhotoGirdViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UICollectionViewDataSourcePrefetching,
PHPhotoLibraryChangeObserver
>


@property (strong, nonatomic) PHAssetCollection *assetCollection;
@property (strong, nonatomic) PHFetchResult<PHAsset *> *fetchResult;
@property (strong, nonatomic) PHCachingImageManager *imageManager;
@property (strong, nonatomic) NSOperationQueue *changeQueue;
@property (strong, nonatomic) NSMutableDictionary<NSIndexPath *, UIImage *> *allCacheImage;
@property (weak,   nonatomic) IBOutlet UICollectionView *photoGridCollectionView;


@end

@implementation NASImagePickerPhotoGirdViewController

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (instancetype)initWithAssetCollection:(PHAssetCollection *)assetCollection
                            fetchResult:(PHFetchResult<PHAsset *> *)fetchResult {
    self = [super init];
    if (self) {
        _assetCollection = assetCollection;
        _fetchResult     = fetchResult;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _assetCollection = nil;
        _fetchResult     = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.allCacheImage removeAllObjects];
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
    self.title =  [self isAllPhotos] ? NSLocalizedStringFromTable(@"ImagePicker.allPhotos", @"ImagePicker", @"All Photos") : self.assetCollection.localizedTitle;
    [self configureCollectionView];
}

- (void)configureCollectionView {
    
    [self.photoGridCollectionView registerNib:[UINib nibWithNibName:@"NASImagePickerPhotoCollectionViewCell" bundle:nil]
                   forCellWithReuseIdentifier:@"NASImagePickerPhotoCollectionViewCell"];
    self.photoGridCollectionView.dataSource   = self;
    self.photoGridCollectionView.delegate     = self;
    if (@available(iOS 10.0, *)) {
        self.photoGridCollectionView.prefetchDataSource = self;
    }
    self.photoGridCollectionView.contentInset = UIEdgeInsetsMake(0, SpaceLeftAndRight, 0, SpaceLeftAndRight);
   
    [self.photoGridCollectionView performBatchUpdates:^{
        [self.photoGridCollectionView reloadData];
    } completion:^(BOOL finished) {
        if (finished) {
            [self.photoGridCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self.photoGridCollectionView numberOfItemsInSection:0] - 1 inSection:0]
                                                 atScrollPosition:UICollectionViewScrollPositionBottom
                                                         animated:NO];
        }
    }];
}

- (void)fetchData {
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)clearData {
    [self.allCacheImage removeAllObjects];
}

- (BOOL)isAllPhotos {
    return self.assetCollection == nil;
}

#pragma mark - UICollectionViewDataSourcePrefetching -

- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        [self imageAtIndexPath:indexPath];
    }
}

#pragma mark - UICollectionViewDelegate -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.row];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(canHandleAsset:)]) {
            if (![self.delegate canHandleAsset:asset]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"ImagePicker.cannotHandleAssetTitle", @"ImagePicker", @"cannotHandleAssetTitle")
                                                                                         message:NSLocalizedStringFromTable(@"ImagePicker.cannotHandleAssetMessage", @"ImagePicker", @"cannotHandleAssetMessage") preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Operation.ok", @"Common", @"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
                [self presentViewController:alertController animated:YES completion:^{
                    
                }];
                return;
            }
        }
        if ([self.delegate respondsToSelector:@selector(didSelectAsset:)]) {
            [self.delegate didSelectAsset:asset];
        }
    }
}

#pragma mark - UICollectionViewDataSource -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NASImagePickerPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NASImagePickerPhotoCollectionViewCell" forIndexPath:indexPath];
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.row];
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        cell.timeLabel.hidden = NO;
        cell.timeLabel.text = [NASTimeManager timeStringFromSeconds:asset.duration];
    }
    cell.photoImageView.image = [self imageAtIndexPath:indexPath];
    return cell;
}

- (UIImage *)imageAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *image = [self.allCacheImage objectForKey:indexPath];
    if (image) {
        return image;
    }
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.row];
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.synchronous = NO;
    __block NSIndexPath *cacheIndexPath = [indexPath copy];
    @weakify(self)
    [self.imageManager requestImageForAsset:asset
                                 targetSize:CGSizeMake(NASImagePickerPhotoCollectionViewCellWidth, NASImagePickerPhotoCollectionViewCellHeight)
                                contentMode:PHImageContentModeAspectFill
                                    options:imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                        @strongify(self)
                                        if (self) {
                                            if (result) {
                                                [self.allCacheImage safe_setObject:result forKey:cacheIndexPath];
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self.photoGridCollectionView reloadItemsAtIndexPaths:@[cacheIndexPath]];
                                                });
                                            }
                                        }
                                    }];
    return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout -

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(NASImagePickerPhotoCollectionViewCellWidth, NASImagePickerPhotoCollectionViewCellHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat width = self.view.frame.size.width;
    NSInteger numberOfline = (width - SpaceLeftAndRight * 2) / NASImagePickerPhotoCollectionViewCellWidth;
    return (width - SpaceLeftAndRight * 2.0 - numberOfline * NASImagePickerPhotoCollectionViewCellWidth ) / (numberOfline - 1.0);
}

#pragma mark - PHPhotoLibraryChangeObserver - 

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    //待优化
    [self.changeQueue cancelAllOperations];
    @weakify(self)
    [self.changeQueue addOperationWithBlock:^{
        @strongify(self)
        if (self) {
            [self clearData];
            self.fetchResult = [changeInstance changeDetailsForFetchResult:self.fetchResult].fetchResultAfterChanges;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.photoGridCollectionView reloadData];
            });
        }
    }];
}

#pragma mark - Initialize -

- (NSMutableDictionary<NSIndexPath *,UIImage *> *)allCacheImage {
    if (!_allCacheImage) {
        _allCacheImage = [NSMutableDictionary dictionary];
    }
    return _allCacheImage;
}

- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}

- (PHFetchResult<PHAsset *> *)fetchResult {
    if (!_fetchResult) {
        if ([self isAllPhotos]) {
            PHFetchOptions *allPhotoOptions = [[PHFetchOptions alloc] init];
            allPhotoOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:PHFetchOptions_SortDescriptors_Key_creationDate
                                                                              ascending:YES],
                                                [NSSortDescriptor sortDescriptorWithKey:PHFetchOptions_SortDescriptors_Key_modificationDate
                                                                              ascending:YES]];
            _fetchResult = [PHAsset fetchAssetsWithOptions:allPhotoOptions];
        }
        else {
            PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
            fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:PHFetchOptions_SortDescriptors_Key_creationDate
                                                                           ascending:YES],
                                             [NSSortDescriptor sortDescriptorWithKey:PHFetchOptions_SortDescriptors_Key_modificationDate
                                                                           ascending:YES]];
            _fetchResult = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:fetchOptions];
        }
    }
    return _fetchResult;
}

- (NSOperationQueue *)changeQueue {
    if (!_changeQueue) {
        _changeQueue = [[NSOperationQueue alloc] init];
        _changeQueue.maxConcurrentOperationCount = 1;
    }
    return _changeQueue;
}

@end
