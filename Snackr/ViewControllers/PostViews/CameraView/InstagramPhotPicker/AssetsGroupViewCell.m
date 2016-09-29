//
//  AssetsGroupViewCell.m
//  InstagramPhotoPicker
//
//  Created by Brendan Zhou on 13/03/2015.
//  Copyright (c) 2015 wenzhaot. All rights reserved.
//

#import "AssetsGroupViewCell.h"

@interface AssetsGroupViewCell ()

@property (nonatomic, strong) ALAssetsGroup* assetsGroup;

@end

@implementation AssetsGroupViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.opaque = YES;
        self.isAccessibilityElement = YES;
        self.textLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.textColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)bind:(ALAssetsGroup*)assetsGroup showNumberOfAssets:(BOOL)showNumberOfAssets;
{
    self.assetsGroup = assetsGroup;
    
    CGImageRef posterImage = assetsGroup.posterImage;
    size_t height = CGImageGetHeight(posterImage);
    float scale = height / 78.0f;
    
    self.imageView.image = [UIImage imageWithCGImage:posterImage scale:scale orientation:UIImageOrientationUp];
    self.textLabel.text = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (showNumberOfAssets)
        self.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)assetsGroup.numberOfAssets];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - Accessibility Label

- (NSString*)accessibilityLabel
{
    NSString* label = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    return [label stringByAppendingFormat:@"%ld Photos", (long)self.assetsGroup.numberOfAssets];
}

@end
