//
//  SwipeDownCommentController.m
//  Snackr
//
//  Created by Snackr on 8/19/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "SwipeDownCommentController.h"

@interface SwipeDownCommentController ()

@end

@implementation SwipeDownCommentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bgView.layer.cornerRadius = 10.0f;
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.undoBtn.titleLabel.text];
    [attrStr addAttribute:NSForegroundColorAttributeName value:self.undoBtn.titleLabel.textColor range:NSMakeRange(0, attrStr.length)];
    [attrStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(0, attrStr.length)];
    [attrStr addAttribute:NSUnderlineColorAttributeName value:self.undoBtn.titleLabel.textColor range:NSMakeRange(0, attrStr.length)];
    self.undoBtn.titleLabel.attributedText = attrStr;
    
    attrStr = [[NSMutableAttributedString alloc] initWithString:self.doneBtn.titleLabel.text];
    [attrStr addAttribute:NSForegroundColorAttributeName value:self.doneBtn.titleLabel.textColor range:NSMakeRange(0, attrStr.length)];
    [attrStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(0, attrStr.length)];
    [attrStr addAttribute:NSUnderlineColorAttributeName value:self.doneBtn.titleLabel.textColor range:NSMakeRange(0, attrStr.length)];
    self.doneBtn.titleLabel.attributedText = attrStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onDone:(id)sender {
    [self.delegate onDone];
}

- (IBAction)onUndo:(id)sender {
    [self.delegate onCancel];
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
