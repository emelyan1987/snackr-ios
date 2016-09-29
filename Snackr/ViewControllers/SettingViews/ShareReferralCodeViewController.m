//
//  ShareReferralCodeViewController.m
//  Snackr
//
//  Created by Snackr on 8/21/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "ShareReferralCodeViewController.h"
#import "KGModal.h"
#import "Utils.h"
#import "AFNetworking.h"
#import "BackEndManager.h"
#import "AlertManager.h"
#import "AppDelegate.h"

@interface ShareReferralCodeViewController () <KGModalShareRefferralDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelReferralCode;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@end

@implementation ShareReferralCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bgView.layer.cornerRadius = 5.0f;
    self.bgView.clipsToBounds = YES;
    
    self.labelReferralCode.text = [[AppDelegate sharedInstance] getReferralCode];//[Utils randomAlphanumericStringWithLength:6];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDone:(id)sender {
    [self.delegate onDoneShareRefferralCode];
}
- (IBAction)onShareRefferralCode:(id)sender {
    [self.delegate onShareRefferalCode];
}

#pragma mark KGModalShareRefferralDelegate
- (void) shareRefferralCode
{
    NSString *code = self.labelReferralCode.text;
    /*AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager.requestSerializer setTimeoutInterval:20];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"code": code};
    [manager POST:[BackEndManager getFullUrlString:@"customer/sharecode"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        // handle response result
        NSDictionary *jsonResult = (NSDictionary*)responseObject;
        
        
        if([[jsonResult objectForKey:@"success"] boolValue] == YES)
        {
            self.btnShare.enabled = NO;
            
            NSString *appStoreUrl = @"https://itunes.apple.com/app/...";
            NSString *textToShare = [NSString stringWithFormat:@"Hey! Join me on Snackr, a fun app to share photos of delicious food dishes.\n\n %@\n\n When you sign up, use my referral code: %@", appStoreUrl, code];
            
            NSURL *myWebsite = [NSURL URLWithString:@"http://www.codingexplorer.com/"];
            
            NSArray *objectsToShare = @[textToShare, myWebsite*];
            
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            
            NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                           UIActivityTypePrint,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeSaveToCameraRoll,
                                           UIActivityTypeAddToReadingList,
                                           UIActivityTypePostToFlickr,
                                           UIActivityTypePostToVimeo];
            
            activityVC.excludedActivityTypes = excludeActivities;
            [activityVC setValue:@"Snackr Sharing Referral Code" forKey:@"subject"];
            
            [self presentViewController:activityVC animated:YES completion:nil];
        } else {
            NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
            [AlertManager showErrorMessage:msg];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //[AlertManager showErrorMessage:@"Connection failure"];
    }];*/
    
NSString *appStoreUrl = @"https://itunes.apple.com/us/app/snackr-food-made-fun/id1034170458?ls=1&mt=8";
NSString *textToShare = [NSString stringWithFormat:@"Hey! Join me on Snackr, a fun app to share photos of delicious food dishes.\n\n %@\n\n When you sign up, use my referral code: %@", appStoreUrl, code];

//NSURL *myWebsite = [NSURL URLWithString:@"http://www.codingexplorer.com/"];

NSArray *objectsToShare = @[textToShare/*, myWebsite*/];

UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];

NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                               UIActivityTypePrint,
                               UIActivityTypeAssignToContact,
                               UIActivityTypeSaveToCameraRoll,
                               UIActivityTypeAddToReadingList,
                               UIActivityTypePostToFlickr,
                               UIActivityTypePostToVimeo];

activityVC.excludedActivityTypes = excludeActivities;
[activityVC setValue:@"Snackr Sharing Referral Code" forKey:@"subject"];

[self presentViewController:activityVC animated:YES completion:nil];
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
