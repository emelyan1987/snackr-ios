//
//  MySubmissionDetailViewController.m
//  Snackr
//
//  Created by Snackr on 8/20/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "MySubmissionDetailViewController.h"
#import "ASFSharedViewTransition.h"
#import "UIImageView+Network.h"
#import "BackEndManager.h"

@interface MySubmissionDetailViewController ()
{
    CLLocationCoordinate2D location;
}
@end

@implementation MySubmissionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *photoUrlString = self.dish.photoUrl;
    NSURL *imageURL = [NSURL URLWithString:[BackEndManager getFullUrlString:[NSString stringWithFormat:@"uploads/%@", photoUrlString]]];
    [self.food_photo loadImageFromURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder.png"] cachingKey:photoUrlString];
    
    self.labelTel.text = self.dish.restaurant.tel;
    self.labelAddress.text = self.dish.restaurant.address;
    
    if(self.dish.price == 0){
        self.labelPrice.text = @"";
    } else if(self.dish.price == 1){
        self.labelPrice.text = @"$";
    } else if(self.dish.price == 2){
        self.labelPrice.text = @"$$";
    } else if(self.dish.price == 3){
        self.labelPrice.text = @"$$$";
    } else if(self.dish.price == 4){
        self.labelPrice.text = @"$$$$";
    }
    [self.btnLocation setTitle:self.dish.restaurant.title forState:UIControlStateNormal];
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    // the location object that we want to initialize based on the string
    
    
    // split the string by comma
    NSArray * locationArray = [self.dish.restaurant.location componentsSeparatedByString: @","];
    
    // set our latitude and longitude based on the two chunks in the string
    location.latitude = [[locationArray objectAtIndex:0] doubleValue];
    location.longitude = [[locationArray objectAtIndex:1] doubleValue];
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.latitude
                                                            longitude:location.longitude
                                                                 zoom:15];
    //self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    
    //self.viewMap = mapView_;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    marker.title = self.dish.restaurant.title;
    //marker.snippet = @"Australia";
    marker.map = self.mapView;
    
    [UIView animateWithDuration:0.3 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.detailView.frame = CGRectMake(0, self.view.frame.size.height-self.detailView.frame.size.height, self.detailView.frame.size.width, self.detailView.frame.size.height);
        
        // layout
        CGRect viewRect = self.detailView.frame;
        CGRect telRect, addressRect, priceRect, mapRect;
        self.labelTel.numberOfLines = 1; [self.labelTel sizeToFit]; telRect = self.labelTel.frame;
        self.labelAddress.numberOfLines = 0; [self.labelAddress sizeToFit]; addressRect = self.labelAddress.frame;
        self.labelPrice.numberOfLines = 1; [self.labelPrice sizeToFit]; priceRect = self.labelPrice.frame;
        
        [self.labelTel setFrame:CGRectMake(10, 60, viewRect.size.width - 20, telRect.size.height)];
        
        CGFloat addressY = self.labelTel.frame.origin.y + self.labelTel.frame.size.height;
        if(self.labelTel.frame.size.height > 0) addressY += 10;
        [self.labelAddress setFrame:CGRectMake(35, addressY, viewRect.size.width - 70, addressRect.size.height)];
        
        CGFloat priceY = self.labelAddress.frame.origin.y + self.labelAddress.frame.size.height;
        if(self.labelAddress.frame.size.height > 0) priceY += 10;
        [self.labelPrice setFrame:CGRectMake(10, priceY, viewRect.size.width - 20, priceRect.size.height)];
        
        mapRect = self.mapView.frame;
        
        CGFloat mapY = self.labelPrice.frame.origin.y + self.labelPrice.frame.size.height;
        if(self.labelPrice.frame.size.height > 0) mapY += 15;
        
        [self.mapView setFrame:CGRectMake(mapRect.origin.x, mapY, mapRect.size.width, mapRect.size.height + mapRect.origin.y - mapY)];
        
        
        // Set tap gesture
        self.labelAddress.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureOnAddress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addressTap)];
        [self.labelAddress addGestureRecognizer:tapGestureOnAddress];
        
        self.labelTel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureOnTel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(telTap)];
        [self.labelTel addGestureRecognizer:tapGestureOnTel];
        [self.labelTel setFrame:CGRectMake(10, 60, viewRect.size.width - 20, telRect.size.height)];
        
        
    } completion:^(BOOL finish){
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.topView.frame = CGRectMake(0, 0, self.topView.frame.size.width, self.topView.frame.size.height);
        }completion:nil];
    }];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.food_photo addGestureRecognizer:singleTap];
    [self.food_photo setUserInteractionEnabled:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.topView.blurRadius = 20;
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

- (IBAction)onBack:(id)sender {
    [self doBack];
}
- (void)photoTapped:(UIGestureRecognizer *)gestureRecognizer {
    [self doBack];
}
-(void) doBack
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.detailView.frame = CGRectMake(0, 800, self.detailView.frame.size.width, self.detailView.frame.size.height);
        self.topView.frame = CGRectMake(0, -55, self.topView.frame.size.width, self.topView.frame.size.height);
    } completion:^(BOOL finish){
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
- (IBAction)onBackLikeFeed:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)addressTap
{
    self.labelAddress.alpha = 0;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.labelAddress.alpha = 1;
                         NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f&zoom=%d", location.latitude,location.longitude, 17]];
                         if (![[UIApplication sharedApplication] canOpenURL:url]) {
                             NSLog(@"Google Maps app is not installed");
                             //left as an exercise for the reader: open the Google Maps mobile website instead!
                             
                             
                             [[UIApplication sharedApplication] openURL:[NSURL
                                                                         URLWithString:[NSString stringWithFormat:@"https://www.google.com/maps/place/%f+%f/@%f,%f,%dz", location.latitude, location.longitude, location.latitude, location.longitude, 17]]];
                         } else {
                             [[UIApplication sharedApplication] openURL:url];
                         }
                     }
                     completion:nil];
}

-(void)telTap
{
    self.labelTel.alpha = 0;
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.labelTel.alpha = 1;
                         NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f&zoom=%d", location.latitude,location.longitude, 17]];
                         if (![[UIApplication sharedApplication] canOpenURL:url]) {
                             NSLog(@"Google Maps app is not installed");
                             //left as an exercise for the reader: open the Google Maps mobile website instead!
                             
                             
                             [[UIApplication sharedApplication] openURL:[NSURL
                                                                         URLWithString:[NSString stringWithFormat:@"https://www.google.com/maps/place/%f+%f/@%f,%f,%dz", location.latitude, location.longitude, location.latitude, location.longitude, 17]]];
                         } else {
                             [[UIApplication sharedApplication] openURL:url];
                         }
                     }
                     completion:nil];
    
    
}
#pragma mark - ASFSharedViewTransitionDataSource


- (UIView *)sharedView
{
    return self.food_photo;
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
