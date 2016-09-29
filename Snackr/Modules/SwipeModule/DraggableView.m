//
//  DraggableView.m
//  testing swiping
//
//  Created by Richard Kim on 5/21/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests

#define ACTION_MARGIN 120 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle


#import "DraggableView.h"
#import "AppDelegate.h"
#import "SwipeDownCommentController.h"
#import "ConfigManager.h"
#import "ShareModalViewController.h"
#import "BackEndManager.h"
#import "AlertManager.h"
#import "AFNetworking.h"
#import "UIImageView+Network.h"
#import "BackEndManager.h"
#import "FlagPostCommentViewController.h"
#import "MBProgressHUD.h"

@implementation DraggableView 
{
    CGFloat xFromCenter;
    CGFloat yFromCenter;
    
    BOOL isDowned;
    BOOL isFirst;
    BOOL isShowedAlert;
    
    CLLocationCoordinate2D location;
    
    MBProgressHUD *HUD;

}

//delegate is instance of ViewController
@synthesize delegate;

@synthesize panGestureRecognizer;
@synthesize information;
@synthesize overlayView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        
        information = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, self.frame.size.width, 100)];
        information.text = @"no info given";
        [information setTextAlignment:NSTextAlignmentCenter];
        information.textColor = [UIColor blackColor];
        
        self.backgroundColor = [UIColor whiteColor];
        
        panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
        
        [self addGestureRecognizer:panGestureRecognizer];
        [self addSubview:information];
        
        
        
    }
    return self;
}

- (void) initView{
    self.backgroundColor = [UIColor clearColor];
    
    panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
    
    [self addGestureRecognizer:panGestureRecognizer];
    
    overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-50, self.food_photo.frame.size.height/2, 100, 100)];
    overlayView.backgroundColor = [UIColor clearColor];
    overlayView.alpha = 1.0f;
//    overlayView.hidden = YES;
    [self addSubview:overlayView];
    
    [self.scrollview setContentSize:CGSizeMake(self.frame.size.width, self.upView.frame.size.height+self.downView.frame.size.height+38)];

    
    isFirst = YES;
    isDowned = YES;
    
    isShowedAlert = NO;
    
    
    
    
}

-(void)setupView
{
    self.layer.cornerRadius = 4;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(1, 1);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//%%% called when you move your finger across the screen.
// called many times a second

-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:self].x; //%%% positive for right swipe, negative for left
    yFromCenter = [gestureRecognizer translationInView:self].y; //%%% positive for up, negative for down
    
//    if ( yFromCenter < 0 && xFromCenter > 0) {
//        if (fabs(xFromCenter) < fabs(yFromCenter)) {
//            return;
//        }
//    }
//    
//    if ( yFromCenter < 0 && xFromCenter < 0) {
//        if (fabs(xFromCenter) < fabs(yFromCenter)) {
//            return;
//        }
//    }
    
    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            //%%% degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            //%%% amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            
            //%%% move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
            
            //%%% rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            //%%% scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            //%%% apply transformations
            self.transform = scaleTransform;
            [self updateOverlay:xFromCenter : yFromCenter];
            
            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            [self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

// checks to see if you are moving right or left and applies the correct overlay image
-(void)updateOverlay:(CGFloat)distance : (CGFloat) y
{
    if (distance > 0 && y < 0) {
        if (fabs(distance) > fabs(y)) {
            overlayView.mode = GGOverlayViewModeRight;
            overlayView.backgroundColor = [UIColor clearColor];
            overlayView.alpha = 1.0f;
        } else{
            overlayView.mode = GGOverlayViewModeTop;
        }
    }else if(distance > 0 && y > 0) {
        if (fabs(distance) > fabs(y)) {
            overlayView.mode = GGOverlayViewModeRight;
            overlayView.backgroundColor = [UIColor clearColor];
            overlayView.alpha = 1.0f;
        } else{
            overlayView.mode = GGOverlayViewModeDown;
        }
    } else if (distance < 0 && y < 0){
        if (fabs(distance) > fabs(y)) {
            overlayView.mode = GGOverlayViewModeLeft;
            overlayView.backgroundColor = [UIColor clearColor];
            overlayView.alpha = 1.0f;
        } else{
            overlayView.mode = GGOverlayViewModeTop;
        }
    }else if (distance < 0 && y > 0){        
        if (fabs(distance) > fabs(y)) {
            overlayView.mode = GGOverlayViewModeLeft;
            overlayView.backgroundColor = [UIColor clearColor];
            overlayView.alpha = 1.0f;
        } else{
            overlayView.mode = GGOverlayViewModeDown;
        }
    } else{
        return;
    }
    
    
}

//%%% called when the card is let go
- (void)afterSwipeAction
{
    if (overlayView.mode == GGOverlayViewModeTop) {
        overlayView.alpha = 0;
        if (yFromCenter < -ACTION_MARGIN)
            [self topAction];
        else //%%% resets the card
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.center = self.originalPoint;
                                 self.transform = CGAffineTransformMakeRotation(0);
                                 overlayView.alpha = 0;
                             }];

    } else if (overlayView.mode == GGOverlayViewModeDown){
        overlayView.alpha = 0;
        if (yFromCenter > 120)
            [self downAction];
        else //%%% resets the card
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.center = self.originalPoint;
                                 self.transform = CGAffineTransformMakeRotation(0);
                                 overlayView.alpha = 0;
                             }];

    } else if (overlayView.mode == GGOverlayViewModeLeft) {
        if (xFromCenter < -ACTION_MARGIN)
            [self leftAction];
        else //%%% resets the card
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.center = self.originalPoint;
                                 self.transform = CGAffineTransformMakeRotation(0);
                                 overlayView.alpha = 0;
                             }];
    } else if (overlayView.mode ==  GGOverlayViewModeRight) {
        if (xFromCenter > ACTION_MARGIN)
            [self rightAction];
        else //%%% resets the card
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.center = self.originalPoint;
                                 self.transform = CGAffineTransformMakeRotation(0);
                                 overlayView.alpha = 0;
                             }];
    } else{
        
    }

}

-(void) doTreatment:(NSString*)action
{
    Dish *dish = self.dish;
    if(dish==nil) return;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager.requestSerializer setTimeoutInterval:20];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *params = @{@"dish_id":[NSNumber numberWithInt:dish.no]};
    
    NSString *url = [NSString stringWithFormat:@"dish/%@", action];
    
    
    [manager POST:[BackEndManager getFullUrlString:url] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSDictionary *jsonResult = (NSDictionary*)responseObject;
        
        
        if([[jsonResult objectForKey:@"success"] boolValue] == YES)
        {
            
        } else {
            NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
            [AlertManager showErrorMessage:msg];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        //[AlertManager showErrorMessage:@"Connection failure"];
    }];
}
//%%% called when a swipe exceeds the ACTION_MARGIN to the right
-(void)rightAction
{
    [self doTreatment:@"like"];
    CGPoint finishPoint = CGPointMake(1000, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.7
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [delegate cardSwipedRight:self];
                     }completion:nil];
    
    NSLog(@"YES");
}

//%%% called when a swip exceeds the ACTION_MARGIN to the left
-(void)leftAction
{
    [self doTreatment:@"dislike"];
    CGPoint finishPoint = CGPointMake(-1000, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.7
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                          [delegate cardSwipedLeft:self];
                     }completion:nil];

    NSLog(@"NO");
}

- (void) topAction
{
    [UIView animateWithDuration:0.2
                         animations:^{
                             self.center = self.originalPoint;
                             self.transform = CGAffineTransformIdentity;
                         }completion:^(BOOL complete){
                            [self removeFromSuperview];
                         }];
    
    
    [delegate cardSwipedLeft:self];
}

- (void) downAction
{
    [self doTreatment:@"neversee"];
    CGPoint finishPoint = CGPointMake(self.frame.size.width/2, 2000);
    [UIView animateWithDuration:1.0
                         animations:^{
                             self.center = finishPoint;
                         }completion:^(BOOL complete){
                             [self removeFromSuperview];
                             isDowned = YES;
                        }];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [delegate cardSwipedLeft:self];
                     }completion:nil];
    
//    [delegate cardSwipedLeft:self];
}

-(void)rightClickAction
{
    CGPoint finishPoint = CGPointMake(600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
//                         self.transform = CGAffineTransformMakeRotation(1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

-(void)leftClickAction
{
    CGPoint finishPoint = CGPointMake(-600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
//                         self.transform = CGAffineTransformMakeRotation(-1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    
    if (offset > 0) {
        panGestureRecognizer.enabled = NO;
    }else {
        panGestureRecognizer.enabled = YES;
        
        if (offset < -75 && !isShowedAlert) {
            
            //if (![[ConfigManager getIsSwipeDownComment] isEqualToString:@"1"]) {
                [scrollView setContentOffset:CGPointMake(0, -76) animated:NO];
            
                NSInteger where = ((AppDelegate*)[UIApplication sharedApplication].delegate).isWhatStoryboard;
            NSString *storyboarName;
            if (where == 1) {
                storyboarName = @"Main_5s";
            } else if (where == 2){
                storyboarName = @"Main_6";
            } else if (where == 3){
                storyboarName = @"Main";
            } else if (where == 4){
                storyboarName = @"Main_4s";
            }
            
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboarName bundle:[NSBundle mainBundle]];
                SwipeDownCommentController *comment_view = [storyboard instantiateViewControllerWithIdentifier:@"swipeDownComment"];
                KGModal *kgm = [KGModal sharedInstance];
                kgm.delegateSwipe = self;
                comment_view.delegate = [KGModal sharedInstance];
                [[KGModal sharedInstance] showWithContentViewController:comment_view andAnimated:YES];
                
                [ConfigManager setIsSwipeDownComment:@"1"];
                isFirst = NO;
            
            isShowedAlert = YES;
//            } else{
//                if (isDowned) {
//                    [self downAction];
//                    isDowned = NO;
//                }
//            }
        }
    }
}

- (IBAction)onShare:(id)sender {
    
    [self doShare];
}

-(void) doShare
{
    NSInteger where = ((AppDelegate*)[UIApplication sharedApplication].delegate).isWhatStoryboard;
    UIStoryboard *storyboard;
    
    if (where == 1) {
        storyboard = [UIStoryboard storyboardWithName:@"Main_5s" bundle:[NSBundle mainBundle]];
    } else if (where == 2){
        storyboard = [UIStoryboard storyboardWithName:@"Main_6" bundle:[NSBundle mainBundle]];
    } else if (where == 3){
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    } else if (where == 4){
        storyboard = [UIStoryboard storyboardWithName:@"Main_4s" bundle:[NSBundle mainBundle]];
    }
    
    ShareModalViewController *share_view = [storyboard instantiateViewControllerWithIdentifier:@"shareModal"];
    share_view.delegate = [KGModal sharedInstance];
    share_view.photo = [self.dish getImage];
    [[KGModal sharedInstance] showWithContentViewController:share_view andAnimated:YES];
}
#pragma mark KGModalDelegateSwipe
- (void) actionAfterDone
{
    [ConfigManager setIsSwipeDownComment:@"1"];
    isFirst = NO;
    [self downAction];
    
    isShowedAlert = NO;
}

- (void) actionAfterUndo
{
    [ConfigManager setIsSwipeDownComment:@"1"];
    isFirst = NO;
    isDowned = NO;
    [self.scrollview setContentOffset:CGPointMake(0, 0) animated:YES];
    isShowedAlert = NO;
}

-(void)bindModel:(Dish *)item
{
    if(item==nil) return;
    NSString *photoUrlString = item.photoUrl;
    NSURL *imageURL = [NSURL URLWithString:[BackEndManager getFullUrlString:[NSString stringWithFormat:@"uploads/%@", photoUrlString]]];
    
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            self.food_photo.image = [UIImage imageWithData:imageData];
        });
    });*/
    [self.food_photo loadImageFromURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder.png"] cachingKey:photoUrlString];
    
    self.labelFoodName.text = item.title;
    //self.labelRestaurantName.text = item.restaurant.title;
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"locationFlag.png"];
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"   %@", item.restaurant.title]];
    
    [myString insertAttributedString:attachmentString atIndex:0];
    
    /*NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    [myString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:(NSRange){0,myString.length}];*/
    self.labelRestaurantName.attributedText = myString;
    
    
    self.labelDistance.text = [item.distance isEqualToString:@"within your zip code"]?@"":item.distance;
    
    self.labelTel.text = item.restaurant.tel;
    
    self.btnAddress.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.btnAddress.titleLabel.textAlignment = UITextAlignmentCenter;
    [self.btnAddress setTitle:item.restaurant.address forState:UIControlStateNormal];
    self.labelAddress.text = item.restaurant.address;
    
    if(item.price == 0){
        self.labelPrice.text = @"";
    } else if(item.price == 1){
        self.labelPrice.text = @"$";
    } else if(item.price == 2){
        self.labelPrice.text = @"$$";
    } else if(item.price == 3){
        self.labelPrice.text = @"$$$";
    } else if(item.price == 4){
        self.labelPrice.text = @"$$$$";
    }

    
    self.dish = item;
    
    
    // layout
    CGRect viewRect = self.downView.frame;
    CGRect telRect, addressRect, priceRect, mapRect;
    self.labelTel.numberOfLines = 1; [self.labelTel sizeToFit]; telRect = self.labelTel.frame;
    self.labelAddress.numberOfLines = 0; [self.labelAddress sizeToFit]; addressRect = self.labelAddress.frame;
    self.labelPrice.numberOfLines = 1; [self.labelPrice sizeToFit]; priceRect = self.labelPrice.frame;
    
    [self.labelTel setFrame:CGRectMake(10, 70, viewRect.size.width - 20, telRect.size.height)];
    
    CGFloat addressY = self.labelTel.frame.origin.y + self.labelTel.frame.size.height;
    if(self.labelTel.frame.size.height > 0) addressY += 15;
    [self.labelAddress setFrame:CGRectMake(50, addressY, viewRect.size.width - 100, addressRect.size.height)];
    [self.btnAddress setFrame:self.labelAddress.frame];
    //self.labelAddress.hidden = YES;
    //self.btnAddress.hidden = NO;
    self.labelAddress.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureOnAddress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addressTap)];
    [self.labelAddress addGestureRecognizer:tapGestureOnAddress];
    UITapGestureRecognizer *tapGestureOnTel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(telTap)];
    [self.labelTel addGestureRecognizer:tapGestureOnTel];
    self.labelTel.userInteractionEnabled = YES;
    CGFloat priceY = self.labelAddress.frame.origin.y + self.labelAddress.frame.size.height;
    if(self.labelAddress.frame.size.height > 0) priceY += 15;
    [self.labelPrice setFrame:CGRectMake(10, priceY, viewRect.size.width - 20, priceRect.size.height)];

    mapRect = self.mapView.frame;
    
    CGFloat mapY = self.labelPrice.frame.origin.y + self.labelPrice.frame.size.height;
    if(self.labelPrice.frame.size.height > 0) mapY += 20;
    
    /*if(self.labelPrice.frame.size.height > 0) mapY = self.labelPrice.frame.origin.y + self.labelPrice.frame.size.height + 20;
    else if(self.labelPrice.frame.size.height == 0 && self.labelAddress.frame.size.height > 0) mapY = self.labelAddress.frame.origin.y + self.labelAddress.frame.size.height + 20;
    else if(self.labelPrice.frame.size.height == 0 && self.labelAddress.frame.size.height == 0 && self.labelTel.frame.size.height > 0) mapY = self.labelTel.frame.origin.y + self.labelTel.frame.size.height + 20;
    else if(self.labelPrice.frame.size.height == 0 && self.labelAddress.frame.size.height == 0 && self.labelTel.frame.size.height == 0) mapY = self.labelTel.frame.origin.y;*/
        
    [self.mapView setFrame:CGRectMake(mapRect.origin.x, mapY, mapRect.size.width, mapRect.size.height + mapRect.origin.y - mapY)];
    
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    // the location object that we want to initialize based on the string
    //CLLocationCoordinate2D location;
    
    // split the string by comma
    NSArray * locationArray = [item.restaurant.location componentsSeparatedByString: @","];
    
    // set our latitude and longitude based on the two chunks in the string
    location.latitude = [[locationArray objectAtIndex:0] doubleValue];
    location.longitude = [[locationArray objectAtIndex:1] doubleValue];
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:location zoom:15 bearing:0 viewingAngle:0];//[GMSCameraPosition cameraWithLatitude:location.latitude longitude:location.longitude zoom:15];
    //self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    //self.mapView.camera = camera;
    //GMSMapView *mapView = [[GMSMapView alloc] initWithFrame:self.mapView.bounds];//[GMSMapView mapWithFrame:self.mapView.bounds camera: camera];
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    self.mapView.padding = mapInsets;
    //self.mapView.settings.consumesGesturesInView = YES;
    
    
    //[self.mapView addSubview: mapView];
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    marker.title = item.restaurant.title;
    //marker.snippet = @"Australia";
    marker.map = self.mapView;
    
    [self setUserInteractionEnabled:YES];
    self.scrollview.hidden = NO;
    self.messageView.hidden = YES;
    self.labelMessage.text = @"Loading photos...";
}

-(void)showErrorMessage:(NSString *)message
{
    NSLog([NSString stringWithFormat:@"Loading dish error:%@", message]);
    self.scrollview.hidden = YES;
    self.messageView.hidden = NO;
    self.labelMessage.text = message;//@"Please go to Settings and enable location or enter a zip code to view photos";
    
}

-(void)hideSwipeMark
{
    self.labelSwipeUp.hidden = YES;
    self.labelSwipeDown.hidden = YES;
    self.imageSwipeUp.hidden = YES;
    self.imageSwipeDown.hidden = YES;
}
- (IBAction)btnDotClicked:(id)sender {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Flag Post",
                            @"Share",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self doFlag];
                    break;
                case 1:
                    [self doShare];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

-(void) doFlag
{
    UIView *view = self.controller.view;
    HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    
    // Set the hud to display with a color
    
    HUD.color = [UIColor colorWithRed:222.0f/255.0f green:0 blue:35.0f/255.0f alpha:0.90];
    HUD.labelText = @"Please wait...";
    HUD.dimBackground = YES;
    
    [HUD show:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager.requestSerializer setTimeoutInterval:20];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *params = @{@"dish_id":[NSNumber numberWithInt:self.dish.no]};
    
    
    [manager POST:[BackEndManager getFullUrlString:@"dish/flag"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [HUD hide:YES];
        NSDictionary *jsonResult = (NSDictionary*)responseObject;
        
        if([[jsonResult objectForKey:@"success"] boolValue] == YES)
        {
            NSInteger where = ((AppDelegate*)[UIApplication sharedApplication].delegate).isWhatStoryboard;
            NSString *storyboarName;
            if (where == 1) {
                storyboarName = @"Main_5s";
            } else if (where == 2){
                storyboarName = @"Main_6";
            } else if (where == 3){
                storyboarName = @"Main";
            }
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboarName bundle:[NSBundle mainBundle]];
            FlagPostCommentViewController *comment_view = [storyboard instantiateViewControllerWithIdentifier:@"flagPostComment"];
            KGModal *kgm = [KGModal sharedInstance];
            
            comment_view.delegate = [KGModal sharedInstance];
            [kgm showWithContentViewController:comment_view andAnimated:YES];
        } else {
            NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
            [AlertManager showErrorMessage:msg];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HUD hide:YES];
        NSLog(@"Error: %@", error);
        
        [AlertManager showErrorMessage:@"Connection failure"];
    }];
    
    
}
- (IBAction)btnAddressClick:(id)sender {
    //Google Maps
    //construct a URL using the comgooglemaps schema
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
@end
