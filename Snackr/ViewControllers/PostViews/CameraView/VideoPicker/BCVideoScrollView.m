//
//  BCVideoScrollView.m
//  BirdCage
//
//  Created by Brendan Zhou on 2/02/2015.
//  Copyright (c) 2015 Bizar Mobile Pty Ltd. All rights reserved.
//

#import "BCVideoScrollView.h"

@interface BCVideoScrollView () <UIScrollViewDelegate> {
    AVPlayer* player;
}

@property (strong, nonatomic) UIView* playerView;
@property (strong, nonatomic) AVAsset* selectedAsset;
@end

@implementation BCVideoScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = YES;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
    }
    return self;
}

- (void)capture
{
    //create an avassetrack with our asset
    AVAssetTrack* clipVideoTrack = [[self.selectedAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //create a video composition and preset some settings
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    //here we are setting its render size to its height x height (Square)
    videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height);
    
    //create a video instruction
    AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30));
    
    //Create an Export Path to store the cropped video
    NSString* exportPath = [NSTemporaryDirectory() stringByAppendingString:@"CroppedVideo.mp4"];
    NSURL* exportUrl = [NSURL fileURLWithPath:exportPath];
    
    //Remove any prevouis videos at that path
    [[NSFileManager defaultManager] removeItemAtURL:exportUrl error:nil];
    
    CGPoint point = CGPointZero;
    if ([self getVideoOrientationFromAsset:self.selectedAsset] == UIImageOrientationUp || [self getVideoOrientationFromAsset:self.selectedAsset] == UIImageOrientationDown) {
        point = CGPointMake(0, (self.contentOffset.y/self.contentSize.height)*clipVideoTrack.naturalSize.width);
    } else {
        point = CGPointMake((self.contentOffset.x/self.contentSize.width)*clipVideoTrack.naturalSize.width, 0);
    }
    
    //Export
    [self applyCropToVideoWithAsset:self.selectedAsset AtRect:CGRectMake(point.x, point.y, videoComposition.renderSize.width, videoComposition.renderSize.height) OnTimeRange:instruction.timeRange ExportToUrl:exportUrl ExistingExportSession:nil WithCompletion:^(BOOL success, NSError* error, NSURL* videoUrl) {
        NSLog(@"%@",videoUrl);
    }];
}

- (void)displayVideo:(AVAsset*)asset
{
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    self.selectedAsset = asset;
    CGSize size = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize];
    if ([self getVideoOrientationFromAsset:asset] == UIImageOrientationUp || [self getVideoOrientationFromAsset:asset] == UIImageOrientationDown) {
        self.playerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, size.width / (size.height / self.frame.size.height))];
        
    } else {
        self.playerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width / (size.height / self.frame.size.height), self.frame.size.height)];
    }
    AVPlayerItem* item = [[AVPlayerItem alloc] initWithAsset:asset];
    player = [[AVPlayer alloc] initWithPlayerItem:item];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:player.currentItem];
    AVPlayerLayer* layer = [[AVPlayerLayer alloc] init];
    layer.frame = self.playerView.frame;
    layer.player = player;
    [player play];
    [self.playerView.layer addSublayer:layer];
    [self addSubview:self.playerView];
    
    [self configureForImageSize:self.playerView.frame.size];
}

- (void)playerItemDidReachEnd:(NSNotification*)notification
{
    AVPlayerItem* p = [notification object];
    [p seekToTime:kCMTimeZero];
    [player play];
}

- (void)configureForImageSize:(CGSize)imageSize
{
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    self.minimumZoomScale = 1.0;
    self.maximumZoomScale = 1.0;
}

- (UIImageOrientation)getVideoOrientationFromAsset:(AVAsset*)asset
{
    AVAssetTrack* videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIImageOrientationLeft; //return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIImageOrientationRight; //return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIImageOrientationDown; //return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIImageOrientationUp; //return UIInterfaceOrientationPortrait;
}

// apply the crop to passed video asset (set outputUrl to avoid the saving on disk ). Return the exporter session object
- (AVAssetExportSession*)applyCropToVideoWithAsset:(AVAsset*)asset AtRect:(CGRect)cropRect OnTimeRange:(CMTimeRange)cropTimeRange ExportToUrl:(NSURL*)outputUrl ExistingExportSession:(AVAssetExportSession*)exporter WithCompletion:(void (^)(BOOL success, NSError* error, NSURL* videoUrl))completion
{
    
    //create an avassetrack with our asset
    AVAssetTrack* clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //create a video composition and preset some settings
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    CGFloat cropOffX = cropRect.origin.x;
    CGFloat cropOffY = cropRect.origin.y;
    CGFloat cropWidth = cropRect.size.width;
    CGFloat cropHeight = cropRect.size.height;
    
    videoComposition.renderSize = CGSizeMake(cropWidth, cropHeight);
    
    //create a video instruction
    AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = cropTimeRange;
    
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    
    UIImageOrientation videoOrientation = [self getVideoOrientationFromAsset:asset];
    
    CGAffineTransform t1 = CGAffineTransformIdentity;
    CGAffineTransform t2 = CGAffineTransformIdentity;
    
    switch (videoOrientation) {
        case UIImageOrientationUp:
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height - cropOffX, 0 - cropOffY);
            t2 = CGAffineTransformRotate(t1, M_PI_2);
            break;
        case UIImageOrientationDown:
            t1 = CGAffineTransformMakeTranslation(0 - cropOffX, clipVideoTrack.naturalSize.width - cropOffY); // not fixed width is the real height in upside down
            t2 = CGAffineTransformRotate(t1, -M_PI_2);
            break;
        case UIImageOrientationRight:
            t1 = CGAffineTransformMakeTranslation(0 - cropOffX, 0 - cropOffY);
            t2 = CGAffineTransformRotate(t1, 0);
            break;
        case UIImageOrientationLeft:
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.width - cropOffX, clipVideoTrack.naturalSize.height - cropOffY);
            t2 = CGAffineTransformRotate(t1, M_PI);
            break;
        default:
            NSLog(@"no supported orientation has been found in this video");
            break;
    }
    
    CGAffineTransform finalTransform = t2;
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    
    //add the transformer layer instructions, then add to video composition
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject:instruction];
    
    //Remove any prevouis videos at that path
    [[NSFileManager defaultManager] removeItemAtURL:outputUrl error:nil];
    
    if (!exporter) {
        exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    }
    
    // assign all instruction for the video processing (in this case the transformation for cropping the video
    exporter.videoComposition = videoComposition;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.outputFileType = AVFileTypeMPEG4;
    
    if (outputUrl) {
        
        exporter.outputURL = outputUrl;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exporter status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"crop Export failed: %@", [[exporter error] localizedDescription]);
                    if (completion){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(NO,[exporter error],nil);
                        });
                        return;
                    }
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"crop Export canceled");
                    if (completion){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(NO,nil,nil);
                        });
                        return;
                    }
                    break;
                default:
                    break;
            }
            
            if (completion){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES,nil,outputUrl);
                    [self exportDidFinish:exporter];
                });
            }
        }];
    }
    
    return exporter;
}

- (void)exportDidFinish:(AVAssetExportSession*)session
{
    //Play the New Cropped video
    NSURL* outputURL = session.outputURL;
    SCRecordSession* newSession = [SCRecordSession recordSession];
    [newSession removeAllSegments];
    [newSession addSegment:outputURL];
    newSession.fileType = AVFileTypeMPEG4;
    [[NSNotificationCenter defaultCenter]postNotificationName:kExportDidFinishNotification object:newSession];
}

#pragma mark - UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView
{
    return self.playerView;
}

@end
