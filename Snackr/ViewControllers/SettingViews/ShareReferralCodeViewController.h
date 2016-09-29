//
//  ShareReferralCodeViewController.h
//  Snackr
//
//  Created by Snackr on 8/21/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShareReferralCodeViewDelegate <NSObject>

-(void) onDoneShareRefferralCode;
-(void) onShareRefferalCode;

@end

@interface ShareReferralCodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (nonatomic, strong) id<ShareReferralCodeViewDelegate> delegate;

@end
