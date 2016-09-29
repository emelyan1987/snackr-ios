//
//  LocationListViewCell.m
//  Snackr
//
//  Created by Snackr on 8/25/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "LocationListViewCell.h"

@implementation LocationListViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)bindModel:(Restaurant *)item
{
    [self.labelTitle setText:item.title];
    [self.labelAddress setText:item.address];
}
@end
