//
//  AssetsGroupViewCell.h
//  InstagramPhotoPicker
//
//  Created by Brendan Zhou on 13/03/2015.
//  Copyright (c) 2015 wenzhaot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AssetsGroupViewCell : UITableViewCell

- (void)bind:(ALAssetsGroup *)assetsGroup showNumberOfAssets:(BOOL)showNumberOfAssets;

@end
