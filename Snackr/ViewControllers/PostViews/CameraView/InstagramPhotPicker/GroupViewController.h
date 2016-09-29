//
//  GroupViewController.h
//  Pods
//
//  Created by Brendan Zhou on 13/03/2015.
//
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define kDidSelectPhotoNotification @"kDidSelectPhotoNotification"

@interface GroupViewController : UIViewController

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@end
