//
//  BCVideoCollectionViewCell.m
//  BirdCage
//
//  Created by Brendan Zhou on 2/02/2015.
//  Copyright (c) 2015 Bizar Mobile Pty Ltd. All rights reserved.
//

#import "BCVideoCollectionViewCell.h"

@implementation BCVideoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.layer.borderColor = [UIColor blueColor].CGColor;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.imageView.layer.borderWidth = selected ? 2 : 0;
}

@end
