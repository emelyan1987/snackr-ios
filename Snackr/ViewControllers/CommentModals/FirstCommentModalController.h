//
//  FirstCommentModalController.h
//  Snackr
//
//  Created by Snackr on 8/19/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FirstCommentModalDelegate <NSObject>

- (void) firstCommentClose;

@end

@interface FirstCommentModalController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (nonatomic, strong) id<FirstCommentModalDelegate> delegate;

@end
