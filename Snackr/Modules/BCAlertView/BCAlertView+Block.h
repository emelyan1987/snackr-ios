//
//  BCAlertView+Block.h
//  BirdCage
//
//  Created by Brendan Zhou on 20/10/2014.
//  Copyright (c) 2014 Bizar Mobile Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Block)

- (void)showWithCompletion:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completion;

@end
