//
//  EnterEmailViewController.m
//  Snackr
//
//  Created by Matko Lajbaher on 9/25/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "EnterEmailViewController.h"

#import "HomeRootViewController.h"
#import "WelcomeViewController.h"
#import "BackEndManager.h"

#import "AFNetworking.h"
#import "AppDelegate.h"
#import "AlertManager.h"

@interface EnterEmailViewController ()
{
    UIBarButtonItem *signupBtn;
    UIBarButtonItem *loadingBtn;
}
@end

@implementation EnterEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setHeaderView];
    [self.textFieldEmail setKeyboardType:UIKeyboardTypeEmailAddress];
    [self.textFieldEmail reloadInputViews];
    
    if(self.email!=nil && self.email.length>0) {
        self.textFieldEmail.text = self.email;
        self.textFieldEmail.enabled = NO;
    }

}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    signupBtn = [[UIBarButtonItem alloc]initWithTitle:@"SIGN UP"  style:UIBarButtonItemStylePlain target:self action:@selector(onSingup)];
    [self.navigationItem setRightBarButtonItem:signupBtn];
    
    UILabel *title = [[UILabel alloc]init];
    [title setFont:[UIFont fontWithName:@"MuseoSans-100" size:16.0f]];
    title.text = @"ENTER YOUR EMAIL";
    title.textColor = [UIColor colorWithRed:(44.0f/255.0f) green:(44.0f/255.0f) blue:(44.0f/255.0f) alpha:1.0f];
    
    float maximumLabelSize =   [title.text boundingRectWithSize:title.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:title.font } context:nil].size.width;
    
    title.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:title];
    
    self.navigationItem.titleView = headerview;
}

- (void) onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onSingup
{
    // Customer signin handling
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
    
    NSString *password = @"twitter";
    //if(loadingBtn == nil)
    {
        UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        activityIndicator.color = [UIColor grayColor];
        loadingBtn = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        
        [activityIndicator startAnimating];
    }
    [self navigationItem].rightBarButtonItem = loadingBtn;
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager.requestSerializer setTimeoutInterval:20];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"email": email, @"password": password, @"class": self.isRestaurant?@"RT":@"NT", @"username": self.username};
    
    [manager POST:[BackEndManager getFullUrlString:@"customer/signup"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [self navigationItem].rightBarButtonItem = signupBtn;
        
        NSDictionary *jsonResult = (NSDictionary*)responseObject;
        
        
        if([[jsonResult objectForKey:@"success"] boolValue] == YES)
        {
            //NSDictionary *userInfo = [jsonResult objectForKey:@"user_info"];
            
            [[AppDelegate sharedInstance] setLoginType:@"twitter"];
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self navigationItem].rightBarButtonItem = signupBtn;
        
        [AlertManager showErrorMessage:@"Connection failure"];
    }];
    
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
        [self onSingup];
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
