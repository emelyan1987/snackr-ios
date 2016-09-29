//
//  EnterEmailViewController.h
//  Snackr
//
//  Created by Matko Lajbaher on 9/25/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnterEmailViewController : UIViewController

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (assign, nonatomic) BOOL isRestaurant;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@end
