//
//  MySubmissionViewCell.h
//  Snackr
//
//  Created by Snackr on 8/20/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MySubmissionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *food_photo;
@property (weak, nonatomic) IBOutlet UILabel *labelViews;
@property (weak, nonatomic) IBOutlet UILabel *labelLiked;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@end
