//
//  UIDragButton.m
//  BirdCage
//
//  Created by lion on 13/05/15.
//  Copyright (c) 2015 Bizar Mobile Pty Ltd. All rights reserved.
//

#import "BCDragButton.h"

@implementation BCDragButton
@synthesize delegate;
@synthesize lastCenter;

- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image inView:(UIView *)view
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lastCenter = CGPointMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2);
        superView = view;
        [self setImage:image forState:UIControlStateNormal];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
        longPress.minimumPressDuration = 0.4;
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void)drag:(UILongPressGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:superView];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            [self setAlpha:0.7];
            lastPoint = point;
            [self.layer setShadowColor:[UIColor grayColor].CGColor];
            [self.layer setShadowOpacity:1.0f];
            [self.layer setShadowRadius:10.0f];
            [superView bringSubviewToFront:self];
            [self startZoom];
            break;
        case UIGestureRecognizerStateChanged:
        {
            float offX = point.x - lastPoint.x;
            float offY = point.y - lastPoint.y;
            [self setCenter:CGPointMake(self.center.x + offX, self.center.y + offY)];
            
            lastPoint = point;
            [delegate checkLocationOfOthersWithButton:self];
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self stopZoom];
            [self setAlpha:1];
            
            [UIView animateWithDuration:0.5 animations:^{
                
                [self setFrame:CGRectMake(lastCenter.x - 28, lastCenter.y - 28, 57, 57)];
                
            } completion:^(BOOL finished) {
                [self.layer setShadowOpacity:0];
                [delegate arrangeImagesWithButton:self];
            }];
            
            break;
        }
        case UIGestureRecognizerStateCancelled:
            [self stopZoom];
            [self setAlpha:1];
            break;
        case UIGestureRecognizerStateFailed:
            [self stopZoom];
            [self setAlpha:1];
            break;
        default:
            break;
    }
}

- (void)startZoom
{
    CABasicAnimation *zoomAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    zoomAnimation.duration = 0.2;
    zoomAnimation.autoreverses = NO;
    zoomAnimation.repeatCount = 1;
    zoomAnimation.additive = YES;
    zoomAnimation.removedOnCompletion = NO;
    zoomAnimation.fillMode = kCAFillModeForwards;
    zoomAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    zoomAnimation.toValue = [NSNumber numberWithFloat:0.22];
    [self.layer addAnimation:zoomAnimation forKey:@"Zoom"];
}

- (void)stopZoom
{
    [self.layer removeAnimationForKey:@"Zoom"];
}

@end