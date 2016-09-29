//
//  EnterPromoCodeViewController.m
//  Snackr
//
//  Created by Snackr on 8/21/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "SetPasswordViewController.h"
#import "AFNetworking.h"
#import "BackEndManager.h"
#import "KGModal.h"
#import "AlertManager.h"

@interface SetPasswordViewController ()
{
    UIBarButtonItem *doneBtn;
    UIActivityIndicatorView* activityIndicator;
}


@end

@implementation SetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setHeaderView];
    
    self.textFieldCurrentPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textFieldNewPassword.autocorrectionType = UITextAutocorrectionTypeNo;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setHeaderView
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backBtn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"DONE"  style:UIBarButtonItemStylePlain target:self action:@selector(onDone)];
    [self.navigationItem setRightBarButtonItem:doneBtn];
    
    UILabel *title = [[UILabel alloc]init];
    [title setFont:[UIFont fontWithName:@"MuseoSans-100" size:16.0f]];
    title.text = @"SET PASSWORD";
    title.textColor = [UIColor colorWithRed:(44.0f/255.0f) green:(44.0f/255.0f) blue:(44.0f/255.0f) alpha:1.0f];
    
    float maximumLabelSize =  [title.text boundingRectWithSize:title.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:title.font } context:nil].size.width;
    
    title.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:title];
    
    self.navigationItem.titleView = headerview;
}

- (void) onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onDone {
    NSString *currentPassword = [self.textFieldCurrentPassword text];
    if(currentPassword == nil || [currentPassword length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input Error"
                                                        message:@"Current password is required. please input password"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *newPassword = [self.textFieldNewPassword text];
    if(newPassword == nil || [newPassword length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input Error"
                                                        message:@"New password is required. please input password"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    activityIndicator.color = [UIColor grayColor];
    UIBarButtonItem *loadingBtn = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator startAnimating];
    [self navigationItem].rightBarButtonItem = loadingBtn;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager.requestSerializer setTimeoutInterval:20];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"currentPassword": currentPassword, @"newPassword": newPassword};
    [manager POST:[BackEndManager getFullUrlString:@"customer/changepwd"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [self navigationItem].rightBarButtonItem = doneBtn;
        
        
        // handle response result
        NSDictionary *jsonResult = (NSDictionary*)responseObject;
        
        
        if([[jsonResult objectForKey:@"success"] boolValue] == YES)
        {
            [AlertManager showSuccessMessage:nil];
            
            [self.navigationController popViewControllerAnimated:NO];
        } else {
            NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
            [AlertManager showErrorMessage:msg];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self navigationItem].rightBarButtonItem = doneBtn;
        
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
