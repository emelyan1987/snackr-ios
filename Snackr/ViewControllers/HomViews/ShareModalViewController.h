//
//  ShareModalViewController.h
//  Snackr
//
//  Created by Snackr on 8/19/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol shareModalDelegate <NSObject>

- (void) onShareDone;

@end

@interface ShareModalViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (nonatomic, strong) id<shareModalDelegate> delegate;
@property (nonatomic, strong) UIImage *photo;

@end
