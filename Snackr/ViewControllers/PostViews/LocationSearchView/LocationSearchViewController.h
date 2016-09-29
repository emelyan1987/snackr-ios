//
//  LocationSearchViewController.h
//  Snackr
//
//  Created by Snackr on 8/25/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationSearchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, retain) UIImage *food_photo;

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchTxt;

@property (weak, nonatomic) IBOutlet UITableView *locationLists;
@property (nonatomic, strong) UIColor *prevNavBarColor;

- (IBAction)changingSearchText:(id)sender;
@end
