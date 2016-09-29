//
//  HomeRootViewController.m
//  Snackr
//
//  Created by Snackr on 8/17/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "HomeRootViewController.h"

@interface HomeRootViewController ()

@end

@implementation HomeRootViewController


- (void)awakeFromNib
{
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"homeView"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuView"];
}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
