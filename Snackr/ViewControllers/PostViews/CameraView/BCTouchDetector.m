//
//  BCTouchDetector.m
//  BirdCage
//
//  Created by Brendan Zhou on 6/08/2014.
//  Copyright (c) 2014 Bizar Mobile Pty Ltd. All rights reserved.
//

#import "BCTouchDetector.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation BCTouchDetector

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled) {
        self.counter = 0;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(incrementCounter)
                                       userInfo:nil
                                        repeats:YES];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled) {
        [self.timer invalidate];
        self.state = UIGestureRecognizerStateEnded;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled) {
        [self.timer invalidate];
        self.State = UIGestureRecognizerStateEnded;
    }
}

- (void)incrementCounter {
    self.counter++;
    if (self.counter > 0) {
        [self.timer invalidate];
        self.state = UIGestureRecognizerStateBegan;
    }
}

@end
