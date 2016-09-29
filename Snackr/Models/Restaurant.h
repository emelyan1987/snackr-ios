//
//  Restaurant.h
//  Snackr
//
//  Created by Matko Lajbaher on 9/10/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Restaurant : NSObject
@property (nonatomic, assign) int no;
@property (nonatomic, strong) NSString *placeId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *tel;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *zipCode;
@property (nonatomic, strong) NSString *descript;
@end
