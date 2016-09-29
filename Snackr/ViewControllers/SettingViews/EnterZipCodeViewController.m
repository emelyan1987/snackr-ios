//
//  EnterZipCodeViewController.m
//  Snackr
//
//  Created by Snackr on 8/21/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "EnterZipCodeViewController.h"
#import "AlertManager.h"
#import "AFNetworking.h"
#import "BackEndManager.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface EnterZipCodeViewController ()
{
    UIBarButtonItem *doneBtn;
    UIActivityIndicatorView* activityIndicator;
    
    MBProgressHUD *HUD;
}
@property (weak, nonatomic) IBOutlet UISwitch *switchUsePhone;
@end

@implementation EnterZipCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setHeaderView];
    self.textFieldZipCode.autocorrectionType = UITextAutocorrectionTypeNo;
    
    NSString *zipCode = [[AppDelegate sharedInstance] getZipCode];
    if(zipCode != nil)
        self.textFieldZipCode.text = zipCode;
    
    BOOL isUsingPhoneForZipCode = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"isUsingPhoneForZipCode"] boolValue];
    
    self.switchUsePhone.on = isUsingPhoneForZipCode;
    
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

- (void) setHeaderView
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backBtn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"DONE"  style:UIBarButtonItemStylePlain target:self action:@selector(onDone)];
    [self.navigationItem setRightBarButtonItem:doneBtn];
    
    UILabel *title = [[UILabel alloc]init];
    [title setFont:[UIFont fontWithName:@"MuseoSans-100" size:16.0f]];
    title.text = @"ADD A ZIP CODE";
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
    NSString *code = [self.textFieldZipCode text];
    if(code == nil || [code length] == 0)
    {
        [AlertManager showErrorMessage:@"ZipCode is required."];
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
    NSDictionary *params = @{@"code": code};
    [manager POST:[BackEndManager getFullUrlString:@"customer/inputzipcode"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [self navigationItem].rightBarButtonItem = doneBtn;
        
        
        // handle response result
        NSDictionary *jsonResult = (NSDictionary*)responseObject;
        
        
        if([[jsonResult objectForKey:@"success"] boolValue] == YES)
        {
            [[AppDelegate sharedInstance] setZipCode:code];
            [AlertManager showSuccessMessage:nil];
            
            [self.navigationController popViewControllerAnimated:NO];
            
            
            
            [[AppDelegate sharedInstance] loadDish:YES successHandler:nil failureHandler:nil];
            
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.switchUsePhone.isOn] forKey:@"isUsingPhoneForZipCode"];
            
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


- (IBAction)changedUsePhoneLocation:(id)sender {
    UISwitch *switchUsePhone = (UISwitch*)sender;
    
    
    if(switchUsePhone.isOn)
    {
        
        /*if([[AppDelegate sharedInstance] isEnableLocation])
        {
            self.textFieldZipCode.text = [[AppDelegate sharedInstance] getPhoneZipCode];
        }
        else
        {
            [AlertManager showInfoMessage:@"First you have to enable location!"];
            [self.navigationController popViewControllerAnimated:NO];
        }*/
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        
        // Set the hud to display with a color
        HUD.color = [UIColor colorWithRed:222.0f/255.0f green:0 blue:35.0f/255.0f alpha:0.90];
        HUD.labelText = @"Please wait...";
        HUD.dimBackground = YES;
        
        [HUD show:YES];
        
        [[AppDelegate sharedInstance] getCurrentCoordinate:^(CLLocationCoordinate2D coordinate, NSError *error){
            if(error != nil)
            {
                [AlertManager showErrorMessage:@"Sorry, couldn't get your current location. Please try again later"];
                [HUD hide:YES];
                return;
            }
            
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            //[manager.requestSerializer setTimeoutInterval:20];
            
            //http://maps.googleapis.com/maps/api/geocode/json?latlng=51.04166373133121,5.580196380615234&sensor=true
            //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:[NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude] forKey:@"latlng"];
            [params setObject:@"true" forKey:@"sensor"];
            
            [manager GET:@"http://maps.googleapis.com/maps/api/geocode/json"
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     [HUD hide:YES];

                     //parse out the json data
                     NSDictionary* json = (NSDictionary*)responseObject;
                     
                     NSLog([NSString stringWithFormat:@"Json Result: %@", json]);
                     
                     NSArray *result = [(NSDictionary*)json objectForKey:@"results"];
                     for(int i=0;i<[result count];i++)
                     {
                         NSDictionary *values = (NSDictionary*)[result objectAtIndex:i];
                         
                         NSArray *component = [(NSDictionary*)values objectForKey:@"address_components"];
                         
                         for(int j=0;j<[component count];j++)
                         {
                             NSDictionary *parts = (NSDictionary*)[component objectAtIndex:j];
                             if([[parts objectForKey:@"types"] containsObject:@"postal_code"])
                             {
                                 NSString *code = [parts objectForKey:@"long_name"];
                                 NSLog(@"Postal Code : %@ ", code);
                                 [[AppDelegate sharedInstance] setPhoneZipCode:code];
                                 self.textFieldZipCode.text = code;
                                 break;
                             }
                         }
                     }
                     
                     
                     
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     [HUD hide:YES];

                     [AlertManager showErrorMessage:[error localizedDescription]];
                     NSLog(@"Error: %@", error);
                     
                 }];
            
        }];
    } else {
        self.textFieldZipCode.text = [[AppDelegate sharedInstance] getZipCode];
    }
    
}
@end
