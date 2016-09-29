//
//  CameraViewController.h
//  Snackr
//
//  Created by Snackr on 8/23/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"
#import "FXBlurView.h"

#define kMinVideoLength 5
#define kMaxVideoLength 15
#define kMaxProfileVideoLength 120

static NSString * const kAVYAviaryAPIKey = @"j8q6p8efaolydstk";
static NSString * const kAVYAviarySecret = @"kk4fd7pglcnrgbpd";

@interface CameraViewController : UIViewController <SCRecorderDelegate>
{
    NSString *_mediaPath;
}

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *realFocousView;
@property (weak, nonatomic) IBOutlet UIButton *pickPhotoBtn;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollControlView;
@property (weak, nonatomic) IBOutlet UIButton *flashModeButton;

@property (weak, nonatomic) IBOutlet UIImageView *PreImageView;

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *retakeBtn;

@property (weak, nonatomic) IBOutlet UIButton *pickBtn;
@property (weak, nonatomic) IBOutlet UIButton *captureBtn;

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIButton *flashBtn;

@end
