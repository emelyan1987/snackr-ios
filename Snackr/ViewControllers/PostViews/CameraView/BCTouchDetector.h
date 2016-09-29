//
//  BCTouchDetector.h
//  BirdCage
//
//  Created by Brendan Zhou on 6/08/2014.
//  Copyright (c) 2014 Bizar Mobile Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCTouchDetector : UIGestureRecognizer

@property (nonatomic) int counter;
@property (nonatomic) NSTimer *timer;

@end
