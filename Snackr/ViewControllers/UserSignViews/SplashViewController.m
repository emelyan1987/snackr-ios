//
//  SplashViewController.m
//  Snackr
//
//  Created by Matko Lajbaher on 9/26/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "SplashViewController.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "BackEndManager.h"


#import "KGModal.h"
#import "ConfigManager.h"
#import "HomeRootViewController.h"
#import "FirstCommentModalController.h"
#import "HomeViewController.h"
#import "UIGifImage.h"

@interface SplashViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *loadingImageView;
@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*NSString *filePath = [[NSBundle mainBundle] pathForResource: @"loader" ofType: @"gif"];
    UIGifImage *loaderImage = [[UIGifImage alloc] initWithContentsOfFile:filePath];
    self.loadingImageView.image = loaderImage;*/
    
    NSDictionary *cookie = [[AppDelegate sharedInstance] getCookie];
    
    if(cookie!=nil)
    {
        NSString *email = [cookie objectForKey:@"email"];
        NSString *password = [cookie objectForKey:@"password"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //[manager.requestSerializer setTimeoutInterval:20];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        NSDictionary *params = @{@"email": email, @"password": password};
        [manager POST:[BackEndManager getFullUrlString:@"customer/signin"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"JSON: %@", responseObject);
            // handle response result
            NSDictionary *jsonResult = (NSDictionary*)responseObject;
            
            
            if([[jsonResult objectForKey:@"success"] boolValue] == YES)
            {
                NSDictionary *userInfo = [jsonResult objectForKey:@"user_info"];
                //NSString *email = [userInfo objectForKey:@"email"];
                NSString *referralCode = [userInfo objectForKey:@"referral_code"];
                NSString *zipCode = [userInfo objectForKey:@"zip_code"];
                
                [[AppDelegate sharedInstance] setLoginType:@"email"];
                [[AppDelegate sharedInstance] setEmail:email];
                [[AppDelegate sharedInstance] setReferralCode:referralCode];
                [[AppDelegate sharedInstance] setZipCode:zipCode];
                
                //[[AppDelegate sharedInstance] loadRestaurants];
                
                //nav_vc = [storyboard instantiateViewControllerWithIdentifier:@"home_root"];
                
                //[initial_nav presentViewController:nav_vc animated:NO completion:nil];
                
                UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"home_root"];
                [self.navigationController pushViewController:vc animated:NO];
                
                if (![[ConfigManager getIsFirstComment] isEqualToString:@"1"]) {
                    FirstCommentModalController *comment_vc = [self.storyboard instantiateViewControllerWithIdentifier:@"firstCommentModal"];
                    comment_vc.delegate = [KGModal sharedInstance];
                    [[KGModal sharedInstance] showWithContentViewController:comment_vc andAnimated:YES];
                    [ConfigManager setIsFistComment:@"1"];
                }
                
                
            } else {
                //NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
                //[AlertManager showErrorMessage:msg];
                UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"startView"];
                [self.navigationController pushViewController:vc animated:NO];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            
            //[AlertManager showErrorMessage:@"Connection failure"];
            UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"startView"];
            [self.navigationController pushViewController:vc animated:NO];
        }];
    } else {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"startView"];
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
