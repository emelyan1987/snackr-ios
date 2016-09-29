//
//  Dish.h
//  Snackr
//
//  Created by Matko Lajbaher on 9/10/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Restaurant.h"

@interface Dish : NSObject
@property int no;
@property NSString *photoUrl;
@property NSString *title;
@property double price;
@property NSString *distance;
@property Restaurant *restaurant;
@property NSDate *createdTime;
@property int views;
@property int likes;

@property UIImage *photo;

-(UIImage*) getImage;
@end
