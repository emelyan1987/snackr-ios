//
//  TWPhotoPickerController.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "TWPhotoPickerController.h"
#import "AssetsGroupViewController.h"
#import "AssetsGroupViewCell.h"
#import "TWImageScrollView.h"
#import "GroupViewController.h"

@interface TWPhotoPickerController () {
    CGFloat beginOriginY;
}
@property (strong, nonatomic) UIView* topView;
@property (strong, nonatomic) UIImageView* maskView;
@property (strong, nonatomic) TWImageScrollView* imageScrollView;

@property (strong, nonatomic) UINavigationController* childNaviVC;
@end

@implementation TWPhotoPickerController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.topView];
    
    AssetsGroupViewController* assetsGroupVC = [[AssetsGroupViewController alloc] initWithStyle:UITableViewStylePlain];
    _childNaviVC = [[UINavigationController alloc] initWithRootViewController:assetsGroupVC];
    _childNaviVC.navigationBarHidden = YES;
    [self addChildViewController:_childNaviVC];
    [_childNaviVC didMoveToParentViewController:self];
    CGRect rect = CGRectMake(0, CGRectGetMaxY(self.topView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.topView.bounds));
    _childNaviVC.view.frame = rect;
    [self.view insertSubview:_childNaviVC.view belowSubview:self.topView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayPhoto:)
                                                 name:kDidSelectPhotoNotification
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)displayPhoto:(NSNotification*)notification
{
    UIImage* image = [notification object];
    [self.imageScrollView displayImage:image];
    if (self.topView.frame.origin.y != 0) {
        [self tapGestureAction:nil];
    }
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
        
        rect = CGRectMake(5, 0, 60, CGRectGetHeight(navView.bounds));
        UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = rect;
        
        UIFont *font = [UIFont fontWithName:@"MuseoSans-500" size:13.0f];
        //[backBtn setImage:[UIImage imageNamed:@"back_arrow.png"] forState:UIControlStateNormal];
        [backBtn setTitle:@"CANCEL" forState:UIControlStateNormal];
        [backBtn.titleLabel setFont:font];
        [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
        
        rect = CGRectMake(CGRectGetWidth(navView.bounds) - 40, 0, 40, CGRectGetHeight(navView.bounds));
        UIButton* cropBtn = [[UIButton alloc] initWithFrame:rect];
        [cropBtn setTitle:@"OK" forState:UIControlStateNormal];
        [cropBtn.titleLabel setFont:font];
        [cropBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [cropBtn addTarget:self action:@selector(cropAction) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:cropBtn];
        
        rect = CGRectMake(0, CGRectGetHeight(self.topView.bounds) - handleHeight, CGRectGetWidth(self.topView.bounds), handleHeight);
        UIView* dragView = [[UIView alloc] initWithFrame:rect];
        dragView.backgroundColor = navView.backgroundColor;
        dragView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.topView addSubview:dragView];
        
        UIImage* img = [UIImage imageNamed:@"cameraroll-picker-grip.png"];
        rect = CGRectMake((CGRectGetWidth(dragView.bounds) - img.size.width) / 2, (CGRectGetHeight(dragView.bounds) - img.size.height) / 2, img.size.width, img.size.height);
        UIImageView* gripView = [[UIImageView alloc] initWithFrame:rect];
        gripView.image = img;
        [dragView addSubview:gripView];
        
        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [dragView addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [dragView addGestureRecognizer:tapGesture];
        
        [tapGesture requireGestureRecognizerToFail:panGesture];
        
        rect = CGRectMake(0, handleHeight, CGRectGetWidth(self.topView.bounds), CGRectGetHeight(self.topView.bounds) - handleHeight * 2);
        self.imageScrollView = [[TWImageScrollView alloc] initWithFrame:rect];
        [self.topView addSubview:self.imageScrollView];
        [self.topView sendSubviewToBack:self.imageScrollView];
        
        self.maskView = [[UIImageView alloc] initWithFrame:rect];
        
        self.maskView.image = [UIImage imageNamed:@"straighten-grid.png"];
        [self.topView insertSubview:self.maskView aboveSubview:self.imageScrollView];
    }
    return _topView;
}

- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cropAction
{
    if (self.cropBlock) {
        self.cropBlock(self.imageScrollView.capture);
    }
    [self backAction];
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
            
            CGRect collectionFrame = self.childNaviVC.view.frame;
            collectionFrame.origin.y = CGRectGetMaxY(topFrame);
            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
            [UIView animateWithDuration:.3f animations:^{
                self.topView.frame = topFrame;
                self.childNaviVC.view.frame = collectionFrame;
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
            
            CGRect collectionFrame = self.childNaviVC.view.frame;
            collectionFrame.origin.y = CGRectGetMaxY(topFrame);
            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
            
            if (topFrame.origin.y <= 0 && (topFrame.origin.y >= -(CGRectGetHeight(self.topView.bounds) - 20 - 44))) {
                self.topView.frame = topFrame;
                self.childNaviVC.view.frame = collectionFrame;
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
    
    CGRect collectionFrame = self.childNaviVC.view.frame;
    collectionFrame.origin.y = CGRectGetMaxY(topFrame);
    collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
    [UIView animateWithDuration:.3f animations:^{
        self.topView.frame = topFrame;
        self.childNaviVC.view.frame = collectionFrame;
    }];
}

- (void)scrollViewWillEndDragging:(UIScrollView*)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint*)targetContentOffset
{
    NSLog(@"velocity:%f", velocity.y);
    if (velocity.y >= 2.0 && self.topView.frame.origin.y == 0) {
        [self tapGestureAction:nil];
    }
}

@end
