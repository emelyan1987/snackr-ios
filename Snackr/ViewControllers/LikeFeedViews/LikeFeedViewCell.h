//
//  LikeFeedViewCell.h
//  Snackr
//
//  Created by Snackr on 8/20/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LikeFeedViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *food_photo;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelRestaurant;

@end
