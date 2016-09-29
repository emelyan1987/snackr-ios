//
//  SoccorViewController.h
//  Snackr
//
//  Created by Snackr on 8/20/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCPieChartView.h"

@interface SoccorViewController : UIViewController <MCPieChartViewDataSource, MCPieChartViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *mySoccorView;

@property (weak, nonatomic) IBOutlet UIView *commentView;

@property (weak, nonatomic) IBOutlet UILabel *labelPoint;
@property (weak, nonatomic) IBOutlet UILabel *labelPercent;
@property (weak, nonatomic) IBOutlet UILabel *labelReward;

@property (weak, nonatomic) IBOutlet MCPieChartView *pieChartView;
@end
