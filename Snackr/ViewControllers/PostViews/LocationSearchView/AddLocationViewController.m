//
//  SubmitLocationViewController.m
//  Snackr
//
//  Created by Matko Lajbaher on 9/25/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "AddLocationViewController.h"

#import "AFNetworking.h"
#import "BackEndManager.h"
#import "AlertManager.h"
#import "PostViewController.h"
#import "Restaurant.h"
#import "AppDelegate.h"

@interface AddLocationViewController ()
{
    UIBarButtonItem *nextBtn;
}
@end

@implementation AddLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setHeaderView];
    
    self.textFieldLocation.autocorrectionType = UITextAutocorrectionTypeNo;
    
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
    
    nextBtn = [[UIBarButtonItem alloc]initWithTitle:@"NEXT"  style:UIBarButtonItemStylePlain target:self action:@selector(onNext)];
    [self.navigationItem setRightBarButtonItem:nextBtn];
    
    UILabel *title = [[UILabel alloc]init];
    [title setFont:[UIFont fontWithName:@"MuseoSans-100" size:16.0f]];
    title.text = @"ADD A LOCATION";
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

- (void) onNext {
    NSString *title = [self.textFieldLocation text];
    if(title == nil || [title length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input Error"
                                                        message:@"Location name is required."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[AppDelegate sharedInstance] getCurrentCoordinate:^(CLLocationCoordinate2D coordinate, NSError *error){
        if(error != nil) {
            [AlertManager showErrorMessage:@"Sorry, couldn't get your current location this time. Please try again later"];
            return;
        }
        
        
        NSString *location = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
        
        UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        activityIndicator.color = [UIColor grayColor];
        UIBarButtonItem *loadingBtn = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        [activityIndicator startAnimating];
        [self navigationItem].rightBarButtonItem = loadingBtn;
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //[manager.requestSerializer setTimeoutInterval:20];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        NSDictionary *params = @{@"title": title, @"location": location};
        [manager POST:[BackEndManager getFullUrlString:@"rest/add"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            [self navigationItem].rightBarButtonItem = nextBtn;
            
            
            // handle response result
            NSDictionary *jsonResult = (NSDictionary*)responseObject;
            
            
            if([[jsonResult objectForKey:@"success"] boolValue] == YES)
            {
                NSDictionary *dicRestaurant = [jsonResult objectForKey:@"restaurant"];
                Restaurant *restaurant = [[Restaurant alloc] init];
                restaurant.no = [[dicRestaurant objectForKey:@"id"] intValue];
                restaurant.title = [dicRestaurant objectForKey:@"title"];
                restaurant.address = [dicRestaurant objectForKey:@"address"];
                restaurant.location = [dicRestaurant objectForKey:@"location"];
                restaurant.zipCode = [dicRestaurant objectForKey:@"zip_code"];
                restaurant.descript = [dicRestaurant objectForKey:@"description"];
                
                //[[[AppDelegate sharedInstance] getRestaurants] addObject:restaurant];
                
                PostViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"postView"];
                vc.post_image = self.post_image;
                vc.restaurant = restaurant;
                
                UINavigationController *navigator = self.navigationController;
                [navigator popViewControllerAnimated:NO];
                [navigator pushViewController:vc animated:YES];
            } else {
                NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
                [AlertManager showErrorMessage:msg];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [self navigationItem].rightBarButtonItem = nextBtn;
            
            //[AlertManager showErrorMessage:@"Connection failure"];
        }];
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
