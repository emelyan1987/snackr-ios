//
//  AlertManager.m
//  Snackr
//
//  Created by Matko Lajbaher on 9/7/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "AlertManager.h"
#import <UIKit/UIKit.h>

@implementation AlertManager
+(void)showErrorMessage:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    
    
    /*ShareReferralCodeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"shareReferralCodeView"];
     KGModal *kgm = [KGModal sharedInstance];
     vc.delegate = kgm;
     kgm.delegateShareRefferralCode = vc;
     [[KGModal sharedInstance] showWithContentViewController:vc andAnimated:YES];*/
}
+(void) showSuccessMessage:(NSString*)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                    message:msg?msg:@"Submit completed!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
+(void) showInfoMessage:(NSString*)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                    message:msg?msg:@"Infomation"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
