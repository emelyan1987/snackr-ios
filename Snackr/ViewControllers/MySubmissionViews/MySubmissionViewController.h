//
//  MySubmissionViewController.h
//  Snackr
//
//  Created by Snackr on 8/20/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"

@interface MySubmissionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet FXBlurView *topView;

@property (weak, nonatomic) IBOutlet UICollectionView *myLists;

@end
