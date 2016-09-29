//
//  BCVideoPickerController.m
//  BirdCage
//
//  Created by Brendan Zhou on 2/02/2015.
//  Copyright (c) 2015 Bizar Mobile Pty Ltd. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"
#import "BCVideoPickerController.h"
#import "BCVideoCollectionViewCell.h"
#import "BCVideoScrollView.h"
#import "SAVideoRangeSlider.h"
#import "CameraViewController.h"
#import "UIView+Toast.h"

@interface BCVideoPickerController () <UICollectionViewDataSource, UICollectionViewDelegate, SAVideoRangeSliderDelegate> {
    CGFloat beginOriginY;
    UIView* dragView;
    NSString* tmpVideoPath;
    AVAsset* selectedAsset;
    NSURL *videoUrl;
}
@property (strong, nonatomic) UIView* topView;
@property (strong, nonatomic) UIImageView* maskView;
@property (strong, nonatomic) BCVideoScrollView* imageScrollView;

@property (strong, nonatomic) NSMutableArray* assets;
@property (strong, nonatomic) ALAssetsLibrary* assetsLibrary;
@property (strong, nonatomic) UICollectionView* collectionView;

@property (strong, nonatomic) AVAssetExportSession* exportSession;
@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat stopTime;
@end

@implementation BCVideoPickerController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.topView];
    [self.view insertSubview:self.collectionView belowSubview:self.topView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadPhotos];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishCrop:)
                                                 name:kExportDidFinishNotification
                                               object:nil];
    
    NSString* tempDir = NSTemporaryDirectory();
    tmpVideoPath = [tempDir stringByAppendingPathComponent:@"tmpMov.mp4"];
}

- (NSMutableArray*)assets
{
    if (_assets == nil) {
        _assets = [[NSMutableArray alloc] init];
    }
    return _assets;
}

- (ALAssetsLibrary*)assetsLibrary
{
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (void)loadPhotos
{
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset* result, NSUInteger index, BOOL* stop) {
        
        if (result) {
            [self.assets insertObject:result atIndex:0];
        }
        
    };
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup* group, BOOL* stop) {
        
        ALAssetsFilter *onlyVideosFilter = [ALAssetsFilter allVideos];
        [group setAssetsFilter:onlyVideosFilter];
        if ([group numberOfAssets] > 0)
        {
            if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
            }
        }
        
        if (group == nil) {
            if (self.assets.count) {
                ALAsset * asset = [self.assets objectAtIndex:0];
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                NSURL *url = [representation url];
                AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
                [self.imageScrollView displayVideo:avAsset];
                [self addTrimmer:avAsset];
            }
            [self.collectionView reloadData];
        }
        
    };
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:listGroupBlock failureBlock:^(NSError* error) {
        NSLog(@"Load Photos Error: %@", error);
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIView*)topView
{
    if (_topView == nil) {
        CGFloat handleHeight = 44.0f;
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) + handleHeight * 2);
        self.topView = [[UIView alloc] initWithFrame:rect];
        self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.topView.backgroundColor = [UIColor clearColor];
        self.topView.clipsToBounds = YES;
        
        rect = CGRectMake(0, 0, CGRectGetWidth(self.topView.bounds), handleHeight);
        UIView* navView = [[UIView alloc] initWithFrame:rect]; //26 29 33
        navView.backgroundColor = [[UIColor colorWithRed:26.0 / 255 green:29.0 / 255 blue:33.0 / 255 alpha:1] colorWithAlphaComponent:.8f];
        [self.topView addSubview:navView];
        
        rect = CGRectMake(-15, 0, 60, CGRectGetHeight(navView.bounds));
        UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = rect;
        [backBtn setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:backBtn];
        
        rect = CGRectMake((CGRectGetWidth(navView.bounds) - 100) / 2, 0, 100, CGRectGetHeight(navView.bounds));
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:rect];
        titleLabel.text = @"SELECT";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [navView addSubview:titleLabel];
        
        rect = CGRectMake(CGRectGetWidth(navView.bounds) - 80, 0, 80, CGRectGetHeight(navView.bounds));
        UIButton* cropBtn = [[UIButton alloc] initWithFrame:rect];
        [cropBtn setTitle:@"OK" forState:UIControlStateNormal];
        [cropBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [cropBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [cropBtn addTarget:self action:@selector(cropAction) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:cropBtn];
        
        rect = CGRectMake(0, CGRectGetHeight(self.topView.bounds) - handleHeight *2, CGRectGetWidth(self.topView.bounds), handleHeight * 2);
        dragView = [[UIView alloc] initWithFrame:rect];
        dragView.backgroundColor = navView.backgroundColor;
        dragView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.topView addSubview:dragView];

        
        CGRect collectionViewFrame = self.collectionView.frame;
        self.collectionView.frame = CGRectMake(collectionViewFrame.origin.x, CGRectGetMaxY(dragView.frame), collectionViewFrame.size.width, collectionViewFrame.size.height);
        
        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [dragView addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [dragView addGestureRecognizer:tapGesture];
        
        [tapGesture requireGestureRecognizerToFail:panGesture];
        
        rect = CGRectMake(0, handleHeight, CGRectGetWidth(self.topView.bounds), CGRectGetHeight(self.topView.bounds) - handleHeight * 2);
        self.imageScrollView = [[BCVideoScrollView alloc] initWithFrame:rect];
        [self.topView addSubview:self.imageScrollView];
        [self.topView sendSubviewToBack:self.imageScrollView];
        
        self.maskView = [[UIImageView alloc] initWithFrame:rect];
        self.maskView.image = [UIImage imageNamed:@"straighten-grid"];
        [self.topView insertSubview:self.maskView aboveSubview:self.imageScrollView];
    }
    return _topView;
}

- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        CGFloat colum = 4.0, spacing = 2.0;
        CGFloat value = floorf((CGRectGetWidth(self.view.bounds) - (colum - 1) * spacing) / colum);
        
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(value, value);
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumInteritemSpacing = spacing;
        layout.minimumLineSpacing = spacing;
        
        CGRect rect = CGRectMake(0, CGRectGetMaxY(self.topView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.topView.bounds));
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        
        [_collectionView registerClass:[BCVideoCollectionViewCell class] forCellWithReuseIdentifier:@"TWPhotoCollectionViewCell"];
    }
    return _collectionView;
}

- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cropAction
{
    float duration = self.stopTime != 0 ? (self.stopTime - self.startTime) : CMTimeGetSeconds(selectedAsset.duration);
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (delegate.isCropForProfile) {
        if ((kMinVideoLength <= duration && duration <= kMaxProfileVideoLength)) {
            [self.view makeToastActivity];
            [self.imageScrollView capture];
        }
        else {
            [self.view makeToast:[NSString stringWithFormat:@"Video must be at least %d seconds and not longer than %d seconds", kMinVideoLength, kMaxProfileVideoLength]];
        }
    } else {
        if ((kMinVideoLength <= duration && duration <= kMaxVideoLength)) {
            [self.view makeToastActivity];
            [self.imageScrollView capture];
        }
        else {
            [self.view makeToast:[NSString stringWithFormat:@"Video must be at least %d seconds and not longer than %d seconds", kMinVideoLength, kMaxVideoLength]];
        }
    }
    
}

- (void)didFinishCrop:(NSNotification*)notification
{
    SCRecordSession* session = [notification object];
    if (self.cropBlock) {
        
        NSURL *fileURL = [session.segments firstObject];
        NSFileManager* fm = [NSFileManager defaultManager];
        BOOL exist = [fm fileExistsAtPath:fileURL.path];
        NSLog(@"%@", exist ? @"exist" : @"not exist");
        
        self.cropBlock(session);
        
        
    }
    [self backAction];
}

- (void)addTrimmer:(AVAsset*)asset
{
    selectedAsset = asset;
    SAVideoRangeSlider* trimVideoSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(0, 0, dragView.bounds.size.width, 44.0f) videoAsset:asset];
    trimVideoSlider.bubleText.font = [UIFont systemFontOfSize:12];
    [trimVideoSlider setPopoverBubbleSize:120 height:60];
    trimVideoSlider.delegate = self;
    [dragView addSubview:trimVideoSlider];
    
    UIImage* img = [UIImage imageNamed:@"cameraroll-picker-grip"];
//    CGRect rect = CGRectMake(CGRectGetWidth(dragView.bounds) - img.size.width - 3, (CGRectGetHeight(dragView.bounds) - img.size.height) / 2, img.size.width, img.size.height);
    CGRect rect = CGRectMake(0.0f, CGRectGetMaxY(trimVideoSlider.frame), dragView.bounds.size.width, dragView.bounds.size.height - trimVideoSlider.frame.size.height);
    UIImageView* gripView = [[UIImageView alloc] initWithFrame:rect];
    gripView.image = img;
    gripView.contentMode = UIViewContentModeCenter;
    [dragView addSubview:gripView];
    
}

- (void)panGestureAction:(UIPanGestureRecognizer*)panGesture
{
    switch (panGesture.state) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            CGRect topFrame = self.topView.frame;
            CGFloat endOriginY = self.topView.frame.origin.y;
            if (endOriginY > beginOriginY) {
                topFrame.origin.y = (endOriginY - beginOriginY) >= 20 ? 0 : -(CGRectGetHeight(self.topView.bounds) - 20 - 44);
            }
            else if (endOriginY < beginOriginY) {
                topFrame.origin.y = (beginOriginY - endOriginY) >= 20 ? -(CGRectGetHeight(self.topView.bounds) - 20 - 44) : 0;
            }
            
            CGRect collectionFrame = self.collectionView.frame;
            collectionFrame.origin.y = CGRectGetMaxY(topFrame);
            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
            [UIView animateWithDuration:.3f animations:^{
                self.topView.frame = topFrame;
                self.collectionView.frame = collectionFrame;
            }];
            break;
        }
        case UIGestureRecognizerStateBegan: {
            beginOriginY = self.topView.frame.origin.y;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGesture translationInView:self.view];
            CGRect topFrame = self.topView.frame;
            topFrame.origin.y = translation.y + beginOriginY;
            
            CGRect collectionFrame = self.collectionView.frame;
            collectionFrame.origin.y = CGRectGetMaxY(topFrame);
            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
            
            if (topFrame.origin.y <= 0 && (topFrame.origin.y >= -(CGRectGetHeight(self.topView.bounds) - 20 - 44))) {
                self.topView.frame = topFrame;
                self.collectionView.frame = collectionFrame;
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer*)tapGesture
{
    CGRect topFrame = self.topView.frame;
    topFrame.origin.y = topFrame.origin.y == 0 ? -(CGRectGetHeight(self.topView.bounds) - 20 - 44) : 0;
    
    CGRect collectionFrame = self.collectionView.frame;
    collectionFrame.origin.y = CGRectGetMaxY(topFrame);
    collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
    [UIView animateWithDuration:.3f animations:^{
        self.topView.frame = topFrame;
        self.collectionView.frame = collectionFrame;
    }];
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"TWPhotoCollectionViewCell";
    
    BCVideoCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageWithCGImage:[[self.assets objectAtIndex:indexPath.row] thumbnail]];
    
    return cell;
}

#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    ALAsset* asset = [self.assets objectAtIndex:indexPath.row];
    ALAssetRepresentation* representation = [asset defaultRepresentation];
    NSURL* url = [representation url];
    AVAsset* avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    [self.imageScrollView displayVideo:avAsset];
    [dragView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addTrimmer:avAsset];
    if (self.topView.frame.origin.y != 0) {
        [self tapGestureAction:nil];
    }
}

- (void)collectionView:(UICollectionView*)collectionView didDeselectItemAtIndexPath:(NSIndexPath*)indexPath
{
}

- (void)scrollViewWillEndDragging:(UIScrollView*)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint*)targetContentOffset
{
    NSLog(@"velocity:%f", velocity.y);
    if (velocity.y >= 2.0 && self.topView.frame.origin.y == 0) {
        [self tapGestureAction:nil];
    }
}

#pragma mark - SAVideoRangeSliderDelegate

- (void)videoRange:(SAVideoRangeSlider*)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    self.startTime = leftPosition;
    self.stopTime = rightPosition;
}

- (void)videoRange:(SAVideoRangeSlider*)videoRange didGestureStateEndedLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    float duration = rightPosition - leftPosition;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (delegate.isCropForProfile) {
        if (kMinVideoLength <= duration && duration <= kMaxProfileVideoLength) {
            [self showTrimmedVideo];
        }
        else {
            [self.view makeToast:[NSString stringWithFormat:@"Video must be at least %d seconds and not longer than %d seconds", kMinVideoLength, kMaxProfileVideoLength]];
        }
    } else {
        if (kMinVideoLength <= duration && duration <= kMaxVideoLength) {
            [self showTrimmedVideo];
        }
        else {
            [self.view makeToast:[NSString stringWithFormat:@"Video must be at least %d seconds and not longer than %d seconds", kMinVideoLength, kMaxVideoLength]];
        }
    }
}

- (void)deleteTmpFile
{
    NSURL* url = [NSURL fileURLWithPath:tmpVideoPath];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError* err;
    if (exist) {
        [fm removeItemAtURL:url
                      error:&err];
        if (err) {
            NSLog(@"file remove error, %@", err.localizedDescription);
        }
    }
    else {
        NSLog(@"no file by that name");
    }
}

- (void)showTrimmedVideo
{
    [self deleteTmpFile];
    
    NSArray* compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:selectedAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        
        self.exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:selectedAsset
                              presetName:AVAssetExportPresetPassthrough];
        // Implementation continues.
        
        NSURL* furl = [NSURL fileURLWithPath:tmpVideoPath];
        videoUrl = furl;  //
        self.exportSession.outputURL = furl;
        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        
        CMTime start = CMTimeMakeWithSeconds(self.startTime, selectedAsset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(self.stopTime - self.startTime, selectedAsset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        self.exportSession.timeRange = range;
        
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([self.exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.imageScrollView displayVideo:[AVURLAsset URLAssetWithURL:furl options:nil]];
                    });
                    
                    break;
            }
        }];
    }
}

@end
