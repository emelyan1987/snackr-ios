//
//  FlagPostCommentViewController.m
//  Snackr
//
//  Created by Matko Lajbaher on 9/29/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "FlagPostCommentViewController.h"

@interface FlagPostCommentViewController ()

@end

@implementation FlagPostCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bgView.layer.cornerRadius = 10.0f;
    self.bgView.clipsToBounds = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onDone:(id)sender {
    [self.delegate onDone];
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
