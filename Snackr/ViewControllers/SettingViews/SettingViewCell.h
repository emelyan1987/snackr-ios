//
//  SettingViewCell.h
//  Snackr
//
//  Created by Snackr on 8/20/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingViewCellDelegate <NSObject>

-(void) onEnableLocation;

@end

@interface SettingViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UIImageView *arrowFlag;

@property (weak, nonatomic) IBOutlet UISwitch *enableBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;


@property (nonatomic, strong) id<SettingViewCellDelegate> delegate;

- (IBAction)changedLocationState:(id)sender;
@end
