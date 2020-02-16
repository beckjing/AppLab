//
//  NASVideoResizeAndRotateViewController.m
//  NanoSparrow
//
//  Created by yuecheng on 12/15/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASVideoResizeAndRotateViewController.h"
#import "NASCropVideoFrameManager.h"
#import "NASVideoPlayer.h"

@interface NASVideoResizeAndRotateViewController ()
<
UIScrollViewDelegate
>

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIView *selectAreaView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *rotateButton;
@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UIScrollView *videoSelectScrollView;
@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) UIView *previewView;
@property (strong, nonatomic) GPUImageView *previewImageView;
@property (strong, nonatomic) GPUImageMovie *previewMovie;
@property (strong, nonatomic) AVPlayerItem *previewPlayerItem;
@property (strong, nonatomic) NASVideoPlayer *previewPlayer;
@property (strong, nonatomic) NASCropVideoFrameModel *videoFrameModel;
@property (assign, nonatomic) CGFloat left;
@property (assign, nonatomic) CGFloat top;
@property (strong, nonatomic) NASCropVideoFrameManager *cropManager;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

@end

@implementation NASVideoResizeAndRotateViewController

- (void)dealloc {
    [self.previewMovie removeAllTargets];
}

- (instancetype)initWithAsset:(AVAsset *)asset model:(NASCropVideoFrameModel *)model {
    self = [super init];
    if (self) {
        _asset = asset;
        _videoFrameModel = model;
    }
    return self;
}

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
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.cancelButton.hidden  = NO;
    self.rotateButton.hidden  = NO;
    self.confirmButton.hidden = NO;
}

- (void)setupRAC {
    RACSignal *aspectRatioSignal = RACObserve(self, videoFrameModel.videoSettingModel.aspectRatioType);
    RACSignal *containViewBoundsSignal = RACObserve(self, containerView.bounds);
    RACSignal *transfromTimesSignal = RACObserve(self, videoFrameModel.transformTimes);
    
    @weakify(self);
    [[[aspectRatioSignal skip:1] distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self) {
            [self refreshUI];
        }
    }];
    
    [[[containViewBoundsSignal skip:1] distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self) {
            [self refreshUI];
        }
    }];
    
    [[[transfromTimesSignal skip:1] distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self) {
            [self refreshUI];
        }
    }];
    
}

- (void)refreshUI {
    [self.videoFrameModel refreshFrameModel];
    [self updateSelectAreaViewConstraints];
    [self updateVideoPreviewView];
    [self updateVideoSelectScrollViewContentInset];
    [self addTargetToPreviewView];
}

- (void)configureNavigationBar {
    UIBarButtonItem *changeResolutionButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"AspectRatio", @"VideoFunction", @"AspectRatio") style:UIBarButtonItemStylePlain target:self action:@selector(clickChangeResolutionButton:)];
    self.navigationItem.rightBarButtonItem = changeResolutionButton;
}

- (void)updateSelectAreaViewConstraints {
    CGSize aspectRatio = [self aspectRatioWithType:self.videoFrameModel.videoSettingModel.aspectRatioType];
    [self.selectAreaView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.containerView);
        make.width.equalTo(self.containerView.mas_width).multipliedBy(aspectRatio.width);
        make.height.equalTo(self.containerView.mas_width).multipliedBy(aspectRatio.height);
    }];
    [self.containerView layoutIfNeeded];
}

- (CGSize)aspectRatioWithType:(NASVideoAspectRatioType)type {
    CGFloat widthRatio  = 0.0;
    CGFloat heightRatio = 0.0;
    switch (type) {
        case NASVideoAspectRatioType_1_1:{
            widthRatio  = 0.8;
            heightRatio = 0.8;
            break;
        }
        case NASVideoAspectRatioType_4_3:{
            widthRatio  = 0.8;
            heightRatio = 0.6;
            break;
        }
        case NASVideoAspectRatioType_3_4:{
            widthRatio  = 0.72;
            heightRatio = 0.96;
            break;
        }
        case NASVideoAspectRatioType_16_9:{
            widthRatio  = 0.8;
            heightRatio = 0.45;
            break;
        }
        case NASVideoAspectRatioType_9_16:{
            widthRatio  = 0.72;
            heightRatio = 1.28;
            break;
        }
        default:{
            break;
        }
    }
    return CGSizeMake(widthRatio, heightRatio);
}

- (void)updateVideoSelectScrollViewContentInset {

    self.left = self.selectAreaView.frame.origin.x;
    self.top  = self.selectAreaView.frame.origin.y;
    self.videoSelectScrollView.contentInset = UIEdgeInsetsMake(self.top,
                                                               self.left,
                                                               self.top,
                                                               self.left);
    CGFloat contentOffsetX = self.videoFrameModel.leftRate * self.videoSelectScrollView.contentSize.width - self.left;
    CGFloat contentOffsetY = self.videoFrameModel.topRate * self.videoSelectScrollView.contentSize.height - self.top;
    self.videoSelectScrollView.contentOffset = CGPointMake(contentOffsetX, contentOffsetY);
}

- (void)updateVideoPreviewView {
    self.videoSelectScrollView.zoomScale = 1.0f;
    CGSize contentSize = [self.videoFrameModel displaySize];
    if ((contentSize.width / contentSize.height) > (self.selectAreaView.frame.size.width / self.selectAreaView.frame.size.height)) {//底边长
        self.previewView.frame = CGRectMake(0,
                                            0,
                                            self.selectAreaView.frame.size.height * contentSize.width / contentSize.height,
                                            self.selectAreaView.frame.size.height);
    }
    else {//竖边长
        self.previewView.frame = CGRectMake(0,
                                            0,
                                            self.selectAreaView.frame.size.width,
                                            self.selectAreaView.frame.size.width * contentSize.height / contentSize.width);
    }
    self.previewImageView.layer.affineTransform = [self.videoFrameModel actualTransform];
    self.previewImageView.frame = self.previewView.bounds;
    self.videoSelectScrollView.contentSize = self.previewView.frame.size;
}

- (void)addTargetToPreviewView {
    [self.previewPlayer stopLoopPlay];
    [self.previewMovie endProcessing];
    [self.previewMovie removeAllTargets];
    [self.previewMovie addTarget:self.previewImageView];
    [self.previewMovie startProcessing];
    [self.previewPlayer playRepeat:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.containerView bringSubviewToFront:self.selectAreaView];
    [self.containerView sendSubviewToBack:self.videoSelectScrollView];
    
    [self.view layoutIfNeeded];
}

#pragma mark - Button Event -

- (void)clickChangeResolutionButton:(UIBarButtonItem *)barButton {
    UIAlertController *changeResolutionActionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"ChangeAspectRatio", @"VideoFunction", @"ChangeAspectRatio") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSInteger i = 0; i < NASVideoAspectRatioType_None; i++) {
        __block NASVideoAspectRatioType aspectRatioType = (NASVideoAspectRatioType)i;
        UIAlertAction *aspectRatioAction = [UIAlertAction actionWithTitle:[NASVideoSettingModel descriptionOfAspectRatioType:aspectRatioType] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.videoFrameModel.videoSettingModel.aspectRatioType = aspectRatioType;
        }];
        [changeResolutionActionSheet addAction:aspectRatioAction];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Operation.cancel", @"Common", @"Cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    [changeResolutionActionSheet addAction:cancelAction];
    [self.navigationController presentViewController:changeResolutionActionSheet animated:YES completion:^{
        
    }];
}

- (void)clickCancelButton:(UIButton *)cancelButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickRotateButton:(UIButton *)rotateButton {
    self.videoFrameModel.transformTimes += 1;
}

- (void)clickConfirmButton:(UIButton *)confirmButton {
    [self.previewPlayer stopLoopPlay];
    self.cropManager = [[NASCropVideoFrameManager alloc] initWithAsset:self.asset model:self.videoFrameModel];
    [self.progressHUD hideAnimated:NO];
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHUD.mode = MBProgressHUDModeDeterminate;
    self.progressHUD.progressObject = self.cropManager.totalProgress;
    @weakify(self)
    [self.cropManager cropWithProgressBlock:nil
                                finishBlock:^(BOOL isSuccess, NSError *error) {
        @strongify(self)
        if (self) {
            [self.progressHUD hideAnimated:YES];
        }
    }];
}

- (void)doubleClickScrollView:(UITapGestureRecognizer *)tapGesture {
    
    if (self.videoSelectScrollView.zoomScale == 1.0f) {
        [self.videoSelectScrollView setZoomScale:2.0f animated:YES];
    }
    else {
        [self.videoSelectScrollView setZoomScale:1.0f animated:YES];
    }
    
}

#pragma mark - UIScrollViewDelegate -

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.previewView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    if (scrollView.isDragging) {
        [self updateCutModelWithScrollview:scrollView];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCutModelWithScrollview:scrollView];
}

- (void)updateCutModelWithScrollview:(UIScrollView *)scrollView {
    
    self.videoFrameModel.leftRate   = (scrollView.contentOffset.x + self.left)  / scrollView.contentSize.width;
    self.videoFrameModel.topRate    = (scrollView.contentOffset.y + self.top)   / scrollView.contentSize.height;
    self.videoFrameModel.widthRate  = self.selectAreaView.frame.size.width      / scrollView.contentSize.width;
    self.videoFrameModel.heightRate = self.selectAreaView.frame.size.height     / scrollView.contentSize.height;
}

#pragma mark - Initialize -

- (NASCropVideoFrameModel *)videoFrameModel {
    if (!_videoFrameModel) {
        _videoFrameModel = [[NASCropVideoFrameModel alloc] initWithAsset:self.asset settingModel:nil];
    }
    return _videoFrameModel;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        [self.view addSubview:_containerView];
        [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.left.bottom.right.equalTo(self.view);
        }];
    }
    return _containerView;
}

- (UIView *)selectAreaView {
    if (!_selectAreaView) {
        _selectAreaView = [[UIView alloc] init];
        _selectAreaView.userInteractionEnabled = NO;
        _selectAreaView.layer.borderWidth = 2.0f;
        _selectAreaView.layer.borderColor = [UIColor blackColor].CGColor;
        _selectAreaView.layer.shadowColor = [UIColor whiteColor].CGColor;
        _selectAreaView.layer.shadowRadius = 2.0f;
        _selectAreaView.layer.shadowOffset = CGSizeMake(0, 0);
        _selectAreaView.layer.shadowOpacity = 0.5f;
        [self.containerView addSubview:_selectAreaView];
    }
    return _selectAreaView;
}

- (UIScrollView *)videoSelectScrollView {
    if (!_videoSelectScrollView) {
        _videoSelectScrollView = [[UIScrollView alloc] init];
        _videoSelectScrollView.backgroundColor = [UIColor whiteColor];
        _videoSelectScrollView.delegate = self;
        _videoSelectScrollView.minimumZoomScale = 1.0f;
        _videoSelectScrollView.maximumZoomScale = 3.0f;
        _videoSelectScrollView.bouncesZoom = NO;
        _videoSelectScrollView.scrollEnabled = YES;
        _videoSelectScrollView.bounces = NO;
        _videoSelectScrollView.showsVerticalScrollIndicator = NO;
        _videoSelectScrollView.showsHorizontalScrollIndicator = NO;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClickScrollView:)];
        tapGesture.numberOfTapsRequired = 2;
        [self.containerView addSubview:_videoSelectScrollView];
        [_videoSelectScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.containerView);
        }];
    }
    return _videoSelectScrollView;
}

- (UIView *)previewView {
    if (!_previewView) {
        _previewView = [[UIView alloc] init];
        [self.videoSelectScrollView addSubview:_previewView];
    }
    return _previewView;
}


- (GPUImageView *)previewImageView {
    if (!_previewImageView) {
        _previewImageView = [[GPUImageView alloc] init];
        [self.previewView addSubview:_previewImageView];
    }
    return _previewImageView;
}

- (GPUImageMovie *)previewMovie {
    if (!_previewMovie) {
        _previewMovie = [[GPUImageMovie alloc] initWithPlayerItem:self.previewPlayerItem];
    }
    return _previewMovie;
}

- (AVPlayerItem *)previewPlayerItem {
    if (!_previewPlayerItem) {
        _previewPlayerItem = [[AVPlayerItem alloc] initWithAsset:self.asset];
    }
    return _previewPlayerItem;
}

- (NASVideoPlayer *)previewPlayer {
    if (!_previewPlayer) {
        _previewPlayer = [[NASVideoPlayer alloc] initWithPlayerItem:self.previewPlayerItem];
    }
    return _previewPlayer;
}


- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:NSLocalizedStringFromTable(@"Operation.cancel", @"Common", @"Cancel")
                       forState:UIControlStateNormal];
        [_cancelButton addTarget:self
                          action:@selector(clickCancelButton:)
                forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:_cancelButton];
        [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(self.containerView);
            make.right.equalTo(self.rotateButton.mas_left);
            make.width.equalTo(self.rotateButton);
        }];
    }
    return _cancelButton;
}

- (UIButton *)rotateButton {
    if (!_rotateButton) {
        _rotateButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_rotateButton setTitle:NSLocalizedStringFromTable(@"Operation.rotate", @"Common", @"Rotate")
                       forState:UIControlStateNormal];
        [_rotateButton addTarget:self
                          action:@selector(clickRotateButton:)
                forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:_rotateButton];
        [_rotateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.containerView);
            make.left.equalTo(self.cancelButton.mas_right);
            make.right.equalTo(self.confirmButton.mas_left);
            make.width.equalTo(self.confirmButton);
        }];
    }
    return _rotateButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_confirmButton setTitle:NSLocalizedStringFromTable(@"Operation.confirm", @"Common", @"Confirm")
                        forState:UIControlStateNormal];
        [_confirmButton addTarget:self
                           action:@selector(clickConfirmButton:)
                 forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:_confirmButton];
        [_confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.rotateButton.mas_right);
            make.bottom.right.equalTo(self.containerView);
        }];
    }
    return _confirmButton;
}

@end
