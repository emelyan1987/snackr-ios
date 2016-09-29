//
//  SettingViewController.m
//  Snackr
//
//  Created by Snackr on 8/20/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingViewCell.h"
#import "SetPasswordViewController.h"
#import "EnterPromoCodeViewController.h"
#import "EnterZipCodeViewController.h"
#import "KGModal.h"
#import "ShareReferralCodeViewController.h"
#import "StartViewController.h"

#import "BackEndManager.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "AlertManager.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <TwitterKit/TwitterKit.h>

@interface SettingViewController () <SettingViewCellDelegate>

@property NSArray *settingTitle;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setHeaderView];
    
    self.settingTitle = [[NSArray alloc] init];
    self.settingTitle = @[@"Email Address", @"Set Password", @"Share Referral Code", @"Input a Referral Code", @"Input a Zip Code"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setHeaderView
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backBtn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    UILabel *title = [[UILabel alloc]init];
    [title setFont:[UIFont fontWithName:@"MuseoSans-100" size:16.0f]];
    title.text = @"SETTINGS";
    title.textColor = [UIColor colorWithRed:(44.0f/255.0f) green:(44.0f/255.0f) blue:(44.0f/255.0f) alpha:1.0f];
    
    float maximumLabelSize =  [title.text boundingRectWithSize:title.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:title.font } context:nil].size.width;
    
    title.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:title];
    
    self.navigationItem.titleView = headerview;
}

- (void) onBack {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 5;
    }else if(section == 1){
        return 1;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 9;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingViewCell"];
    
    cell.delegate = self;
    
    cell.email.hidden = YES;
    cell.arrowFlag.hidden = YES;
    cell.enableBtn.hidden = YES;
    cell.loadingIndicator.hidden = YES;
    
    if (indexPath.section == 0) {
        cell.title.text = [self.settingTitle objectAtIndex:indexPath.row];
        
        if (indexPath.row == 0) {
            cell.email.hidden = NO;
            cell.email.text = [[AppDelegate sharedInstance] getEmail];
            cell.userInteractionEnabled = NO;
            
        } else if(indexPath.row == 1) {
            if(![[[AppDelegate sharedInstance] getLoginType] isEqualToString:@"email"])
                cell.userInteractionEnabled = NO;
            
            cell.arrowFlag.hidden = NO;
        } else {
            cell.arrowFlag.hidden = NO;
        }
    } else if (indexPath.section == 1){
        cell.title.text = @"Enable Location";
        cell.enableBtn.hidden = NO;
        cell.enableBtn.on = [[AppDelegate sharedInstance] isEnableLocation];
    } else {
        cell.title.text = @"Log Out";
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int section = indexPath.section;
    if (section == 0) {
        if (indexPath.row == 1) {
            SetPasswordViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"setPasswordView"];
            
            [self.navigationController pushViewController:vc animated:YES];
        } else if(indexPath.row == 2){
            
            ShareReferralCodeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"shareReferralCodeView"];
            KGModal *kgm = [KGModal sharedInstance];
            vc.delegate = kgm;
            kgm.delegateShareRefferralCode = vc;
            [[KGModal sharedInstance] showWithContentViewController:vc andAnimated:YES];
            
        } else if (indexPath.row == 3){
            EnterPromoCodeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"promoCodeView"];
            
            [self.navigationController pushViewController:vc animated:YES];
        } else if (indexPath.row == 4){
            EnterZipCodeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"zipCodeView"];
            
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if(section == 2) { // handle logging out
        SettingViewCell *cell = (SettingViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.loadingIndicator.hidden = NO;
        [cell.loadingIndicator startAnimating];
        
        NSString *loginType = [[AppDelegate sharedInstance] getLoginType];
        if([loginType isEqualToString:@"facebook"]) {
            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
            [loginManager logOut];
        } else if([loginType isEqualToString:@"twitter"]) {
            TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
            NSString *userID = store.session.userID;
            
            [store logOutUserID:userID];
        }
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //[manager.requestSerializer setTimeoutInterval:20];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        [manager POST:[BackEndManager getFullUrlString:@"customer/logout"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            //[self navigationItem].rightBarButtonItem = signupBtn;
            
            
            // handle response result
            NSDictionary *jsonResult = (NSDictionary*)responseObject;
            
            
            if([[jsonResult objectForKey:@"success"] boolValue] == YES)
            {
                [[AppDelegate sharedInstance] deleteCookie];
                UIViewController *rootVC = [self.storyboard instantiateViewControllerWithIdentifier:@"parent_nav"];
                [self presentViewController:rootVC animated:YES completion:nil];
            } else {
                NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
                [AlertManager showErrorMessage:msg];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            //[self navigationItem].rightBarButtonItem = signupBtn;
            
            //[AlertManager showErrorMessage:@"Connection failure"];
        }];
    }
}
#pragma mark SettingViewCellDelegate

-(void) onEnableLocation {
    
}
- (IBAction)btnToSClicked:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL
                                                URLWithString:@"http://www.snackrapp.com/terms-of-service"]];
}
- (IBAction)btnPPClicked:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL
                                                URLWithString:@"http://www.snackrapp.com/privacy-policy"]];
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
