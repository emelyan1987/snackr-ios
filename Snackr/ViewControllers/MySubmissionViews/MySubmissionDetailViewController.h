//
//  MySubmissionDetailViewController.h
//  Snackr
//
//  Created by Snackr on 8/20/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"
#import "Dish.h"
@import GoogleMaps;

@interface MySubmissionDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *food_photo;
@property UIImage *image;

@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet FXBlurView *topView;

@property (weak, nonatomic) IBOutlet UILabel *labelTel;
@property (weak, nonatomic) IBOutlet UILabel *labelAddress;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UIButton *btnLocation;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property Dish *dish;
@end
