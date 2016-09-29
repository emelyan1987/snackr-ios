//
//  FirstCommentModalController.m
//  Snackr
//
//  Created by Snackr on 8/19/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "FirstCommentModalController.h"

@interface FirstCommentModalController ()

@end

@implementation FirstCommentModalController

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

- (IBAction)onGo:(id)sender {
    [self.delegate firstCommentClose];
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
