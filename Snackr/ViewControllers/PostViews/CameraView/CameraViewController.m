//
//  CameraViewController.m
//  Snackr
//
//  Created by Snackr on 8/23/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "CameraViewController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "BCTouchDetector.h"
#import "BCRecordSessionManager.h"
//#import "BCVideoPlayerController.h"
#import "UIImage+Resize.h"
#import "BCGridView.h"
#import "BCAlertView+Block.h"
#import "BCVideoPickerController.h"
#import "SCRecorderToolsView.h"
#import "SCRecorder.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+Toast.h"
#import <ImageIO/ImageIO.h>
#import "TWPhotoPickerController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
//#import <AviarySDK/AviarySDK.h>

#import "LocationSearchViewController.h"

#define kVideoPreset AVCaptureSessionPreset640x480
#define kPhotoPreset AVCaptureSessionPresetHigh
#define kMaximumPhoto 1
#define kPhotoWidth 320

@interface CameraViewController () <UIScrollViewDelegate/*, AVYPhotoEditorControllerDelegate*/>
{
    SCRecorder* _recorder;
    UIImage* _photo;
    SCRecordSession* _recordSession;
}

@property (strong, nonatomic) SCRecorderToolsView* focusView;
//@property (strong, nonatomic) YLProgressBar* recordProgressBar;
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) UIView *segmentSeparatorContainerView;

@end

@implementation CameraViewController

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#endif

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _recorder = [SCRecorder recorder];
    _recorder.maxRecordDuration = CMTimeMake(15, 1);
    _recorder.autoSetVideoOrientation = YES;
    _recorder.captureSessionPreset = AVCaptureSessionPresetPhoto;
    //_recorder.device = AVCaptureDevicePositionFront;
   
    // Listen to the messages SCRecorder can send
    _recorder.delegate = self;
    _recorder.videoZoomFactor = 4;
    
    SCVideoConfiguration* video = _recorder.videoConfiguration;
    video.sizeAsSquare = YES;
    video.enabled = YES;
    video.bitrate = 2000000; // 2Mbit/s
    video.size = CGSizeMake(1280, 720);
    video.scalingMode = AVVideoScalingModeResizeAspect;
    video.timeScale = 1;
    video.filter = [SCFilter filterWithCIFilterName:@"CIPhotoEffectInstant"];
    
    
    
    
    UIView* previewView = self.previewView;
    _recorder.previewView = previewView;
    
    _recorder.previewLayer.frame = previewView.bounds;
    _recorder.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [previewView.layer addSublayer: _recorder.previewLayer];
    

    self.focusView = [[SCRecorderToolsView alloc] initWithFrame:self.previewView.bounds];
    self.focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.focusView.recorder = _recorder;
    [previewView addSubview:self.focusView];
    
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"CAMFocus"];
    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"CAMFocus"];
    
    
    
     // ScrollView for switch Camera/Photo Mode
    self.scrollControlView.contentSize = CGSizeMake(self.scrollControlView.frame.size.width * 2,
                                                    self.scrollControlView.frame.size.height);
    
    [self.pickPhotoBtn addTarget:self action:@selector(presentSourcePicker:) forControlEvents:UIControlEventTouchUpInside];
    
    [self getMostRecentThumbnail];
    
    
    // Start the Aviary Editor OpenGL Load
    //[AVYOpenGLManager beginOpenGLLoad];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
}

- (void) setPhotoEditorCustomizationOptions
{
    // Set API Key and Secret
    //[AVYPhotoEditorController setAPIKey:kAVYAviaryAPIKey secret:kAVYAviarySecret];
    
    // Set Tool Order
    /*NSArray *toolOrder = @[kAVYEnhance,
                           kAVYEffects,
                           kAVYFocus,
                           kAVYFrames,
                           kAVYStickers,
                           kAVYOrientation,
                           kAVYCrop,
                           kAVYColorAdjust,
                           kAVYLightingAdjust,
                           kAVYSplash,
                           kAVYDraw,
                           kAVYText,
                           kAVYRedeye,
                           kAVYWhiten,
                           kAVYBlemish,
                           kAVYMeme];
    [AVYPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set Custom Crop Sizes
    [AVYPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AVYPhotoEditorCustomization setCropToolCustomEnabled:YES];
    NSDictionary *fourBySix = @{kAVYCropPresetHeight : @4.0f,
                                kAVYCropPresetWidth : @6.0f};
    NSDictionary *fiveBySeven = @{kAVYCropPresetHeight : @5.0f,
                                  kAVYCropPresetWidth : @7.0f};
    NSDictionary *square = @{kAVYCropPresetName: @"Square",
                             kAVYCropPresetHeight : @1.0f,
                             kAVYCropPresetWidth : @1.0f};
    
    [AVYPhotoEditorCustomization setCropToolPresets:@[fourBySix,
                                                      fiveBySeven,
                                                      square]];
    
    // Set Supported Orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray *supportedOrientations = @[@(UIInterfaceOrientationPortrait),
                                           @(UIInterfaceOrientationPortraitUpsideDown),
                                           @(UIInterfaceOrientationLandscapeLeft),
                                           @(UIInterfaceOrientationLandscapeRight)];
        [AVYPhotoEditorCustomization setSupportedIpadOrientations:supportedOrientations];
    }*/
}

/*- (void)photoEditor:(AVYPhotoEditorController *)editor finishedWithImage:(UIImage *)image {
    //[self.navigationController popViewControllerAnimated:NO];
    //[editor dismissViewControllerAnimated:NO completion:^{
    
        LocationSearchViewController *locSearchView = [self.storyboard instantiateViewControllerWithIdentifier:@"locationSearchView"];
        locSearchView.food_photo = image;
        [self.navigationController pushViewController:locSearchView animated:YES];
    //}];
}

- (void)photoEditorCanceled:(AVYPhotoEditorController *)editor {
    //[editor dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}*/



- (void)recorder:(SCRecorder*)recorder didReconfigureAudioInput:(NSError*)audioInputError
{
    NSLog(@"Reconfigured audio input: %@", audioInputError);
}

- (void)recorder:(SCRecorder*)recorder didReconfigureVideoInput:(NSError*)videoInputError
{
    NSLog(@"Reconfigured video input: %@", videoInputError);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_recorder startRunning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_recorder stopRunning];
}

// Focus
- (void)recorderDidStartFocus:(SCRecorder*)recorder
{
    [self.focusView showFocusAnimation];
}

- (void)recorderDidEndFocus:(SCRecorder*)recorder
{
    [self.focusView hideFocusAnimation];
}

- (void)recorderWillStartFocus:(SCRecorder*)recorder
{
    [self.focusView showFocusAnimation];
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)presentSourcePicker:(id)sender
{
    if ([_recorder.captureSessionPreset isEqualToString:kPhotoPreset]) {
        TWPhotoPickerController* photoPicker = [[TWPhotoPickerController alloc] init];
        photoPicker.cropBlock = ^(UIImage* image) {
            
            [self showPhoto:image];
        };
        [self presentViewController:photoPicker animated:YES completion:NULL];
    }
    else if (_recordSession.segments.count > 0) {
    }
    else {
    }
}

- (void)getMostRecentThumbnail
{
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                      usingBlock:^(ALAssetsGroup* group, BOOL* stop) {
                                          if (nil != group) {
                                              // be sure to filter the group so you only get photos
                                              if ([_recorder.captureSessionPreset isEqualToString:kPhotoPreset]) {
                                                  [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                              } else {
                                                  [group setAssetsFilter:[ALAssetsFilter allVideos]];
                                              }
                                              
                                              if (group.numberOfAssets > 0) {
                                                  [group
                                                   enumerateAssetsAtIndexes:
                                                   [NSIndexSet indexSetWithIndex:group.numberOfAssets - 1]
                                                   options:0
                                                   usingBlock:^(ALAsset *result, NSUInteger index,
                                                                BOOL *stop) {
                                                       if (nil != result) {
                                                           if ([_recorder.captureSessionPreset
                                                                isEqualToString:kPhotoPreset]) {
                                                               [self.pickPhotoBtn setBackgroundImage:[UIImage imageWithCGImage:[result thumbnail]] forState:UIControlStateNormal];
                                                           }
                                                           
                                                           // we only need the first (most recent)
                                                           // photo -- stop the enumeration
                                                           *stop = YES;
                                                       }
                                                   }];
                                              }
                                          }
                                          
                                          *stop = NO;
                                      }
                                    failureBlock:^(NSError* error) { NSLog(@"error: %@", error);
                                        
                                    }];
}

- (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)message
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)handleReverseCameraTapped:(id)sender
{
    [_recorder switchCaptureDevices];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finishSession:(SCRecordSession*)recordSession
{
    [[BCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
    _recordSession = recordSession;
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (!error) {
        [self getMostRecentThumbnail];
    }
    else {
        NSLog(@"Saving failed :(");
    }
}

- (void)showPhoto:(UIImage*)photo
{
    _photo = [self squareImageFromImage:photo scaledToSize:kPhotoWidth];
    
    self.previewView.hidden = YES;
    self.PreImageView.hidden = NO;
    
    self.flashBtn.hidden = YES;
    self.pickPhotoBtn.hidden = YES;
    self.captureBtn.hidden = YES;
    self.captureBtn.enabled = NO;
    self.commentLabel.hidden = YES;
    
    self.confirmBtn.hidden = NO;
    self.retakeBtn.hidden = NO;
    
    self.PreImageView.image = _photo;
}

- (UIImage*)squareImageFromImage:(UIImage*)image
                    scaledToSize:(CGFloat)newSize
{
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    }
    else {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    }
    else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (IBAction)onTakePicture:(id)sender {

    [_recorder capturePhoto:^(NSError* error, UIImage* image) {
        if (image != nil) {
            [self showPhoto:image];
            self.scrollControlView.scrollEnabled = NO;
        } else {
            [self showAlertViewWithTitle:@"Failed to capture photo"
                                 message:error.localizedDescription];
        }
    }];
    
    /*_mediaPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"media.jpg"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *imgData = UIImageJPEGRepresentation(_photo, 1);
        NSError *error = nil;
        [imgData writeToFile:_mediaPath options:NSDataWritingAtomic error:&error];
        [self goToEditController];
        if (error) {
            NSLog(@"error writing : %@", error);
        }
        
    });*/
}


- (IBAction)switchFlash:(id)sender
{
    NSString* flashModeString = nil;
    switch (_recorder.flashMode) {
        case SCFlashModeOff:
            flashModeString = @"On";
            _recorder.flashMode = SCFlashModeLight;
            break;
        case SCFlashModeLight:
            flashModeString = @"Off";
            _recorder.flashMode = SCFlashModeOff;
            break;
        default:
            break;
    }
}

- (IBAction)closeCam:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [_recorder stopRunning];
}

- (IBAction)onRetake:(id)sender {
    self.previewView.hidden = NO;
    self.PreImageView.hidden = YES;
    
    self.flashBtn.hidden = NO;
    //self.pickPhotoBtn.hidden = NO;
    self.captureBtn.hidden = NO;
    self.captureBtn.enabled = YES;
    self.commentLabel.hidden = NO;
    
    self.confirmBtn.hidden = YES;
    self.retakeBtn.hidden = YES;
}

- (IBAction)onConfirm:(id)sender {
    
    _mediaPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"media.jpg"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        /*NSData *imgData = UIImageJPEGRepresentation(_photo, 1);
        NSError *error = nil;
        [imgData writeToFile:_mediaPath options:NSDataWritingAtomic error:&error];
        [self goToEditController];
        
        if (error) {
            NSLog(@"error writing : %@", error);
        }*/
        
        LocationSearchViewController *locSearchView = [self.storyboard instantiateViewControllerWithIdentifier:@"locationSearchView"];
        locSearchView.food_photo = _photo;
        [self.navigationController pushViewController:locSearchView animated:YES];
        
    });
    
    //UIImage *image = [UIImage imageWithContentsOfFile:_mediaPath];
    /*LocationSearchViewController *locSearchView = [self.storyboard instantiateViewControllerWithIdentifier:@"locationSearchView"];
    locSearchView.food_photo = _photo;
    [self.navigationController pushViewController:locSearchView animated:YES];*/
}

- (void) goToEditController {
    /*AVYPhotoEditorController * photoEditor = [[AVYPhotoEditorController alloc] initWithImage:[UIImage imageWithContentsOfFile:_mediaPath]];
    [photoEditor setDelegate:self];
    [AVYPhotoEditorCustomization setRightNavigationBarButtonTitle:kAVYRightNavigationTitlePresetNext];
    //[self presentViewController:photoEditor animated:NO completion:nil];
    [self.navigationController pushViewController:photoEditor animated:YES];
    
    //[self onRetake:nil];*/
}

- (void)prepareCamera
{
    if (_recorder.session == nil) {
        
        SCRecordSession* session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        
        _recorder.session = session;
    }
}

- (void)recorder:(SCRecorder*)recorder didCompleteRecordSession:(SCRecordSession*)recordSession
{
    [self finishSession:recordSession];
}

- (void)recorder:(SCRecorder*)recorder didInitializeAudioInRecordSession:(SCRecordSession*)recordSession
           error:(NSError*)error
{
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    }
    else {
        NSLog(@"Failed to initialize audio in record session: %@",
              error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder*)recorder didInitializeVideoInRecordSession:(SCRecordSession*)recordSession
           error:(NSError*)error
{
    if (error == nil) {
        NSLog(@"Initialized video in record session");
    }
    else {
        NSLog(@"Failed to initialize video in record session: %@",
              error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder*)recorder didBeginRecordSegment:(SCRecordSession*)recordSession
           error:(NSError*)error
{
    NSLog(@"Began record segment: %@", error);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    
}

#pragma mark - Lazy loaded properties
-(ALAssetsLibrary *) assetsLibrary{
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

-(UIView *) segmentSeparatorContainerView{
    if(_segmentSeparatorContainerView == nil){
        [_segmentSeparatorContainerView setBackgroundColor:[UIColor clearColor]];
    }
    return _segmentSeparatorContainerView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
