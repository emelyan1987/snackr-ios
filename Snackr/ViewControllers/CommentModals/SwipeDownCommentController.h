//
//  SwipeDownCommentController.h
//  Snackr
//
//  Created by Snackr on 8/19/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwipeDownCommentDelegate <NSObject>

- (void) onCancel;
- (void) onDone;

@end


@interface SwipeDownCommentController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *undoBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;

@property (nonatomic, strong) id<SwipeDownCommentDelegate> delegate;

@end
