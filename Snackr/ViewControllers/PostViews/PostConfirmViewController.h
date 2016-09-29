//
//  PostConfirmViewController.h
//  Snackr
//
//  Created by Snackr on 8/25/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostConfirmViewDelegate <NSObject>

- (void) onPostConfirmDone;

@end

@interface PostConfirmViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property UIImage *postedImage;

@property (nonatomic, strong) id<PostConfirmViewDelegate> delegate;

@end
