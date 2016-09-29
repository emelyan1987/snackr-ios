//
//  BCVideoPlayerController.h
//  BirdCage
//
//  Created by Brendan Zhou on 6/08/2014.
//  Copyright (c) 2014 Bizar Mobile Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCVideoPlayerView.h"
#import "SCRecorder.h"

@interface BCVideoPlayerController : UIViewController<SCPlayerDelegate>

@property (nonatomic, strong) SCRecordSession *recordSession;
@property (nonatomic, strong) IBOutlet SCVideoPlayerView *videoPlayerView;
@property (weak, nonatomic) IBOutlet UIView *thumbnailsView;
@property (weak, nonatomic) IBOutlet UIButton *chooseThumbnailBtn;
@property (weak, nonatomic) IBOutlet UISlider *imageSlider;
@property (weak, nonatomic) IBOutlet UIImageView *previewView;

@end
