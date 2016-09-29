//
//  WelcomeViewController.m
//  Snackr
//
//  Created by Snackr on 8/10/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "WelcomeViewController.h"
#import "HomeRootViewController.h"
#import "FirstCommentModalController.h"
#import "ConfigManager.h";
#import "KGModal.h"

@interface WelcomeViewController () <UIScrollViewDelegate>
{
    BOOL showStatusBar;
}

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initViews];
    
    [self initScrollViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) initViews
{
    showStatusBar = NO;
    
    for (int viewTag = 0 ; viewTag < 7; viewTag ++) {
        UIView *subviews = [self.scrollView viewWithTag:viewTag];
        
        subviews.frame = CGRectMake(self.scrollView.frame.size.width * viewTag, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }
    
    
    HomeRootViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"home_root"];
    
    vc.view.frame = CGRectMake(self.scrollView.frame.size.width * 7, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    [self addChildViewController:vc];
    
    [self.scrollView addSubview:vc.view];
}

- (void) initScrollViews
{
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width*8, self.view.frame.size.height);
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView) {
        
        
        CGFloat offset = scrollView.contentOffset.x;
        
        int index = offset / self.view.frame.size.width;
        
        if (index > 6) {
            self.pageIndicator.hidden = YES;
            self.scrollView.scrollEnabled = NO;
            
            if (![[ConfigManager getIsFirstComment] isEqualToString:@"1"]) {
                FirstCommentModalController *comment_vc = [self.storyboard instantiateViewControllerWithIdentifier:@"firstCommentModal"];
                comment_vc.delegate = [KGModal sharedInstance];
                [[KGModal sharedInstance] showWithContentViewController:comment_vc andAnimated:YES];
                [ConfigManager setIsFistComment:@"1"];
            }
            
        } else{
            self.pageIndicator.hidden = NO;
            self.pageIndicator.currentPage = index;
        }
    }
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
