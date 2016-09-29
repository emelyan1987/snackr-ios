//
//  StartViewController.m
//  Snackr
//
//  Created by Snackr on 8/11/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "StartViewController.h"
#import "EmailLoginViewController.h"
#import "EmailSignupViewController.h"
#include "SignUpRestaurantViewController.h"
#import "EnterEmailViewController.h"

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "BackEndManager.h"
#import "WelcomeViewController.h"

#import "KGModal.h"
#import "ConfigManager.h"
#import "HomeRootViewController.h"
#import "FirstCommentModalController.h"


#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <TwitterKit/TwitterKit.h>

#import "AlertManager.h"

#import <CoreText/CoreText.h>
#import "MBProgressHUD.h"

@interface StartViewController () <MBProgressHUDDelegate>{
    BOOL isPanning;
    BOOL isLogging;
    
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UIView *upView;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic)CGPoint originalPoint;
@property BOOL down;

@property (weak, nonatomic) IBOutlet UILabel *labelAgree;
@property (weak, nonatomic) IBOutlet UITextView *textAgree;
@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.    
    
        
    [self initView];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"By signing up, you agree to our terms of service and privacy policy"];
    [attString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
                      value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                      range:(NSRange){32,16}];
    [attString addAttribute:NSLinkAttributeName
                             value:@"http://www.snackrapp.com/terms-of-service"
                             range:(NSRange){32,16}];
    [attString addAttribute:NSLinkAttributeName
                      value:@"http://www.snackrapp.com/privacy-policy"
                      range:(NSRange){53,14}];
    
    [attString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
                      value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                      range:(NSRange){53,14}];
    
    UIFont *font = [UIFont fontWithName:@"MuseoSans-300" size:14];
    [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attString.length)];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attString.length)];

    //self.labelAgree.attributedText = attString;
    self.textAgree.attributedText = attString;
    self.textAgree.delegate = self;
    
    //self.facebookSignupBtn = [[FBSDKLoginButton alloc] init];
    /*loginButton.center = self.view.center;
    [self.view addSubview:loginButton];*/
}
/*- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    NSString *scheme = URL.scheme;
    if ([URL.scheme isEqualToString:@"TOS"]) {
        // Launch View controller
        
        return NO;
    }
    return YES;
}*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initView
{
//    [self setNeedsStatusBarAppearanceUpdate];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
    
    [self.upView addGestureRecognizer:self.panGestureRecognizer];
    
    self.signinBtn.alpha = 0.0f;
    self.signupBtn.alpha = 0.0f;
    self.triangleImg.alpha = 0.0f;
}

-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGFloat yFromCenter = [gestureRecognizer translationInView:self.upView].y;
    if (self.upView.frame.origin.y > 0) {
        self.upView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        
        isPanning = NO;
        return;
    }
    switch (gestureRecognizer.state) {
        //just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.upView.center;
            isPanning = YES;
            break;
        };
        //in the middle of a swipe
        case UIGestureRecognizerStateChanged:
            if (!isPanning)
                break;
            self.upView.center = CGPointMake(self.originalPoint.x , self.originalPoint.y + yFromCenter);
            
            [self changeSwipeState : yFromCenter];
            
            break;
        //
        case UIGestureRecognizerStateEnded: {
            if (!isPanning) {
                break;
            }
            [self afterSwipeAction : yFromCenter];
            isPanning = NO;
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

- (void) changeSwipeState : (CGFloat) distance
{
    if (distance < 0) {
        self.down = NO;
    } else{
        self.down = YES;
    }
}

- (void) afterSwipeAction : (CGFloat) distance
{
    if (self.down)
    {
        if (distance > 100) {
            [self swipeDown];
        } else{
            [UIView animateWithDuration:0.2
                             animations:^{
                                 self.upView.center = self.originalPoint;
                            }];
        }
    }
    else
    {
    
        if (distance < -100)
        {
            [self swipeTop];
        }
        else
        {
            [UIView animateWithDuration:0.2
                         animations:^{
                             self.upView.center = self.originalPoint;
                        }];
        }
    }
}

- (void) swipeTop
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.upView.center = CGPointMake(self.upView.center.x, (self.upView.frame.size.height)/2 - self.downView.frame.size.height);
                         
                         self.signinBtn.alpha = 1.0f;
                         self.signupBtn.alpha = 1.0f;
                         self.triangleImg.alpha = 1.0f;
                         
                         self.swipeComment.alpha = 0.0f;
                         self.swipeImg.alpha = 0.0f;
                     }];
}

- (void) swipeDown
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.upView.center = CGPointMake(self.upView.center.x, (self.upView.frame.size.height)/2);
                         
                         self.signinBtn.alpha = 0.0f;
                         self.signupBtn.alpha = 0.0f;
                         self.triangleImg.alpha = 0.0f;
                         
                         self.swipeComment.alpha = 1.0f;
                         self.swipeImg.alpha = 1.0f;
                     }];

}

- (IBAction)onSignUp:(UIButton *)sender
{
    if (!sender.selected) {
        sender.selected = !sender.selected;
        self.signinBtn.selected = !self.signinBtn.selected;
        
        [UIView animateWithDuration:0.2
                            animations:^{
                                self.triangleImg.center = CGPointMake(self.signupBtn.center.x, self.triangleImg.center.y);
                                
                                self.signupView.frame = CGRectMake(0, 0, self.signupView.frame.size.width, self.signupView.frame.size.height);
                                self.signinView.frame = CGRectMake(-self.signinView.frame.size.width, 0, self.signinView.frame.size.width, self.signinView.frame.size.height);
                            }completion:^(BOOL complete){
                                self.signinView.hidden = YES;
                            }];
    }
}

- (IBAction)onSignIn:(UIButton *)sender {
    if (!sender.selected) {
        sender.selected = !sender.selected;
        self.signupBtn.selected = !self.signupBtn.selected;
        
        self.signinView.hidden = NO;
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.triangleImg.center = CGPointMake(self.signinBtn.center.x, self.triangleImg.center.y);
                             
                             self.signupView.frame = CGRectMake(self.signupView.frame.size.width, 0, self.signupView.frame.size.width, self.signupView.frame.size.height);
                             self.signinView.frame = CGRectMake(0, 0, self.signinView.frame.size.width, self.signinView.frame.size.height);
                         }];
    }
    
   }

- (IBAction)onSignupEmail:(id)sender
{
    EmailSignupViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"email_singupView"];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    [self swipeDown];
}

- (IBAction)onSignupRestaurant:(id)sender
{
    SignUpRestaurantViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"signupRestaurantView"];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    [self swipeDown];
}

- (IBAction)onSigninEmail:(id)sender
{
    EmailLoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"email_loginView"];
    
    UINavigationController *navController = self.navigationController;

    NSMutableArray *controllers=[[NSMutableArray alloc] initWithArray:navController.viewControllers] ;

    [navController pushViewController:vc animated:YES];
    
    [self swipeDown];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)facebookSignupBtnClicked:(id)sender {
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Set the hud to display with a color
    
    HUD.color = [UIColor colorWithRed:222.0f/255.0f green:0 blue:35.0f/255.0f alpha:0.90];
    HUD.labelText = @"Please wait...";
    HUD.dimBackground = YES;
    
    [HUD show:YES];
    //[HUD showWhileExecuting:@selector(signupWithTwitter) onTarget:self withObject:nil animated:YES];
    
    
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
                             NSDictionary *params = @{@"email": email, @"password": password, @"class": @"NF"};
                             
                             
                             
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
                                     //[[AppDelegate sharedInstance] setReferralCode:[userInfo objectForKey:@"referral_code"]];
                                     //[[AppDelegate sharedInstance] setZipCode:[userInfo objectForKey:@"zip_code"]];
                                     
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
                             }];
                         }
                         
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

- (IBAction)facebookLoginBtnClicked:(id)sender {
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Set the hud to display with a color
    
    HUD.color = [UIColor colorWithRed:222.0f/255.0f green:0 blue:35.0f/255.0f alpha:0.90];
    HUD.labelText = @"Please wait...";
    HUD.dimBackground = YES;
    
    [HUD show:YES];
    //[HUD showWhileExecuting:@selector(signupWithTwitter) onTarget:self withObject:nil animated:YES];
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logInWithReadPermissions: @[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
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
             
             [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"picture, email, name"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                  if (!error) {
                      NSString *pictureURL = [NSString stringWithFormat:@"%@",[result objectForKey:@"picture"]];
                      NSString *email = [result objectForKey:@"email"];
                      NSLog(@"email is %@", email);
                      
                      NSData  *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:pictureURL]];
                      
                      NSLog(@"fetched user:%@", result);
                      
                      
                      NSString *password = @"facebook";
                      
                      AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                      //[manager.requestSerializer setTimeoutInterval:20];
                      manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
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
                      
                  }
                  else{
                      NSLog(@"%@", [error localizedDescription]);
                      
                      [HUD hide:YES];
                  }
              }];
         }
     }];
}

- (IBAction)twitterSignupBtnClicked:(id)sender {
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Set the hud to display with a color
    HUD.color = [UIColor colorWithRed:222.0f/255.0f green:0 blue:35.0f/255.0f alpha:0.90];
    HUD.labelText = @"Please wait...";
    HUD.dimBackground = YES;
    
    [HUD show:YES];
    //[HUD showWhileExecuting:@selector(signupWithTwitter) onTarget:self withObject:nil animated:YES];
    
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
                        
                        [HUD hide:YES];
                        EnterEmailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"enterEmailView"];
                        vc.username = [session userName];
                        //vc.email = email;
                        
                        UINavigationController *navController = self.navigationController;
                        
                        NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:navController.viewControllers] ;
                        
                        [navController pushViewController:vc animated:YES];
                        
                        [self swipeDown];
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    [HUD hide:YES];
                    
                    //[AlertManager showErrorMessage:@"Connection failure"];
                }];
            //}];
            //[self presentViewController:shareEmailViewController animated:YES completion:nil];
            
            
            
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
            [HUD hide:YES];
        }
    }];
}

- (IBAction)twitterLoginBtnClicked:(id)sender {
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Set the hud to display with a color
    
    HUD.color = [UIColor colorWithRed:222.0f/255.0f green:0 blue:35.0f/255.0f alpha:0.90];
    HUD.labelText = @"Please wait...";
    HUD.dimBackground = YES;
    
    [HUD show:YES];
    //[HUD showWhileExecuting:@selector(signupWithTwitter) onTarget:self withObject:nil animated:YES];
    
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            NSString *username = [session userName];
            NSLog(@"signed in as %@", username);

            //TWTRShareEmailViewController* shareEmailViewController = [[TWTRShareEmailViewController alloc] initWithCompletion:^(NSString* email, NSError* error) {
                //NSLog(@"Email %@, Error: %@", email, error);
                
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
            //}];
            
            //[self presentViewController:shareEmailViewController animated:YES completion:nil];
            
            
            
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
            
            [HUD hide:YES];
        }
    }];
}
@end
