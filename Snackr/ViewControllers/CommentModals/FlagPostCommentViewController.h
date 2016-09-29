//
//  FlagPostCommentViewController.h
//  Snackr
//
//  Created by Matko Lajbaher on 9/29/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FlagPostCommentDelegate <NSObject>

- (void) onCancel;
- (void) onDone;

@end
@interface FlagPostCommentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (nonatomic, strong) id<FlagPostCommentDelegate> delegate;
@end
