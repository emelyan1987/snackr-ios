//
//  EmailLoginViewController.m
//  Snackr
//
//  Created by Snackr on 8/11/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "EmailLoginViewController.h"
#import "ForgetPasswordViewController.h"
#import "HomeRootViewController.h"

#import "FirstCommentModalController.h"
#import "KGModal.h"
#import "ConfigManager.h"

#import "BackEndManager.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "AlertManager.h"


@interface EmailLoginViewController ()
{
    UIBarButtonItem *signupBtn;
    UIBarButtonItem *loadingBtn;
}
@property UIActivityIndicatorView* activityIndicator;

@end

@implementation EmailLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setHeaderView];
    [self initView];
    
    [self.textFieldEmail setKeyboardType:UIKeyboardTypeEmailAddress];
    [self.textFieldEmail reloadInputViews];
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
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSFontAttributeName:[UIFont fontWithName:@"MuseoSans-900" size:13.0f]
       } forState:UIControlStateNormal];
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backBtn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    signupBtn = [[UIBarButtonItem alloc]initWithTitle:@"LOG IN"  style:UIBarButtonItemStylePlain target:self action:@selector(onSingin)];
    [self.navigationItem setRightBarButtonItem:signupBtn];
    
    UILabel *title = [[UILabel alloc]init];
    [title setFont:[UIFont fontWithName:@"MuseoSans-100" size:16.0f]];
    title.text = @"LOG IN WITH EMAIL";
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

- (void) onSingin
{
    NSString *email = [self.textFieldEmail text];
    
    if(![BackEndManager isValidEmail:email]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input Error"
                                                        message:@"Email format is incorrect. please use correct format(ex:emelyan@gmail.com)"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSString *password = [self.textFieldPassword text];
    if(password == nil || [password length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input Error"
                                                        message:@"Password is required. please input password"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //if(loadingBtn == nil)
    {
        self.activityIndicator.color = [UIColor grayColor];
        loadingBtn = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
        
        [self.activityIndicator startAnimating];
    }
    [self navigationItem].rightBarButtonItem = loadingBtn;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager.requestSerializer setTimeoutInterval:20];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"email": email, @"password": password};
    [manager POST:[BackEndManager getFullUrlString:@"customer/signin"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [self navigationItem].rightBarButtonItem = signupBtn;
        
        
        // handle response result
        NSDictionary *jsonResult = (NSDictionary*)responseObject;
        
        
        if([[jsonResult objectForKey:@"success"] boolValue] == YES)
        {
            NSDictionary *userInfo = [jsonResult objectForKey:@"user_info"];
            NSString *referralCode = [userInfo objectForKey:@"referral_code"];
            NSString *zipCode = [userInfo objectForKey:@"zip_code"];
            
            [[AppDelegate sharedInstance] setLoginType:@"email"];
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self navigationItem].rightBarButtonItem = signupBtn;
        
        [AlertManager showErrorMessage:@"Connection failure"];
    }];
}


- (void) initView
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.submitBtn.layer.cornerRadius = 3.0f;
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.forgetPassBtn.titleLabel.text];
    [attrStr addAttribute:NSForegroundColorAttributeName value:self.forgetPassBtn.titleLabel.textColor range:NSMakeRange(0, attrStr.length)];
    [attrStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(0, attrStr.length)];
    [attrStr addAttribute:NSUnderlineColorAttributeName value:self.forgetPassBtn.titleLabel.textColor range:NSMakeRange(0, attrStr.length)];
    self.forgetPassBtn.titleLabel.attributedText = attrStr;
}

- (IBAction)onSubmit:(id)sender {
    [self onSingin];
}

- (IBAction)onForgetPassword:(id)sender {
    ForgetPasswordViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"forgetPassView"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(textField == self.textFieldEmail)
        [self.textFieldPassword becomeFirstResponder];
    else if (textField == self.textFieldPassword)
        [self onSingin];
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
