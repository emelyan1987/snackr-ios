//
//  EmailSignupViewController.h
//  Snackr
//
//  Created by Snackr on 8/11/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailSignupViewController : UIViewController <UITextFieldDelegate>

@property (assign, nonatomic) BOOL isRestaurant;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;
@end
