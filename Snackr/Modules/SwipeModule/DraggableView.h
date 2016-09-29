//
//  DraggableView.h
//  testing swiping
//
//  Created by Richard Kim on 5/21/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests

/*
 
 Copyright (c) 2014 Choong-Won Richard Kim <cwrichardkim@gmail.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import "OverlayView.h"
#import "KGModal.h"
#import "Dish.h"
@import GoogleMaps;

@protocol DraggableViewDelegate <NSObject>

-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;
@end

@interface DraggableView : UIView <UIScrollViewDelegate, KGModalSwipeDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIViewController *controller;

@property (weak) id <DraggableViewDelegate> delegate;

@property (nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic)CGPoint originalPoint;
@property (nonatomic,strong)OverlayView* overlayView;
@property (nonatomic,strong)UILabel* information; //%%% a placeholder for any card-specific information

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *messageView;

@property (weak, nonatomic) IBOutlet UIView *upView;
@property (weak, nonatomic) IBOutlet UIImageView *food_photo;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UILabel *labelFoodName;
@property (weak, nonatomic) IBOutlet UILabel *labelRestaurantName;
@property (weak, nonatomic) IBOutlet UILabel *labelDistance;
@property (weak, nonatomic) IBOutlet UILabel *labelTel;
@property (weak, nonatomic) IBOutlet UILabel *labelAddress;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;


@property (weak, nonatomic) IBOutlet UILabel *labelMessage;

@property (weak, nonatomic) IBOutlet UILabel *labelSwipeUp;
@property (weak, nonatomic) IBOutlet UIImageView *imageSwipeUp;
@property (weak, nonatomic) IBOutlet UILabel *labelSwipeDown;
@property (weak, nonatomic) IBOutlet UIImageView *imageSwipeDown;

@property (weak, nonatomic) IBOutlet UIButton *btnAddress;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) Dish *dish;
- (void) initView;
-(void)leftClickAction;
-(void)rightClickAction;

-(void)bindModel:(Dish*)item;
-(void)showErrorMessage:(NSString*)message;

-(void)hideSwipeMark;
@end
