//
//  PostViewController.h
//  Snackr
//
//  Created by Snackr on 8/25/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Restaurant.h"

@interface PostViewController : UIViewController <UITextFieldDelegate>

@property UIImage *post_image;
@property Restaurant *restaurant;

@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldDishName;

@property UIButton *selecteBtn;

@end
