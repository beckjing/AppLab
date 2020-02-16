//
//  NASReverseVideoViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 2/26/18.
//  Copyright © 2018 nanosparrow.com. All rights reserved.
//

#import "NASReverseVideoViewController.h"
#import "NASImagePickerCoordinator.h"
#import "NASReverseVideoManager.h"


@interface NASReverseVideoViewController ()
<
NASImagePickerCoordinatorDelegate
>

@property (nonatomic, strong) NASImagePickerCoordinator *imagePickerCoordinator;
@property (nonatomic, strong) NASReverseVideoManager *reverseVideoManager;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation NASReverseVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {
    [super setupUI];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)clickImportButton:(UIButton *)sender {
    
    [self.imagePickerCoordinator start];
    
}

- (NASImagePickerCoordinator *)imagePickerCoordinator {
    if (!_imagePickerCoordinator) {
        _imagePickerCoordinator = [[NASImagePickerCoordinator alloc] initWithNavigationController:self.navigationController];
        _imagePickerCoordinator.imagePickerShowType  = NASImagePickerShowType_Push;
        _imagePickerCoordinator.imagePickerCloseType = NASImagePickerDidSelectCloseType_Close;
        _imagePickerCoordinator.delegate = self;
    }
    return _imagePickerCoordinator;
}



- (BOOL)canHandleAsset:(PHAsset *)asset {
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        return YES;
    }
    return NO;
}

- (void)didSelectAsset:(PHAsset *)asset {
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        self.reverseVideoManager = [[NASReverseVideoManager alloc] initWithAsset:asset];
        [self.reverseVideoManager reverseVideoByAVFoundationWithProgressBlock:nil
                                                                  finishBlock:^(BOOL isSuccess, NSError *error) {
                                                                      [self.progressHUD hideAnimated:YES];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressHUD hideAnimated:YES];
            self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.progressHUD.mode = MBProgressHUDModeDeterminate;
            self.progressHUD.progressObject = self.reverseVideoManager.totalProgress;
        });
    }];
}

@end
