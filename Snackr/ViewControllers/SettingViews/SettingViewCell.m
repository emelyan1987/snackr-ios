//
//  SettingViewCell.m
//  Snackr
//
//  Created by Snackr on 8/20/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "SettingViewCell.h"
#import "AppDelegate.h"
#import "AlertManager.h"

@implementation SettingViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (IBAction)changedLocationState:(id)sender {
    UISwitch *stateSwitch = (UISwitch*)sender;
    if(stateSwitch.isOn)
    {
        [[AppDelegate sharedInstance] setEnableLocation:YES];    }
    else
    {
        [[AppDelegate sharedInstance] setEnableLocation:NO];
        
        NSString *zipCode = [[AppDelegate sharedInstance] getZipCode];
        if(zipCode == nil || zipCode.length==0)
        {
            [AlertManager showInfoMessage:@"In order to find delicious dishes around you, please enter a zip code"];
        }

    }
    
    [[AppDelegate sharedInstance] loadDish:YES successHandler:nil failureHandler:nil];
}
@end
