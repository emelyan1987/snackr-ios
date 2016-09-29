//
//  SignUpRestaurantViewController.m
//  Snackr
//
//  Created by Snackr on 8/12/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "SignUpRestaurantViewController.h"
#import "EmailSignupViewController.h"


#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <TwitterKit/TwitterKit.h>

#import "AFNetworking.h"
#import "AlertManager.h"
#import "BackEndManager.h"
#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import "EnterEmailViewController.h"
#import "MBProgressHUD.h"
#import "KGModal.h"
#import "ConfigManager.h"
#import "HomeRootViewController.h"
#import "FirstCommentModalController.h"


@interface SignUpRestaurantViewController ()

{
    MBProgressHUD *HUD;
}
@end

@implementation SignUpRestaurantViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setHeaderView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void) setHeaderView
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backBtn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    UILabel *title = [[UILabel alloc]init];
    [title setFont:[UIFont fontWithName:@"MuseoSans-100" size:16.0f]];
    title.text = @"RESTAURANT SIGN UP";
    title.textColor = [UIColor colorWithRed:(44.0f/255.0f) green:(44.0f/255.0f) blue:(44.0f/255.0f) alpha:1.0f];
    
    float maximumLabelSize =  [title.text boundingRectWithSize:title.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:title.font } context:nil].size.width;
    
    title.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:title];
    
    self.navigationItem.titleView = headerview;
}

- (void) onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSignup:(id)sender
{
    EmailSignupViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"email_singupView"];
    vc.isRestaurant = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)facebookSignupBtn:(id)sender {
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Set the hud to display with a color
    
    HUD.color = [UIColor colorWithRed:222.0f/255.0f green:0 blue:35.0f/255.0f alpha:0.90];
    HUD.labelText = @"Please wait...";
    HUD.dimBackground = YES;
    
    [HUD show:YES];
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager
     logInWithReadPermissions: @[@"email"]
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
             [AlertManager showErrorMessage:@"Facebook process error"];
             
             [HUD hide:YES];
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
             [AlertManager showErrorMessage:@"Facebook process cancelled"];
             
             
             [HUD hide:YES];
         } else {
             NSLog(@"Logged in");
             
             [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"picture, email"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 if (!error) {
                     NSString *pictureURL = [NSString stringWithFormat:@"%@",[result objectForKey:@"picture"]];
                     NSString *email = [result objectForKey:@"email"];
                     NSLog(@"email is %@", email);
                     
                     NSData  *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:pictureURL]];
                     
                     NSLog(@"fetched user:%@", result);
                     
                     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                     //[manager.requestSerializer setTimeoutInterval:20];
                     manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
                     NSDictionary *params = @{@"email": email, @"class":@"NF"};
                     
                     [manager GET:[BackEndManager getFullUrlString:@"customer/exist"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         
                         // handle response result
                         NSDictionary *jsonResult = (NSDictionary*)responseObject;
                         
                         NSString *password = @"facebook";
                         
                         
                         if([[jsonResult objectForKey:@"exist"] boolValue] == YES)
                         {
                             NSDictionary *params = @{@"email": email, @"password": password};
                             
                             [manager POST:[BackEndManager getFullUrlString:@"customer/signin"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 NSLog(@"JSON: %@", responseObject);
                                 //[self navigationItem].rightBarButtonItem = signupBtn;
                                 
                                 NSDictionary *jsonResult = (NSDictionary*)responseObject;
                                 
                                 
                                 if([[jsonResult objectForKey:@"success"] boolValue] == YES)
                                 {
                                     // set login type as facebook
                                     NSDictionary *userInfo = [jsonResult objectForKey:@"user_info"];
                                     
                                     [[AppDelegate sharedInstance] setLoginType:@"facebook"];
                                     [[AppDelegate sharedInstance] setEmail:email];
                                     [[AppDelegate sharedInstance] setReferralCode:[userInfo objectForKey:@"referral_code"]];
                                     [[AppDelegate sharedInstance] setZipCode:[userInfo objectForKey:@"zip_code"]];
                                     
                                     // save cookie
                                     [[AppDelegate sharedInstance] setCookie:email password:password];
                                     
                                     
                                     HomeRootViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"home_root"];
                                     [self.navigationController presentViewController:vc animated:YES completion:nil];
                                     
                                     if (![[ConfigManager getIsFirstComment] isEqualToString:@"1"]) {
                                         FirstCommentModalController *comment_vc = [self.storyboard instantiateViewControllerWithIdentifier:@"firstCommentModal"];
                                         comment_vc.delegate = [KGModal sharedInstance];
                                         [[KGModal sharedInstance] showWithContentViewController:comment_vc andAnimated:YES];
                                         [ConfigManager setIsFistComment:@"1"];
                                     }
                                 } else {
                                     NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
                                     [AlertManager showErrorMessage:msg];
                                 }
                                 
                                 
                                 [HUD hide:YES];
                                 
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"Error: %@", error);
                                 //[self navigationItem].rightBarButtonItem = signupBtn;
                                 
                                 //[AlertManager showErrorMessage:@"Connection failure"];
                                 
                                 [HUD hide:YES];
                             }];
                         } else {
                             
                             NSDictionary *params = @{@"email": email, @"password": password, @"class": @"RF"};
                             
                             
                             
                             [manager POST:[BackEndManager getFullUrlString:@"customer/signup"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 NSLog(@"JSON: %@", responseObject);
                                 //[self navigationItem].rightBarButtonItem = signupBtn;
                                 
                                 NSDictionary *jsonResult = (NSDictionary*)responseObject;
                                 
                                 
                                 if([[jsonResult objectForKey:@"success"] boolValue] == YES)
                                 {
                                     // set login type as facebook
                                     //NSDictionary *userInfo = [jsonResult objectForKey:@"user_info"];
                                     
                                     [[AppDelegate sharedInstance] setLoginType:@"facebook"];
                                     [[AppDelegate sharedInstance] setEmail:email];
                                     [[AppDelegate sharedInstance] setReferralCode:nil];
                                     [[AppDelegate sharedInstance] setZipCode:nil];
                                     
                                     // save cookie
                                     [[AppDelegate sharedInstance] setCookie:email password:password];
                                     
                                     WelcomeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"welcomeView"];
                                     [self.navigationController presentViewController:vc animated:YES completion:nil];
                                 } else {
                                     NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
                                     [AlertManager showErrorMessage:msg];
                                 }
                                 
                                 [HUD hide:YES];
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"Error: %@", error);
                                 //[self navigationItem].rightBarButtonItem = signupBtn;
                                 
                                 //[AlertManager showErrorMessage:@"Connection failure"];
                                 
                                 [HUD hide:YES];
                             }];                         }
                         
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         NSLog(@"Error: %@", error);
                         [HUD hide:YES];
                         
                         //[AlertManager showErrorMessage:@"Connection failure"];
                     }];
                     
                 }
                 else{
                     NSLog(@"%@", [error localizedDescription]);
                     
                     [HUD hide:YES];
                 }
             }];
         }
     }];
}

- (IBAction)twitterSignupBtn:(id)sender {
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Set the hud to display with a color
    
    HUD.color = [UIColor colorWithRed:222.0f/255.0f green:0 blue:35.0f/255.0f alpha:0.90];
    HUD.labelText = @"Please wait...";
    HUD.dimBackground = YES;
    
    [HUD show:YES];
    
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            NSLog(@"signed in as %@", [session userName]);
            
            NSString *username = [session userName];
            //TWTRShareEmailViewController* shareEmailViewController = [[TWTRShareEmailViewController alloc] initWithCompletion:^(NSString* email, NSError* error) {
                //NSLog(@"Email %@, Error: %@", email, error);
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                //[manager.requestSerializer setTimeoutInterval:20];
                manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
                
                NSDictionary *params;
                
                //if(email!=nil && email.length>0)
                    //params = @{@"email": email};
                //else
                    params = @{@"username": username};
                
                
                [manager GET:[BackEndManager getFullUrlString:@"customer/exist"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    // handle response result
                    NSDictionary *jsonResult = (NSDictionary*)responseObject;
                    
                    
                    if([[jsonResult objectForKey:@"exist"] boolValue] == YES)
                    {
                        //[AlertManager showErrorMessage:@"You've already signed up with this Twitter account"];
                        NSString *password = @"twitter";
                        
                        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                        //[manager.requestSerializer setTimeoutInterval:20];
                        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
                        NSDictionary *params = @{@"username": username, @"password": password};
                        [manager POST:[BackEndManager getFullUrlString:@"customer/signinwithusername"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            NSLog(@"JSON: %@", responseObject);
                            
                            
                            
                            // handle response result
                            NSDictionary *jsonResult = (NSDictionary*)responseObject;
                            
                            
                            if([[jsonResult objectForKey:@"success"] boolValue] == YES)
                            {
                                NSDictionary *userInfo = [jsonResult objectForKey:@"user_info"];
                                NSString *referralCode = [userInfo objectForKey:@"referral_code"];
                                NSString *zipCode = [userInfo objectForKey:@"zip_code"];
                                NSString *email = [userInfo objectForKey:@"email"];
                                
                                [[AppDelegate sharedInstance] setLoginType:@"twitter"];
                                [[AppDelegate sharedInstance] setEmail:email];
                                [[AppDelegate sharedInstance] setReferralCode:referralCode];
                                [[AppDelegate sharedInstance] setZipCode:zipCode];
                                
                                //[[AppDelegate sharedInstance] loadRestaurants];
                                
                                // save cookie
                                [[AppDelegate sharedInstance] setCookie:email password:password];
                                
                                HomeRootViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"home_root"];
                                [self.navigationController presentViewController:vc animated:YES completion:nil];
                                
                                if (![[ConfigManager getIsFirstComment] isEqualToString:@"1"]) {
                                    FirstCommentModalController *comment_vc = [self.storyboard instantiateViewControllerWithIdentifier:@"firstCommentModal"];
                                    comment_vc.delegate = [KGModal sharedInstance];
                                    [[KGModal sharedInstance] showWithContentViewController:comment_vc andAnimated:YES];
                                    [ConfigManager setIsFistComment:@"1"];
                                }
                                
                                
                            } else {
                                NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
                                [AlertManager showErrorMessage:msg];
                            }
                            
                            [HUD hide:YES];
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"Error: %@", error);
                            
                            //[AlertManager showErrorMessage:@"Connection failure"];
                            
                            [HUD hide:YES];
                        }];
                    } else {
                        EnterEmailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"enterEmailView"];
                        vc.isRestaurant = YES;
                        vc.username = [session userName];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    
                    [HUD hide:YES];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    
                    //[AlertManager showErrorMessage:@"Connection failure"];
                    
                    [HUD hide:YES];
                }];
             //}];
             //[self presentViewController:shareEmailViewController animated:YES completion:nil];
            
            
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
            
            [HUD hide:YES];
        }
    }];
}
@end
