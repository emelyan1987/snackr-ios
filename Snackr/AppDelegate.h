	//
//  AppDelegate.h
//  Snackr
//
//  Created by Snackr on 8/10/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) BOOL isCropForProfile;

@property NSInteger isWhatStoryboard;

@property NSMutableArray *dishes;

@property int feedLoadingStatus;

+(instancetype)sharedInstance;
-(void)setLoginType:(NSString*)type;
-(NSString*)getLoginType;
-(void)setEmail:(NSString*)emailString;
-(NSString*)getEmail;
-(void)setReferralCode:(NSString*)code;
-(NSString*)getReferralCode;
-(void)setZipCode:(NSString*)code;
-(NSString*)getZipCode;
-(void)setPhoneZipCode:(NSString*)code;
-(NSString*)getPhoneZipCode;
-(void)setEnableLocation:(BOOL)enabled;
-(BOOL)isEnableLocation;

-(void)getCurrentCoordinate:(void (^)(CLLocationCoordinate2D coordinate, NSError *error))completeHandler;
-(CLLocation*)getCurrentLocation;


//-(NSMutableArray*)getRestaurants;

-(void) loadDish:(BOOL)isInitialize successHandler:(void (^)(NSMutableArray *array))success failureHandler:(void(^)(NSString *errorMsg))failure;

-(void) setCookie:(NSString*)email password:(NSString*)password;
-(void) deleteCookie;
-(NSDictionary*) getCookie;

-(BOOL) isLoadingPhoto;



@end

