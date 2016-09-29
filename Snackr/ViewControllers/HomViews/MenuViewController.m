//
//  MenuViewController.m
//  Snackr
//
//  Created by Snackr on 8/17/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "MenuViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "HomeRootViewController.h"
#import "HomeViewController.h"
#import "LikeFeedViewController.h"
#import "LikeFeedDetailViewController.h"
#import "MySubmissionViewController.h"
#import "MySubmissionDetailViewController.h"
#import "ASFSharedViewTransition.h"
#import "SoccorViewController.h"

@interface MenuViewController ()
{
    UIButton *selectedBtn;
}

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    selectedBtn = self.homeBtn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeMenu:(id)sender
{
    [self.frostedViewController hideMenuViewController];
}

- (IBAction)onHome:(UIButton *)sender
{
//    if (!sender.selected) {
//        selectedBtn.selected = NO;
//        sender.selected = !sender.selected;
//        selectedBtn = sender;
//    }
    [self.frostedViewController hideMenuViewController];
}
- (IBAction)onSubmission:(UIButton *)sender
{
//    if (!sender.selected) {
//        selectedBtn.selected = NO;
//        sender.selected = !sender.selected;
//        selectedBtn = sender;
//    }
    
    UINavigationController *mySubmissionNav = [self.storyboard instantiateViewControllerWithIdentifier:@"mySubmissionViewNav"];
    
    [ASFSharedViewTransition addTransitionWithFromViewControllerClass:[MySubmissionViewController class]
                                                ToViewControllerClass:[MySubmissionDetailViewController class]
                                             WithNavigationController:mySubmissionNav
                                                         WithDuration:0.5f];
    [self.frostedViewController.contentViewController presentViewController:mySubmissionNav animated:YES completion:nil];
    [self.frostedViewController hideMenuViewController];
}

- (IBAction)onLikes:(UIButton *)sender
{
//    if (!sender.selected) {
//        selectedBtn.selected = NO;
//        sender.selected = !sender.selected;
//        selectedBtn = sender;
//    }
    
    UINavigationController *likeFeedNav = [self.storyboard instantiateViewControllerWithIdentifier:@"likeFeedNav"];
    
    [ASFSharedViewTransition addTransitionWithFromViewControllerClass:[LikeFeedViewController class]
                                                    ToViewControllerClass:[LikeFeedDetailViewController class]
                                                 WithNavigationController:likeFeedNav
                                                             WithDuration:0.5f];

    
    [self.frostedViewController.contentViewController presentViewController:likeFeedNav animated:YES completion:nil];
    
    [self.frostedViewController hideMenuViewController];
}
- (IBAction)onSoccor:(UIButton *)sender
{
//    if (!sender.selected) {
//        selectedBtn.selected = NO;
//        sender.selected = !sender.selected;
//        selectedBtn = sender;
//    }
    
    UINavigationController *soccorView_Nav = [self.storyboard instantiateViewControllerWithIdentifier:@"mySoccorNav"];
        
    [self.frostedViewController.contentViewController presentViewController:soccorView_Nav animated:YES completion:nil];
    
    [self.frostedViewController hideMenuViewController];
}
- (IBAction)onSetting:(UIButton *)sender
{
//    if (!sender.selected) {
//        selectedBtn.selected = NO;
//        sender.selected = !sender.selected;
//        selectedBtn = sender;
//    }
    
    UINavigationController *settingViewNav = [self.storyboard instantiateViewControllerWithIdentifier:@"settingViewNav"];
    
    [self.frostedViewController.contentViewController presentViewController:settingViewNav animated:YES completion:nil];
    
    [self.frostedViewController hideMenuViewController];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
