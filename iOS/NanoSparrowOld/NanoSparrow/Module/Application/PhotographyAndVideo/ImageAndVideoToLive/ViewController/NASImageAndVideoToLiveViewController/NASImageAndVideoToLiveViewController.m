//
//  NASImageAndVideoToLiveViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 12/11/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASImageAndVideoToLiveViewController.h"
#import "NASImageAndVideoToLiveManager.h"
#import "NASImagePickerCoordinator.h"
#import "NASHeader.h"

@interface NASImageAndVideoToLiveViewController ()
<
NASImagePickerCoordinatorDelegate
>

@property (weak,   nonatomic) IBOutlet UIButton *importImageButton;
@property (weak,   nonatomic) IBOutlet UIButton *importVideoButton;
@property (weak,   nonatomic) IBOutlet UIButton *convertButton;
@property (strong, nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) AVAsset *selectedVideo;
@property (strong, nonatomic) NASImagePickerCoordinator *imagePickerCoordinator;
@property (assign, nonatomic) BOOL isSelectImage;
@property (strong, nonatomic) NASImageAndVideoToLiveManager *transferManager;
@property (strong, nonatomic) MBProgressHUD *toastView;

@end

@implementation NASImageAndVideoToLiveViewController

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
    [super setupUI];
}

- (void)configureNavigationBar {
    
}


- (IBAction)clickImportImageButton:(UIButton *)sender {
    self.isSelectImage = YES;
    self.convertButton.enabled = YES;
    [self.imagePickerCoordinator start];
}

- (IBAction)clickImportVideoButton:(UIButton *)sender {
    self.isSelectImage = NO;
    self.convertButton.enabled = YES;
    [self.imagePickerCoordinator start];
}

- (IBAction)clickConvertButton:(UIButton *)sender {
    if (self.selectedImage && self.selectedVideo) {
        sender.enabled = NO;
        self.transferManager = [[NASImageAndVideoToLiveManager alloc] initWithImage:self.selectedImage videoAsset:self.selectedVideo];
        @weakify(self)
        self.toastView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.toastView.label.text = NSLocalizedStringFromTable(@"Exporting", @"VideoFunction", @"Exporting");
        [self.transferManager transferWithCompletionBlock:^(BOOL isSuccess, NSError *error) {
            @strongify(self)
            if (self) {
                if (isSuccess && !error) {
                    self.toastView.label.text = NSLocalizedStringFromTable(@"ExportSuccess", @"VideoFunction", @"ExportSuccess");
                    [self.toastView hideAnimated:YES afterDelay:1.0];
                }
                else {
                    self.toastView.label.text = NSLocalizedStringFromTable(@"ExportFailed", @"VideoFunction", @"ExportFailed ");
                    [self.toastView hideAnimated:YES afterDelay:1.0];
                    self.convertButton.enabled = YES;
                }
            }
        }];
    }
}

- (BOOL)canHandleAsset:(PHAsset *)asset {
    if (self.isSelectImage) {//图片
        return asset.mediaType == PHAssetMediaTypeImage;
    }
    else {//视频
        return asset.mediaType == PHAssetMediaTypeVideo;
    }
}

- (void)didSelectAsset:(PHAsset *)asset {
    if (self.isSelectImage) {//图片
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            self.selectedImage = result;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.importImageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
                [self.importImageButton setImage:result forState:UIControlStateNormal];
            });
        }];
    }
    else {//视频
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            self.selectedVideo = asset;
            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            CGImageRef assetCGImage = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:nil error:nil];
            UIImage *assetImage = [UIImage imageWithCGImage:assetCGImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.importVideoButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
                [self.importVideoButton setImage:assetImage forState:UIControlStateNormal];
            });
        }];
    }
}

- (NASImagePickerCoordinator *)imagePickerCoordinator {
    if (!_imagePickerCoordinator) {
        _imagePickerCoordinator = [[NASImagePickerCoordinator alloc] initWithNavigationController:self.navigationController];
        _imagePickerCoordinator.imagePickerCloseType = NASImagePickerDidSelectCloseType_Close;
        _imagePickerCoordinator.delegate = self;
    }
    return _imagePickerCoordinator;
}


@end
