//
//  PostViewController.m
//  Snackr
//
//  Created by Snackr on 8/25/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "PostViewController.h"

#import "PostConfirmViewController.h"
#import "KGModal.h"
#import "AFNetworking.h"
#import "BackEndManager.h"
#import "AlertManager.h"

@interface PostViewController ()
{
    UIBarButtonItem *postBtn;
    int price;
}
@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setHeaderView];
    
    self.postImageView.layer.cornerRadius = 5.0f;
    self.postImageView.clipsToBounds = YES;
    self.postImageView.image = self.post_image;
    
    self.textFieldDishName.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textFieldDishName.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    if(self.textFieldDishName.isFirstResponder)
        //[self.textFieldDishName resignFirstResponder];
        [self.view endEditing:YES];
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
    
    postBtn = [[UIBarButtonItem alloc]initWithTitle:@"POST"  style:UIBarButtonItemStylePlain target:self action:@selector(onPost)];
    //postBtn.enabled = NO;
    [self.navigationItem setRightBarButtonItem:postBtn];
    
    UILabel *title = [[UILabel alloc]init];
    [title setFont:[UIFont fontWithName:@"MuseoSans-100" size:16.0f]];
    title.text = @"NAME YOUR DISH";
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

- (void) onPost {
    NSString *dishName = self.textFieldDishName.text;
    if(dishName == nil || dishName.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input Error"
                                                        message:@"Please enter your dish name!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    if(dishName!=nil && [dishName length] > 0)
    {
        
            UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            activityIndicator.color = [UIColor grayColor];
            UIBarButtonItem *loadingBtn = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
            
            [activityIndicator startAnimating];
        
        [self navigationItem].rightBarButtonItem = loadingBtn;
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //[manager.requestSerializer setTimeoutInterval:20];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];//@{@"title": dishName, @"place_id": self.restaurant.placeId, @"price":[NSNumber numberWithInt:price]};
        
        [params setObject:dishName forKey:@"title"];
        [params setObject:[NSNumber numberWithInt:price] forKey:@"price"];
        
        if(self.restaurant.placeId!=nil && self.restaurant.placeId.length>0)
            [params setObject:self.restaurant.placeId forKey:@"place_id"];
        else
            [params setObject:[NSNumber numberWithInt:self.restaurant.no] forKey:@"restaurant_id"];
        
        //NSLog([NSString stringWithFormat:@"Restaurant NO: %d", self.restaurant.no]);
        
        //NSLog([NSString stringWithFormat:@"Params: %@", params]);
        
        
        [manager POST:[BackEndManager getFullUrlString:@"dish/save"] parameters:params
            constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                NSData *imageData = UIImageJPEGRepresentation(self.post_image, 0.5);
                CGSize size = self.post_image.size;
                [formData appendPartWithFileData:imageData name:@"photo" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
            }
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                //NSLog(@"JSON: %@", responseObject);
                [self navigationItem].rightBarButtonItem = postBtn;
            
            NSDictionary *jsonResult = (NSDictionary*)responseObject;
            
            
            if([[jsonResult objectForKey:@"success"] boolValue] == YES)
            {
                PostConfirmViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"postConfirmView"];
                vc.postedImage = self.post_image;
                KGModal *kgm = [KGModal sharedInstance];
                vc.delegate = kgm;
                [kgm showWithContentViewController:vc andAnimated:YES];
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
                [AlertManager showErrorMessage:msg];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [self navigationItem].rightBarButtonItem = postBtn;
            
            //[AlertManager showErrorMessage:@"Connection failure"];
        }];
        
        
    }
    
}

- (IBAction)onOne:(UIButton *)sender {
    if (!sender.selected) {
        sender.selected = !sender.selected;
        
        self.selecteBtn.selected = NO;
        self.selecteBtn = sender;
        
        price = 1;
    }
}

- (IBAction)onTwo:(UIButton *)sender {
    if (!sender.selected) {
        sender.selected = !sender.selected;
        
        self.selecteBtn.selected = NO;
        self.selecteBtn = sender;
        
        price = 2;
    }
}

- (IBAction)onThree:(UIButton *)sender {
    if (!sender.selected) {
        sender.selected = !sender.selected;
        
        self.selecteBtn.selected = NO;
        self.selecteBtn = sender;
        
        price = 3;
    }
}

- (IBAction)onFour:(UIButton *)sender {
    if (!sender.selected) {
        sender.selected = !sender.selected;
        
        self.selecteBtn.selected = NO;
        self.selecteBtn = sender;
        
        price = 4;
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self.textFieldDishName resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textFieldDishName resignFirstResponder];
    return YES;
}
- (IBAction)textFieldDishNameChanged:(id)sender {
    
    //postBtn.enabled = ([self.textFieldDishName.text length] > 0);
    
}

@end
