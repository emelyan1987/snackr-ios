//
//  EnterZipCodeViewController.h
//  Snackr
//
//  Created by Snackr on 8/21/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnterZipCodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *textFieldZipCode;
- (IBAction)changedUsePhoneLocation:(id)sender;

@end
