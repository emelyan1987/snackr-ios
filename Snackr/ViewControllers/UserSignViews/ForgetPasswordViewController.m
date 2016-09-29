//
//  ForgetPasswordViewController.m
//  Snackr
//
//  Created by Snackr on 8/12/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "AFNetworking.h"
#import "BackEndManager.h"
#import "AlertManager.h"

@interface ForgetPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@end

@implementation ForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setHeaderView];
    self.submitBtn.layer.cornerRadius = 3.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setHeaderView
{
//    [self setNeedsStatusBarAppearanceUpdate];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backBtn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];

    UILabel *title = [[UILabel alloc]init];
    [title setFont:[UIFont fontWithName:@"MuseoSans-100" size:16.0f]];
    title.text = @"FORGET PASSWORD";
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
- (IBAction)onSubmit:(id)sender {
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
    
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    activityIndicator.color = [UIColor grayColor];
    UIBarButtonItem *loadingBtn = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        
    [activityIndicator startAnimating];
    [self navigationItem].rightBarButtonItem = loadingBtn;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager.requestSerializer setTimeoutInterval:20];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"email": email};
    [manager POST:[BackEndManager getFullUrlString:@"customer/resetpassword"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        // handle response result
        NSDictionary *jsonResult = (NSDictionary*)responseObject;
        
        
        if([[jsonResult objectForKey:@"success"] boolValue] == YES)
        {
            [AlertManager showInfoMessage:@"Check your email to reset your password"];
            
            [self.navigationController popViewControllerAnimated:NO];
        } else {
            NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
            [AlertManager showErrorMessage:msg];
        }
        
        [self navigationItem].rightBarButtonItem = nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self navigationItem].rightBarButtonItem = nil;
        
        //[AlertManager showErrorMessage:@"Connection failure"];
    }];
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
