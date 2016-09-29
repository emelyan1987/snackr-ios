//
//  GoToMapViewCell.m
//  Snackr
//
//  Created by Snackr on 8/25/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "GoToMapViewCell.h"

@implementation GoToMapViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.bgView.layer.cornerRadius = 5.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
