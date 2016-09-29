//
//  UIDragButton.h
//  BirdCage
//
//  Created by lion on 13/05/15.
//  Copyright (c) 2015 Bizar Mobile Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/////////////////////////////////////////////

@class BCDragButton;

@protocol BCDragButtonDelegate <NSObject>

- (void)setPreviewButtonsFrameWithAnimate:(BOOL)_bool withoutZoomingButton:(BCDragButton *)ZoomingButton;
- (void)checkLocationOfOthersWithButton:(BCDragButton *)ZoomingButton;
- (void)arrangeImagesWithButton:(BCDragButton *)dragButton;

@end

@interface BCDragButton : UIButton {
    UIView *superView;
    CGPoint lastPoint;
    NSTimer *timer;
}

@property (nonatomic, assign) CGPoint lastCenter;
@property (nonatomic, assign) id<BCDragButtonDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image inView:(UIView *)view;

@end