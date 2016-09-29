//
//  BCVideoPlayerController.m
//  BirdCage
//
//  Created by Brendan Zhou on 6/08/2014.
//  Copyright (c) 2014 Bizar Mobile Pty Ltd. All rights reserved.
//

#import "BCVideoPlayerController.h"
#import "SCAssetExportSession.h"
//#import "BCProductDetailViewController.h"

#define kPreviewSize CGSizeMake(640, 640)
#define kThumbSize CGSizeMake(75, 75)

@interface BCVideoPlayerController () {
    AVAssetImageGenerator* imageGenerator;
    UIImage* coverImage;
    BOOL createdThumbnail;
}

@end

@implementation BCVideoPlayerController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.videoPlayerView.player pause];
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Preview";
    
    self.videoPlayerView.tapToPauseEnabled = YES;
    self.videoPlayerView.player.loopEnabled = YES;
    [self.videoPlayerView.player setItemByAsset:_recordSession.assetRepresentingSegments];
    [self.videoPlayerView.player play];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(saveAndEditProduct)];
    
    [self getAllImagesFromVideo];
    [self.imageSlider setMinimumTrackImage:[UIImage new]
                                  forState:UIControlStateNormal];
    [self.imageSlider setMaximumTrackImage:[UIImage new]
                                  forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveAndEditProduct
{
    if (coverImage == nil) {
        return;
    }
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    void (^completionHandler)(NSURL * outputUrl, NSError * error) = ^(NSURL* outputUrl, NSError* error) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if (error == nil) {
//            BCProductDetailViewController *productDetailVC = [[BCProductDetailViewController alloc]init];
//            productDetailVC.mediaImage = coverImage;
//            productDetailVC.mediaPath = _recordSession.outputUrl;
//            
//            [self.navigationController pushViewController:productDetailVC animated:YES];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Failed to save"
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    };
    
    //[self.recordSession mergeRecordSegmentsUsingPreset:AVAssetExportPresetHighestQuality completionHandler:completionHandler];
}

- (void)getAllImagesFromVideo
{
    self.previewView.hidden = YES;
    imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:_recordSession.assetRepresentingSegments];
    imageGenerator.appliesPreferredTrackTransform = TRUE;
    imageGenerator.maximumSize = kPreviewSize;
    
    CGFloat x = 0;
    int time = (CMTimeGetSeconds(_recordSession.assetRepresentingSegments.duration) >= 5 ? CMTimeGetSeconds(_recordSession.assetRepresentingSegments.duration) : 5);
    for (Float64 i = 0; i < time; i += 0.5) // For 25 fps in 15 sec of Video
    {
        CGImageRef imgRef = [imageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(i, 60) actualTime:NULL error:NULL];
        UIImage* thumbnail = [UIImage imageWithCGImage:imgRef];
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 10, self.thumbnailsView.frame.size.width / (time * 2), self.thumbnailsView.frame.size.height - 5)];
        imageView.image = thumbnail;
        if (x == 0) {
            coverImage = thumbnail;
            self.previewView.image = thumbnail;
            [self.view bringSubviewToFront:self.previewView];
            
            UIImage* image = thumbnail;
            image = [self imageWithImage:image scaledToSize:kThumbSize];
            image = [self imageWithBorderFromImage:image];
            [self.imageSlider setThumbImage:image
                                   forState:UIControlStateNormal];
        }
        x += self.thumbnailsView.frame.size.width / (time * 2);
        [self.thumbnailsView addSubview:imageView];
    }
    
    UIView *coverView = [[UIView alloc]initWithFrame:CGRectMake(self.thumbnailsView.frame.origin.x, self.thumbnailsView.frame.origin.y + 10, self.thumbnailsView.frame.size.width, self.thumbnailsView.frame.size.height - 5)];
    coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [self.view insertSubview:coverView aboveSubview:self.thumbnailsView];
}

- (void)getImageAtTime:(CMTime)time
{
    [imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:time]] completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError* error) {
        if (result == AVAssetImageGeneratorSucceeded) {
            coverImage = [UIImage imageWithCGImage:image];
        }
    }];
    
    self.previewView.image = coverImage;
    
    UIImage* thumbImage = coverImage;
    thumbImage = [self imageWithImage:thumbImage scaledToSize:kThumbSize];
    thumbImage = [self imageWithBorderFromImage:thumbImage];
    [self.imageSlider setThumbImage:thumbImage
                           forState:UIControlStateNormal];
}

- (UIImage*)imageWithBorderFromImage:(UIImage*)source;
{
    CGSize size = [source size];
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [source drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 4.0);
    CGContextSetRGBStrokeColor(context, 0.15, 0.67, 0.89, 1.0);
    CGContextStrokeRect(context, rect);
    UIImage *testImg =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return testImg;
}

- (IBAction)chooseThumbnail:(id)sender
{
    if ([self.chooseThumbnailBtn.titleLabel.text isEqualToString:@"Use it as Cover Frame"]) {
        self.previewView.hidden = YES;
    }
}

- (IBAction)moveSlider:(UISlider*)sender
{
    float position = sender.value;
    CMTime currentTime = CMTimeMakeWithSeconds(position * CMTimeGetSeconds(_recordSession.assetRepresentingSegments.duration), 60);
    [self getImageAtTime:currentTime];
    self.previewView.hidden = NO;
}

#pragma mark ImageResize
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
