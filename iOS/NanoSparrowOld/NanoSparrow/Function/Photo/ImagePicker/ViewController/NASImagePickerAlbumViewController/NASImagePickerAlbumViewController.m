//
//  NASImagePickerAlbumViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 12/13/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASImagePickerAlbumViewController.h"
#import "NASImagePickerAlbumCollectionViewCell.h"
#import "NASImagePickerAlbumCollectionViewHeaderView.h"
#import "NASPhotoConstant.h"
#import "NASPhotoManager.h"
#import "NASHeader.h"

@interface NASImagePickerAlbumViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
PHPhotoLibraryChangeObserver
>

@property (weak,   nonatomic) IBOutlet UICollectionView *albumCollectionView;

@property (strong, nonatomic) PHFetchResult<PHAsset *> *allPhotos;
@property (strong, nonatomic) NSMutableArray<PHAssetCollection *> *allSmartAlbums;
@property (strong, nonatomic) NSMutableArray<PHAssetCollection *> *allUserAlbums;
@property (strong, nonatomic) NSMutableArray *allResult;
@property (strong, nonatomic) NSMutableDictionary<NSIndexPath *, UIImage *> *allCacheImage;
@property (strong, nonatomic) NSMutableDictionary<NSIndexPath *, PHFetchResult *> *allCacheFetchResult;
@property (strong, nonatomic) PHCachingImageManager *imageManager;
@property (strong, nonatomic) NSOperationQueue *changeQueue;

@end

@implementation NASImagePickerAlbumViewController

- (void)dealloc {
    self.allPhotos = nil;
    [self.allSmartAlbums removeAllObjects];
    [self.allUserAlbums removeAllObjects];
    [self.allResult removeAllObjects];
    [self.allCacheImage removeAllObjects];
    [self.allCacheFetchResult removeAllObjects];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
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
    self.title = NSLocalizedStringFromTable(@"ImagePicker.photos", @"ImagePicker", @"Photos");
    self.changeQueue.maxConcurrentOperationCount = 1;
    [self configureCollectionView];
}

- (void)fetchData {
    [self fetchAlbumData];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)clearData {
    self.allPhotos = nil;
    [self.allResult removeAllObjects];
    [self.allSmartAlbums removeAllObjects];
    [self.allUserAlbums removeAllObjects];
    [self.allCacheImage removeAllObjects];
    [self.allCacheFetchResult removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.albumCollectionView reloadData];
    });
}

- (void)fetchAlbumData {
    PHFetchOptions *allPhotoOptions = [[PHFetchOptions alloc] init];
    allPhotoOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:PHFetchOptions_SortDescriptors_Key_creationDate
                                                                      ascending:YES],
                                        [NSSortDescriptor sortDescriptorWithKey:PHFetchOptions_SortDescriptors_Key_modificationDate
                                                                      ascending:YES]];
    self.allPhotos = [PHAsset fetchAssetsWithOptions:allPhotoOptions];
    if (self.allPhotos.count > 0) {
        [self.allResult safe_addObject:self.allPhotos];
    }
    [[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self needShowAssetCollection:obj]) {
            PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
            fetchOptions.fetchLimit = 1;
            if ([PHAsset fetchAssetsInAssetCollection:obj options:fetchOptions].count > 0) {
                [self.allSmartAlbums safe_addObject:obj];
            }
        }
    }];
    if (self.allSmartAlbums.count > 0) {
        [self.allResult safe_addObject:self.allSmartAlbums];
    }
    [[PHAssetCollection fetchTopLevelUserCollectionsWithOptions:nil] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *collection = (PHAssetCollection *)obj;
            PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
            fetchOptions.fetchLimit = 1;
            if ([PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions].count > 0) {
                [self.allUserAlbums safe_addObject:collection];
            }
        }
    }];
    if (self.allUserAlbums.count > 0) {
        [self.allResult safe_addObject:self.allUserAlbums];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.albumCollectionView reloadData];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self precacheImage];
    });
    
}

- (BOOL)needShowAssetCollection:(PHAssetCollection *)assetCollection {
    if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) {
        return NO;
    }
    if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumDeleteRecently) {
        return NO;
    }
    return YES;
}

- (void)precacheImage {
    [self.allCacheImage removeAllObjects];
    NSUInteger section = 0;
    if (self.allPhotos.count > 0) {
        [self cacheImageAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        section ++;
    }
    @weakify(self)
    if (self.allSmartAlbums.count > 0) {
        __block NSUInteger smartAlbumsSection = section;
        [self.allSmartAlbums enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self)
            if (self) {
                if (self.allSmartAlbums.count == 0) {
                    *stop = YES;
                }
                else {
                    [self cacheImageAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:smartAlbumsSection]];
                }
                
            }
        }];
        section ++;
    }
    if (self.allUserAlbums.count > 0) {
        __block NSUInteger userAlbumsSection = section;
        [self.allUserAlbums enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self)
            if (self) {
                if (self.allUserAlbums.count == 0) {
                    *stop = YES;
                }
                else {
                    [self cacheImageAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:userAlbumsSection]];
                }
                
            }
        }];
    }
    
}

- (void)cacheImageAtIndexPath:(NSIndexPath *)indexPath {
    __block NSIndexPath *cacheIndexPath = [indexPath copy];
    PHFetchResult *fetchResult = [self resultAtIndexPath:indexPath];
    PHAsset *asset = nil;
    asset = [fetchResult lastObject];
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.synchronous = NO;
   
    @weakify(self)
    [self.imageManager requestImageForAsset:asset
                                 targetSize:CGSizeMake(NASImagePickerAlbumCollectionViewCellWdith, NASImagePickerAlbumCollectionViewCellWdith)
                                contentMode:PHImageContentModeAspectFill
                                    options:requestOptions
                              resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                  @strongify(self)
                                  if (self) {
                                      @weakify(self)
                                      __block UIImage *cacheImage = result;
                                      __block NSIndexPath *indexPathKey = cacheIndexPath;
                                      [self.changeQueue addOperationWithBlock:^{
                                          @strongify(self)
                                          if (self) {
                                              if (cacheImage) {
                                                  [self.allCacheImage safe_setObject:cacheImage forKey:indexPathKey];
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      if ([[self.albumCollectionView indexPathsForVisibleItems] containsObject:cacheIndexPath]) {
                                                          [self.albumCollectionView reloadItemsAtIndexPaths:@[cacheIndexPath]];
                                                      }
                                                  });
                                              }
                                          }
                                      }];
                                  }
                              }];
}

- (void)configureCollectionView {
    [self.albumCollectionView registerNib:[UINib nibWithNibName:@"NASImagePickerAlbumCollectionViewCell" bundle:nil]
               forCellWithReuseIdentifier:@"NASImagePickerAlbumCollectionViewCell"];
    [self.albumCollectionView registerNib:[UINib nibWithNibName:@"NASImagePickerAlbumCollectionViewHeaderView" bundle:nil]
               forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                      withReuseIdentifier:@"NASImagePickerAlbumCollectionViewHeaderView"];
    self.albumCollectionView.delegate = self;
    self.albumCollectionView.dataSource = self;
    self.albumCollectionView.contentInset = UIEdgeInsetsMake(0, SpaceLeftAndRight, 0, SpaceLeftAndRight);
}

- (void)configureNavigationBar {
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(clickCancelButton:)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)clickCancelButton:(UIBarButtonItem *)barButtonItem {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCancelSelectAlbum)]) {
        [self.delegate didCancelSelectAlbum];
    }
}

#pragma mark - UICollectionViewDelegate -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id result = [self.allResult safe_objectAtIndex:indexPath.section];
    if (result == self.allPhotos) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectAllPhotos:)]) {
            [self.delegate didSelectAllPhotos:self.allPhotos];
        }
    }
    else {
       PHAssetCollection *assetCollection = [result safe_objectAtIndex:indexPath.row];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectAssetCollection:fetchResult:)]) {
            [self.delegate didSelectAssetCollection:assetCollection fetchResult:[self resultAtIndexPath:indexPath]];
        }
    }
}

#pragma mark - UICollectionViewDataSource -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.allResult.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id result = [self.allResult safe_objectAtIndex:section];
    if (result == self.allPhotos) {
        return 1;
    }
    else if (result == self.allSmartAlbums) {
        return self.allSmartAlbums.count;
    }
    else if (result == self.allUserAlbums) {
        return self.allUserAlbums.count;
    }
    return 0;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(NASImagePickerAlbumCollectionViewCellWdith, NASImagePickerAlbumCollectionViewCellHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.view.frame.size.width - 2 * SpaceLeftAndRight, NASImagePickerAlbumCollectionViewHeaderViewHeight);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NASImagePickerAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NASImagePickerAlbumCollectionViewCell" forIndexPath:indexPath];
    id result = [self.allResult safe_objectAtIndex:indexPath.section];
    PHFetchResult *indexPathResult = [self resultAtIndexPath:indexPath];
    NSUInteger photoNumber = indexPathResult.count;
    UIImage *albumImage = [self.allCacheImage objectForKey:indexPath];
    if (!albumImage) {
        [self cacheImageAtIndexPath:indexPath];
    }
    NSString *albumName = @"";
    if (result == self.allPhotos) {
        albumName = NSLocalizedStringFromTable(@"ImagePicker.allPhotos", @"ImagePicker", @"All Photos");
    }
    else if (result == self.allSmartAlbums) {
        PHAssetCollection *assetCollection = [self.allSmartAlbums safe_objectAtIndex:indexPath.row];
        albumName = assetCollection.localizedTitle;
    }
    else if (result == self.allUserAlbums) {
        PHAssetCollection *assetCollection = [self.allUserAlbums safe_objectAtIndex:indexPath.row];
        albumName = assetCollection.localizedTitle;
    }
  
    [cell configureCellWithThumbnail:albumImage
                           albumName:albumName
                         photoNumber:photoNumber];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NASImagePickerAlbumCollectionViewHeaderView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"NASImagePickerAlbumCollectionViewHeaderView" forIndexPath:indexPath];
        id result = [self.allResult safe_objectAtIndex:indexPath.section];
        if (result == self.allPhotos) {
            [headerView configureAlbumName:NSLocalizedStringFromTable(@"ImagePicker.allPhotos", @"ImagePicker", @"All Photos")];
        }
        else if (result == self.allSmartAlbums) {
            [headerView configureAlbumName:NSLocalizedStringFromTable(@"ImagePicker.smartAlbums", @"ImagePicker", @"Smart Albums")];
        }
        else if (result == self.allUserAlbums) {
            [headerView configureAlbumName:NSLocalizedStringFromTable(@"ImagePicker.myAlbums", @"ImagePicker", @"My Albums")];
        }
        return headerView;
    }
    return nil;
}

- (PHFetchResult *)resultAtIndexPath:(NSIndexPath *)indexPath {
    id result = [self.allResult safe_objectAtIndex:indexPath.section];
    if (result == self.allPhotos) {
        return self.allPhotos;
    }
    else if (result == self.allSmartAlbums) {
        PHFetchResult *photos = [self.allCacheFetchResult objectForKey:indexPath];
        if (photos) {
            return photos;
        }
        PHAssetCollection *assetCollection = [self.allSmartAlbums objectAtIndex:indexPath.row];
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:PHFetchOptions_SortDescriptors_Key_creationDate
                                                                       ascending:YES],
                                         [NSSortDescriptor sortDescriptorWithKey:PHFetchOptions_SortDescriptors_Key_modificationDate
                                                                       ascending:YES]];
        photos = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
        [self.allCacheFetchResult safe_setObject:photos forKey:indexPath];
        return photos;
    }
    else if (result == self.allUserAlbums) {
        PHFetchResult *photos = [self.allCacheFetchResult objectForKey:indexPath];
        if (photos) {
            return photos;
        }
        PHAssetCollection *assetCollection = [self.allUserAlbums safe_objectAtIndex:indexPath.row];
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:PHFetchOptions_SortDescriptors_Key_creationDate
                                                                       ascending:YES],
                                         [NSSortDescriptor sortDescriptorWithKey:PHFetchOptions_SortDescriptors_Key_modificationDate
                                                                       ascending:YES]];
        photos = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection options:fetchOptions];
        [self.allCacheFetchResult safe_setObject:photos forKey:indexPath];
        return photos;
    }
    return nil;
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
            [self fetchAlbumData];
        }
    }];
}

#pragma mark - Initialize -

- (NSMutableArray<NSMutableArray *> *)allResult {
    if (!_allResult) {
        _allResult = [NSMutableArray array];
    }
    return _allResult;
}

- (NSMutableArray<PHAssetCollection *> *)allSmartAlbums {
    if (!_allSmartAlbums) {
        _allSmartAlbums = [NSMutableArray array];
    }
    return _allSmartAlbums;
}

- (NSMutableArray<PHAssetCollection *> *)allUserAlbums {
    if (!_allUserAlbums) {
        _allUserAlbums = [NSMutableArray array];
    }
    return _allUserAlbums;
}

- (NSMutableDictionary<NSIndexPath *,UIImage *> *)allCacheImage {
    if (!_allCacheImage) {
        _allCacheImage = [NSMutableDictionary dictionary];
    }
    return _allCacheImage;
}

- (NSMutableDictionary<NSIndexPath *,PHFetchResult *> *)allCacheFetchResult {
    if (!_allCacheFetchResult) {
        _allCacheFetchResult = [NSMutableDictionary dictionary];
    }
    return _allCacheFetchResult;
}

- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[PHCachingImageManager alloc] init];
        _imageManager.allowsCachingHighQualityImages = NO;
    }
    return _imageManager;
}

- (NSOperationQueue *)changeQueue {
    if (!_changeQueue) {
        _changeQueue = [[NSOperationQueue alloc] init];
    }
    return _changeQueue;
}

@end
