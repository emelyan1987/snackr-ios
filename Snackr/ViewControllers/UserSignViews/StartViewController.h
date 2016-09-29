//
//  StartViewController.h
//  Snackr
//
//  Created by Snackr on 8/11/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StartViewController : UIViewController  <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *signupBtn;
@property (weak, nonatomic) IBOutlet UIButton *signinBtn;
@property (weak, nonatomic) IBOutlet UIImageView *triangleImg;

@property (weak, nonatomic) IBOutlet UIImageView *swipeImg;
@property (weak, nonatomic) IBOutlet UILabel *swipeComment;

@property (weak, nonatomic) IBOutlet UIView *signupView;
@property (weak, nonatomic) IBOutlet UIView *signinView;

@property (strong, nonatomic) IBOutlet UIView *parentView;

- (IBAction)facebookSignupBtnClicked:(id)sender;
- (IBAction)facebookLoginBtnClicked:(id)sender;
- (IBAction)twitterSignupBtnClicked:(id)sender;
- (IBAction)twitterLoginBtnClicked:(id)sender;

@end
