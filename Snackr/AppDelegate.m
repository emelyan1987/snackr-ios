//
//  AppDelegate.m
//  Snackr
//
//  Created by Snackr on 8/10/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "AppDelegate.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "AFNetworking.h"
#import "BackEndManager.h"

#import "Restaurant.h"
#import "Dish.h"

#import "NSMutableArray+Queue.h"
#import "AlertManager.h"
#import <PinterestSDK/PinterestSDK.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>



@import GoogleMaps;

@interface AppDelegate ()
{
    UINavigationController *nav_vc;
    UIStoryboard *storyboard;
    
    
    NSString *loginType;
    NSString *email;
    NSString *referralCode;
    NSString *zipCode;
    
    BOOL isEnableLocation;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    CLLocationCoordinate2D currentCoordinate;
    
    NSString *phoneZipCode;
    
    NSMutableArray *restaurants;
    
    
    int currentPage;
    BOOL isLoadingPhoto;
    BOOL hadShowedAwayAlert;
    
}@end

const NSString *GMSAPIKey = @"AIzaSyCwnjJk0eQCSik-GA7y042Rd9FtIoWAHzo";
const NSString *PinterestAppId = @"4792547218840095487";
const NSString *TwitterConsumerKey = @"HDZyFChwX98mRy0KlrUHxTq4E";
const NSString *TwitterConsumerSecret = @"V37IhwQfjjNHmtj2CyY6q91EsWFofOIhx065jpskSXC6DtYHr1";

#define FEED_PAGE_SIZE 25

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GMSServices provideAPIKey:GMSAPIKey];
    
    // Override point for customization after application launch.
    
/*
    NSArray *fontFamilies = [UIFont familyNames];
    
    for (int i = 0; i < [fontFamilies count]; i++)
    {
        NSString *fontFamily = [fontFamilies objectAtIndex:i];
        NSArray *fontNames = [UIFont fontNamesForFamilyName:[fontFamilies objectAtIndex:i]];
        NSLog (@"%@: %@", fontFamily, fontNames);
    }
*/
    
    CGSize iOSScreenSize = [[UIScreen mainScreen] bounds].size;
    
    
    
    
    if (iOSScreenSize.height == 568) {
        self.isWhatStoryboard = 1;
        storyboard = [UIStoryboard storyboardWithName:@"Main_5s" bundle:nil];
    }
    
    if (iOSScreenSize.height == 667) {
        self.isWhatStoryboard = 2;
        storyboard = [UIStoryboard storyboardWithName:@"Main_6" bundle:nil];
    }
    
    if (iOSScreenSize.height >= 736) {
        self.isWhatStoryboard = 3;
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    }
    
    if (iOSScreenSize.height == 480) {
        self.isWhatStoryboard = 4;
        storyboard = [UIStoryboard storyboardWithName:@"Main_4s" bundle:nil];
    }
    
    
    nav_vc = [storyboard instantiateViewControllerWithIdentifier:@"parent_nav"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = nav_vc;
    [self.window makeKeyAndVisible];
    
    
    
    // load enable location state from persist
    isEnableLocation = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enableLocation"] boolValue];
    
    
    if(isEnableLocation)
    [self startUpdatingLocation];
    //[self updateCurrentLocation];
    
    hadShowedAwayAlert = NO;
    self.dishes = [[NSMutableArray alloc] init];
    
    [PDKClient configureSharedInstanceWithAppId:PinterestAppId];
    
    [[Twitter sharedInstance] startWithConsumerKey:TwitterConsumerKey consumerSecret:TwitterConsumerSecret];
    [Fabric with:@[[Twitter sharedInstance]]];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+(instancetype)sharedInstance
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}
-(void)setLoginType:(NSString *)type
{
    loginType = type;
}
-(NSString*)getLoginType
{
    return loginType;
}
-(void)setEmail:(NSString *)emailString
{
    email = emailString;
}
-(NSString*)getEmail
{
    return email;
}
-(void)setReferralCode:(NSString *)code
{
    referralCode = code;
}
-(NSString*)getReferralCode
{
    return referralCode;
}
-(void)setZipCode:(NSString *)code
{
    zipCode = code;
}
-(NSString*)getZipCode
{
    return zipCode;
}
-(void)setPhoneZipCode:(NSString*)code
{
    phoneZipCode = code;
}
-(NSString*)getPhoneZipCode
{
    return phoneZipCode;
}
-(void)setEnableLocation:(BOOL)enabled
{
    if(enabled)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"enableLocation"];
        [self startUpdatingLocation];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"enableLocation"];
        [self stopUpdatingLocation];
    }
    
    isEnableLocation = enabled;
}
-(BOOL)isEnableLocation
{
    return isEnableLocation;
}
//******************* Facebook relation code *******************


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

//****************** Location Relation code ********************
//------------ Current Location Address-----
-(void)startUpdatingLocation
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        return;
    }
    //---- For getting current gps location
    if(locationManager == nil)
    {
        locationManager = [CLLocationManager new];
        locationManager.delegate = self;
        //locationManager.distanceFilter = kCLDistanceFilterNone;
        //locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 10.0f;
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [locationManager requestWhenInUseAuthorization];
        }
    }
    
    [locationManager startUpdatingLocation];
    //------
}
-(void)stopUpdatingLocation
{
    if(locationManager != nil)
        [locationManager stopUpdatingLocation];
}
/*- (void)locationManager:(CLLocationManager *)manager
 didUpdateToLocation:(CLLocation *)newLocation
 fromLocation:(CLLocation *)oldLocation
 {
 // if the location is older than 30s ignore
 if (fabs([newLocation.timestamp timeIntervalSinceDate:[NSDate date]]) > 30 )
 {
 return;
 }
 
 currentLocationCoordinate = [newLocation coordinate];
 
 
 
 // after recieving a location, stop updating
 //[self stopUpdatingCurrentLocation];
 }*/
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    currentLocation = [locations objectAtIndex:0];
    
    if (fabs([currentLocation.timestamp timeIntervalSinceDate:[NSDate date]]) > 30 )
    {
        return;
    }
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             //NSLog(@"\nCurrent Location Detected\n");
             NSLog(@"placemark %@",placemark);
             //NSLog(@"name: %@", [placemark name]);
             //NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             //NSString *Address = [[NSString alloc]initWithString:locatedAt];
             //NSString *Area = [[NSString alloc]initWithString:placemark.locality];
             //NSString *Country = [[NSString alloc]initWithString:placemark.country];
             //NSString *CountryArea = [NSString stringWithFormat:@"%@, %@", Area,Country];
             
             currentLocation = placemark.location;
             currentCoordinate = currentLocation.coordinate;
             //NSLog(@"%@",CountryArea);
             
             phoneZipCode = placemark.postalCode;
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
             //return;
             
         }
         /*---- For more results
          placemark.region);
          placemark.country);
          placemark.locality);
          placemark.name);
          placemark.ocean);
          placemark.postalCode);
          placemark.subLocality);
          placemark.location);
          ------*/
     }];
}

-(void)getCurrentCoordinate:(void (^)(CLLocationCoordinate2D coordinate, NSError *error))completeHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(currentCoordinate.latitude != 0 && currentCoordinate.longitude != 0)
        {
            completeHandler(currentCoordinate, nil);
            return;
        }
        
        [locationManager requestWhenInUseAuthorization];
        
        GMSPlacesClient *_placesClient = [[GMSPlacesClient alloc] init];
        [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *placeLikelihoodList, NSError *error){
            if (error != nil || placeLikelihoodList == nil) {
                NSLog(@"Pick Place error %@", [error localizedDescription]);
                completeHandler(currentCoordinate, error);
                return;
            }
            
            
            NSString *placeName;
            NSString *addressLabel;
            if (placeLikelihoodList != nil) {
                GMSPlace *place = [[[placeLikelihoodList likelihoods] firstObject] place];
                if (place != nil) {
                    placeName = place.name;
                    addressLabel = [[place.formattedAddress componentsSeparatedByString:@", "]
                                    componentsJoinedByString:@"\n"];
                    
                    NSLog([NSString stringWithFormat:@"Place Name: %@", placeName]);
                    NSLog([NSString stringWithFormat:@"Address Label: %@", addressLabel]);
                    NSLog([NSString stringWithFormat:@"GMSPlace: %@", place]);
                    
                    currentCoordinate = place.coordinate;
                    completeHandler(currentCoordinate, nil);
                }
            }
        }];
    });    
}
-(CLLocation*)getCurrentLocation
{
    
    return currentLocation;
}
-(void) updateCurrentLocation
{
    [locationManager requestWhenInUseAuthorization];
     
     GMSPlacesClient *_placesClient = [[GMSPlacesClient alloc] init];
     [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *placeLikelihoodList, NSError *error){
         if (error != nil) {
             NSLog(@"Pick Place error %@", [error localizedDescription]);
             return;
         }
     
     
         NSString *placeName;
         NSString *addressLabel;
         if (placeLikelihoodList != nil) {
                GMSPlace *place = [[[placeLikelihoodList likelihoods] firstObject] place];
                if (place != nil) {
                        placeName = place.name;
                        addressLabel = [[place.formattedAddress componentsSeparatedByString:@", "]
                                        componentsJoinedByString:@"\n"];
     
                    NSLog([NSString stringWithFormat:@"Place Name: %@", placeName]);
                    NSLog([NSString stringWithFormat:@"Address Label: %@", addressLabel]);
                    NSLog([NSString stringWithFormat:@"GMSPlace: %@", place]);
                }
         }
     }];
}
//-(NSMutableArray*)getRestaurants
//{
//    return restaurants;
//}


-(void) loadDish:(BOOL)isInitialize successHandler:(void (^)(NSMutableArray *array))success failureHandler:(void (^)(NSString *errorMsg))failure
{
    if(isInitialize == YES) currentPage = 0;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager.requestSerializer setTimeoutInterval:20];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    int start = currentPage * FEED_PAGE_SIZE;
    
    [params setObject:[NSNumber numberWithInt:start] forKey:@"start"];
    
    
    if([[AppDelegate sharedInstance] isEnableLocation]) {
        [[AppDelegate sharedInstance] getCurrentCoordinate:^(CLLocationCoordinate2D coordinate, NSError *error){
            if(error != nil)
            {
                if(failure != nil)
                    failure(@"Couldn't get your current location.");
                return;
            }
            
            //if([[AppDelegate sharedInstance] getCurrentLocation] != nil){
                
                NSString *location = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
                
                [params setObject:location forKey:@"location"];
            //} else {
                //if(failure != nil)
                    //failure(@"Location is enabled but couldn't get location info on your phone.");
                //return;
            //}
            
            //[params setObject:@"42.921076,129.528810" forKey:@"location"];
            isLoadingPhoto = YES;
            [manager GET:[BackEndManager getFullUrlString:@"dish/feed1"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                
                NSDictionary *jsonResult = (NSDictionary*)responseObject;
                
                
                if([[jsonResult objectForKey:@"success"] boolValue] == YES)
                {
                    NSDictionary *dicData = [jsonResult objectForKey:@"data"];
                    if(dicData.count == 0) {
                        currentPage = 0;
                        isLoadingPhoto = NO;
                        
                        if(failure != nil)
                        {
                            if(self.feedLoadingStatus!=1 && self.feedLoadingStatus!=2) self.feedLoadingStatus = 1; // the frag for showing "There are no more photos posted at this time" popup alert.
                            failure(@"Sorry, there are no more photos posted at this time.");                           
                            
                        }
                        return;
                    }
                    
                    for (NSDictionary *dicItem in dicData) {
                        Dish *dish = [[Dish alloc] init];
                        dish.no = [[dicItem objectForKey:@"dish_id"] intValue];
                        dish.title = [dicItem objectForKey:@"dish_title"];
                        NSString *price = [dicItem objectForKey:@"price"];
                        if(![price isEqual:[NSNull null]])
                            dish.price = [price doubleValue];
                        NSString *photoUrl = [dicItem objectForKey:@"photo"];
                        dish.photoUrl = photoUrl;
                        dish.distance = [dicItem objectForKey:@"distance"];
                        
                        Restaurant *rest = [[Restaurant alloc] init];
                        rest.no = [[dicItem objectForKey:@"restaurant_id"] intValue];
                        rest.title = [dicItem objectForKey:@"restaurant_title"];
                        NSString *tel = [dicItem objectForKey:@"tel"];
                        rest.tel = [tel isEqual:[NSNull null]] ? @"" : tel;
                        rest.address = [dicItem objectForKey:@"address"];
                        rest.location = [dicItem objectForKey:@"location"];
                        //NSLog([NSString stringWithFormat:@"Restaurant Location : %@", rest.location]);
                        
                        rest.zipCode = [dicItem objectForKey:@"zip_code"];
                        dish.restaurant = rest;
                        
                        [self.dishes enqueue:dish];
                    }
                    
                    NSString *msg = [jsonResult objectForKey:@"msg"];
                    if(msg.length > 0 && !hadShowedAwayAlert) {
                        [AlertManager showInfoMessage:msg];
                        hadShowedAwayAlert = YES;
                    }
                    if(success!=nil)
                        success(self.dishes);
                    
                    
                } else {
                    NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
                    [AlertManager showErrorMessage:msg];
                }
                
                isLoadingPhoto = NO;
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                
                //[AlertManager showErrorMessage:@"Connection failure"];
                isLoadingPhoto = NO;
            }];
            currentPage ++;
        }];
        
    } else {
        NSString *zipCode = [[AppDelegate sharedInstance] getZipCode];
        if(zipCode != nil && ![zipCode isEqualToString:@""]){
            [params setObject:[[AppDelegate sharedInstance] getZipCode] forKey:@"zip_code"];
        } else {
            if(failure != nil)
                failure(@"You have to go to Settings and input zip code.");
            return;
        }
        
        //[params setObject:@"42.921076,129.528810" forKey:@"location"];
        isLoadingPhoto = YES;
        [manager GET:[BackEndManager getFullUrlString:@"dish/feed"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            NSDictionary *jsonResult = (NSDictionary*)responseObject;
            
            
            if([[jsonResult objectForKey:@"success"] boolValue] == YES)
            {
                NSDictionary *dicData = [jsonResult objectForKey:@"data"];
                if(dicData.count == 0) {
                    currentPage = 0;
                    isLoadingPhoto = NO;
                    
                    if(failure != nil)
                    {
                        if(self.feedLoadingStatus!=1 && self.feedLoadingStatus!=2) self.feedLoadingStatus = 1; // the frag for showing "There are no more photos posted at this time" popup alert.

                        failure(@"Sorry, there are no more photos posted at this time.");
                    }
                    return;
                }
                
                for (NSDictionary *dicItem in dicData) {
                    Dish *dish = [[Dish alloc] init];
                    dish.no = [[dicItem objectForKey:@"dish_id"] intValue];
                    dish.title = [dicItem objectForKey:@"dish_title"];
                    NSString *price = [dicItem objectForKey:@"price"];
                    if(![price isEqual:[NSNull null]])
                        dish.price = [price doubleValue];
                    NSString *photoUrl = [dicItem objectForKey:@"photo"];
                    dish.photoUrl = photoUrl;
                    dish.distance = [dicItem objectForKey:@"distance"];
                    
                    Restaurant *rest = [[Restaurant alloc] init];
                    rest.no = [[dicItem objectForKey:@"restaurant_id"] intValue];
                    rest.title = [dicItem objectForKey:@"restaurant_title"];
                    NSString *tel = [dicItem objectForKey:@"tel"];
                    rest.tel = [tel isEqual:[NSNull null]] ? @"" : tel;
                    rest.address = [dicItem objectForKey:@"address"];
                    rest.location = [dicItem objectForKey:@"location"];
                    //NSLog([NSString stringWithFormat:@"Restaurant Location : %@", rest.location]);
                    
                    rest.zipCode = [dicItem objectForKey:@"zip_code"];
                    dish.restaurant = rest;
                    
                    [self.dishes enqueue:dish];
                }
                
                NSString *msg = [jsonResult objectForKey:@"msg"];
                if(msg.length > 0 && !hadShowedAwayAlert) {
                    [AlertManager showInfoMessage:msg];
                    hadShowedAwayAlert = YES;
                }
                if(success!=nil)
                    success(self.dishes);
                
                
            } else {
                NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
                [AlertManager showErrorMessage:msg];
            }
            
            isLoadingPhoto = NO;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            
            //[AlertManager showErrorMessage:@"Connection failure"];
            isLoadingPhoto = NO;
        }];
        currentPage ++;
    }
    
}


-(BOOL) isLoadingPhoto
{
    return isLoadingPhoto;
}
-(void) setCookie:(NSString *)email password:(NSString *)password
{
    if(email==nil || email.length==0) return;
    if(password==nil || password.length==0) return;
    
    NSDictionary *cookie = @{@"email": email, @"password": password};
    [[NSUserDefaults standardUserDefaults] setValue:cookie forKey:@"cookie"];
}

-(void) deleteCookie
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cookie"];
}

-(NSDictionary*) getCookie
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [[PDKClient sharedInstance] handleCallbackURL:url];
}
@end
