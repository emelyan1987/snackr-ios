//
//  LocationSearchViewController.m
//  Snackr
//
//  Created by Snackr on 8/25/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "LocationSearchViewController.h"
#import "LocationListViewCell.h"
#import "GoToMapViewCell.h"
#import "PostViewController.h"
#import "AddLocationViewController.h"

#import "AppDelegate.h"
#import "Restaurant.h"
#import "AFNetworking.h"
#import "BackEndManager.h"
#import "AlertManager.h"

#define ITEMS_PAGE_SIZE 20
const NSString *GMSAPIKey1 = @"AIzaSyCwnjJk0eQCSik-GA7y042Rd9FtIoWAHzo";

@interface LocationSearchViewController ()
{
    NSMutableArray *locations;
    NSMutableArray *filteredLocations;
    BOOL isFiltered;
    int currentPage;
    
    NSDate *prevTime;
    NSTimer *timer;
    
    NSString *nextPageToken;
}
@end


@implementation LocationSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setHeaderView];
    
    self.searchView.layer.cornerRadius = 5.0f;
    self.searchTxt.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchTxt.delegate = self;
    
    locations = [[NSMutableArray alloc] init];
    [self firstFetchItems];
}

-(void) firstFetchItems
{
    
    NSString *keyword = self.searchTxt.text;
    //[locations removeAllObjects];
    
    nextPageToken = nil;
    [self searchRestaurants:keyword pageToken:nextPageToken];
}
-(void) nextFetchItems
{
    NSString *keyword = self.searchTxt.text;
    [self searchRestaurants:keyword pageToken:nextPageToken];
}


-(void) searchRestaurants:(NSString *)keyword pageToken:(NSString*)pageToken
{
    // Build the url string we are going to sent to Google. NOTE: The kGOOGLE_API_KEY is a constant which should contain your own API key that you can obtain from Google. See this link for more info:
    // https://developers.google.com/maps/documentation/places/#Authentication
   
    
    if(self.navigationItem.rightBarButtonItem == nil) {
        UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        activityIndicator.color = [UIColor grayColor];
        UIBarButtonItem *loadingBtn = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        
        [activityIndicator startAnimating];
        
        [self navigationItem].rightBarButtonItem = loadingBtn;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        [[AppDelegate sharedInstance] getCurrentCoordinate:^(CLLocationCoordinate2D coordinate, NSError *error){
            if(error != nil)
            {
                [AlertManager showErrorMessage:@"Sorry, couldn't get your current location. Please try again later"];
                return;
            }
            
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:[NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude] forKey:@"location"];
            //[params setObject:[NSNumber numberWithInt:16093] forKey:@"radius"];
            [params setObject:@"distance" forKey:@"rankby"];
            //[params setObject:@"bar|food|cafe|restaurant" forKey:@"types"];
            [params setObject:@"food|restaurant" forKey:@"types"];
            [params setObject:GMSAPIKey1 forKey:@"key"];
            
            if(keyword != nil && keyword.length > 0)
                [params setObject:keyword forKey:@"keyword"];
            
            if(pageToken != nil && pageToken.length > 0) {
                [params setObject:pageToken forKey:@"pagetoken"];
                //NSLog([NSString stringWithFormat:@"next_page_token:%@", pageToken]);
                
                [NSThread sleepForTimeInterval:2];
                //[self performSelector:@selector(requestToGoogle:) withObject:params afterDelay:2];
                [self requestToGoogle:params];
            } else {
                [self requestToGoogle:params];
            }
            
        }];
        
    });
    
}

-(void)requestToGoogle:(NSMutableDictionary*)params
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager.requestSerializer setTimeoutInterval:20];
    
    NSLog([NSString stringWithFormat:@"Google Request URL: %@", params]);
    //[AlertManager showInfoMessage:[NSString stringWithFormat:@"Google Request URL: %@", params]];
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json"
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             //parse out the json data
             NSDictionary* json = (NSDictionary*)responseObject;
             
             NSLog([NSString stringWithFormat:@"Json Result: %@", json]);
             
             // if next_page_token exists, set nextPageToken
             if(nextPageToken == nil) [locations removeAllObjects];
             
             nextPageToken = [json objectForKey:@"next_page_token"];
             
             //The results from Google will be an array obtained from the NSDictionary object with the key "results".
             NSArray* places = [json objectForKey:@"results"];
             
             //Write out the data to the console.
             //NSLog(@"Google Data: %@", places);
             //if(places.count == 0) [AlertManager showErrorMessage:[NSString stringWithFormat:@"Json Response Result: %@", json]];
             
             //Loop through the array of places returned from the Google API.
             for (int i=0; i<[places count]; i++)
             {
                 //Retrieve the NSDictionary object in each index of the array.
                 NSDictionary* place = [places objectAtIndex:i];
                 
                 //There is a specific NSDictionary object that gives us location info.
                 NSDictionary *geo = [place objectForKey:@"geometry"];
                 
                 
                 //Get our name and address info for adding to a pin.
                 NSString *placeId = [place objectForKey:@"place_id"];
                 NSString *name=[place objectForKey:@"name"];
                 NSString *vicinity=[place objectForKey:@"vicinity"];
                 
                 //Get the lat and long for the location.
                 NSDictionary *loc = [geo objectForKey:@"location"];
                 
                 //Create a special variable to hold this coordinate info.
                 CLLocationCoordinate2D placeCoord;
                 
                 //Set the lat and long.
                 placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
                 placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
                 
                 Restaurant *restaurant = [[Restaurant alloc] init];
                 restaurant.placeId = placeId;
                 restaurant.title = name;
                 restaurant.address = vicinity;
                 restaurant.location = [NSString stringWithFormat:@"%f,%f", placeCoord.latitude, placeCoord.longitude];
                 //restaurant.zipCode = [dicRestaurant objectForKey:@"zip_code"];
                 //restaurant.descript = [dicRestaurant objectForKey:@"description"];
                 
                 [locations addObject:restaurant];
             }
             
             [self.locationLists reloadData];
             [self navigationItem].rightBarButtonItem = nil;
             
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [AlertManager showErrorMessage:[error localizedDescription]];
             NSLog(@"Error: %@", error);
             [self.locationLists reloadData];
             [self navigationItem].rightBarButtonItem = nil;
         }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void) setHeaderView
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backBtn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    UIBarButtonItem *nextBtn = [[UIBarButtonItem alloc]initWithTitle:@"NEXT"  style:UIBarButtonItemStylePlain target:self action:@selector(onNext)];
    //[self.navigationItem setRightBarButtonItem:nextBtn];
    
    UILabel *title = [[UILabel alloc]init];
    [title setFont:[UIFont fontWithName:@"MuseoSans-100" size:16.0f]];
    title.text = @"WHERE ARE YOU EATING?";
    title.textColor = [UIColor colorWithRed:(44.0f/255.0f) green:(44.0f/255.0f) blue:(44.0f/255.0f) alpha:1.0f];
    
    float maximumLabelSize =  [title.text boundingRectWithSize:title.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:title.font } context:nil].size.width;
    
    title.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:title];
    
    self.navigationItem.titleView = headerview;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
}

- (void) onBack {
    [self.navigationController popViewControllerAnimated:YES];
    UIColor *color = [UIColor colorWithRed:51.0/255.0 green:57.0/255.0 blue:67.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:color];
}

- (void) onNext {
    PostViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"postView"];
    vc.post_image = self.food_photo;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int rowCount;
    /*if(isFiltered)
        rowCount = (int)filteredLocations.count;
    else*/
        rowCount = (int)locations.count;
    
    return rowCount + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        GoToMapViewCell * cell =  [tableView dequeueReusableCellWithIdentifier : @"goToMapViewCell" ];
        if(cell == nil){
            cell  = [[GoToMapViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"goToMapViewCell"];
        }
        
        return cell;
        
    } else {
        NSInteger itemIndex = indexPath.item;
        if(nextPageToken != nil && itemIndex == (locations.count - ITEMS_PAGE_SIZE + 1) && itemIndex%ITEMS_PAGE_SIZE == 1){
            [self nextFetchItems];
        }

        LocationListViewCell * cell =  [tableView dequeueReusableCellWithIdentifier : @"loactionListViewCell" ];
        if(cell == nil){
            cell  = [[LocationListViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"loactionListViewCell"];
        }
        
        Restaurant *item;
        item = [locations objectAtIndex:(indexPath.row - 1)];
        
        [cell bindModel:item];
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        AddLocationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addLocationView"];
        vc.post_image = self.food_photo;
        
        
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        PostViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"postView"];
        vc.post_image = self.food_photo;
        
        Restaurant *rest;
        
        rest = [locations objectAtIndex:(indexPath.row-1)];
        
        vc.restaurant = rest;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (timer.isValid) {
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                             target: self
                                           selector: @selector(timeToSearchForStuff:)
                                           userInfo: nil
                                            repeats: NO];
    
    if(self.navigationItem.rightBarButtonItem == nil) {
        UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        activityIndicator.color = [UIColor grayColor];
        UIBarButtonItem *loadingBtn = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    
        [activityIndicator startAnimating];

        [self navigationItem].rightBarButtonItem = loadingBtn;
    }

    return YES;
}

-(void) timeToSearchForStuff:(NSTimer*)theTimer
{
    [self firstFetchItems];
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
