//
//  PostConfirmViewController.m
//  Snackr
//
//  Created by Snackr on 8/25/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "PostConfirmViewController.h"
#import "ShareModalViewController.h"
#import "KGModal.h"
#import "AppDelegate.h"

@interface PostConfirmViewController ()

@end

@implementation PostConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bgView.layer.cornerRadius = 10.0f;
    self.bgView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 5.0f;
    self.imageView.clipsToBounds = YES;
    
    self.imageView.image = self.postedImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDone:(id)sender {
    [self.delegate onPostConfirmDone];
}
- (IBAction)onShare:(id)sender {
    
    NSInteger where = ((AppDelegate*)[UIApplication sharedApplication].delegate).isWhatStoryboard;
    UIStoryboard *storyboard;
    
    if (where == 1) {
        storyboard = [UIStoryboard storyboardWithName:@"Main_5s" bundle:[NSBundle mainBundle]];
    } else if (where == 2){
        storyboard = [UIStoryboard storyboardWithName:@"Main_6" bundle:[NSBundle mainBundle]];
    } else if (where == 3){
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    } else if (where == 4){
        storyboard = [UIStoryboard storyboardWithName:@"Main_4s" bundle:[NSBundle mainBundle]];
    }
    
    ShareModalViewController *share_view = [storyboard instantiateViewControllerWithIdentifier:@"shareModal"];
    share_view.delegate = [KGModal sharedInstance];
    share_view.photo = self.postedImage;
    [[KGModal sharedInstance] showWithContentViewController:share_view andAnimated:YES];
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
