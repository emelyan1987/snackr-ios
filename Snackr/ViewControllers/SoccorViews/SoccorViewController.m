//
//  SoccorViewController.m
//  Snackr
//
//  Created by Snackr on 8/20/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "SoccorViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "ShareReferralCodeViewController.h"
#import "KGModal.h"


#import "AFNetworking.h"
#import "BackEndManager.h"
#import "AlertManager.h"

@interface SoccorViewController ()
{
    NSMutableArray *valuesForChart;
}
@end

@implementation SoccorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    valuesForChart = [[NSMutableArray alloc] init];
    [self setHeaderView];
    [self initView];
    
    [self loadPoint];
}

-(void) loadPoint
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager.requestSerializer setTimeoutInterval:20];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    
    [manager GET:[BackEndManager getFullUrlString:@"customer/point"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSDictionary *jsonResult = (NSDictionary*)responseObject;
        
        
        if([[jsonResult objectForKey:@"success"] boolValue] == YES)
        {
            NSDictionary *dicData = [jsonResult objectForKey:@"data"];
            
            NSNumber *point = [dicData objectForKey:@"point"];
            NSNumber *reward = [dicData objectForKey:@"reward"];
            int percent = (int)(100 * [point intValue] / 10000);
            
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            NSString *formattedPoint = [formatter stringFromNumber:point];

            self.labelPoint.text = [NSString stringWithFormat:@"%@ points", formattedPoint];
            self.labelReward.text = [NSString stringWithFormat:@"Number of 10,000 points received: %@", reward];
            self.labelPercent.text = [NSString stringWithFormat:@"%d%%", percent];
            
            [valuesForChart addObject:[NSNumber numberWithInt:percent]];
            [valuesForChart addObject:[NSNumber numberWithInt:(100-percent)]];
            [self.pieChartView reloadData];
        } else {
            NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
            [AlertManager showErrorMessage:msg];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        //[AlertManager showErrorMessage:@"Connection failure"];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setHeaderView
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backBtn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];

    UILabel *title = [[UILabel alloc]init];
    [title setFont:[UIFont fontWithName:@"MuseoSans-100" size:16.0f]];
    title.text = @"SNACKR SCORE";
    title.textColor = [UIColor colorWithRed:(44.0f/255.0f) green:(44.0f/255.0f) blue:(44.0f/255.0f) alpha:1.0f];
    
    float maximumLabelSize =  [title.text boundingRectWithSize:title.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:title.font } context:nil].size.width;
    
    title.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:title];
    
    self.navigationItem.titleView = headerview;
}

- (void) onBack {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) initView {
    self.mySoccorView.layer.borderColor = [UIColor colorWithRed:(255.0/255.0f) green:(123.0/255.0f) blue:(123.0/255.0f) alpha:1.0f].CGColor;
    self.mySoccorView.layer.borderWidth = 1.0f;
    
    self.commentView.layer.cornerRadius = 5.0f;
    
    
    self.pieChartView.dataSource = self;
    self.pieChartView.delegate = self;
    self.pieChartView.animationDuration = 0.5;
    //self.pieChartView.sliceColor = [MCUtil flatWetAsphaltColor];
    self.pieChartView.borderColor = [UIColor colorWithRed:219.0/255.0 green:218.0/255.0 blue:206.0/255.0 alpha:1.0];
    //self.pieChartView.selectedSliceColor = [MCUtil flatSunFlowerColor];
    //self.pieChartView.textColor = [MCUtil flatSunFlowerColor];
    //self.pieChartView.selectedTextColor = [MCUtil flatWetAsphaltColor];
    self.pieChartView.borderPercentage = 0.01;
    
    self.labelPoint.text = @"0 points";
    self.labelPercent.text = @"0%";
    self.labelReward.text = @"Number of 10,000 points received: 2";
}

- (NSInteger)numberOfSlicesInPieChartView:(MCPieChartView *)pieChartView {
    return valuesForChart.count;
}

-(void)pieChartView:(MCPieChartView *)pieChartView didSelectSliceAtIndex:(NSInteger)index
{
    return;
}

-(UIColor*)pieChartView:(MCPieChartView *)pieChartView colorForSliceAtIndex:(NSInteger)index
{
    if(index == 0) {
        return [UIColor colorWithRed:255.0/255.0 green:116.0/255.0 blue:125.0/255.0 alpha:1.0];
    }
    return [UIColor colorWithRed:253.0/255.0 green:252.0/255.0 blue:196.0/255.0 alpha:1.0];
}
- (UIColor*)pieChartView:(MCPieChartView *)pieChartView colorForTextAtIndex:(NSInteger)index
{
    if(index == 0) {
        return [UIColor colorWithRed:255.0/255.0 green:116.0/255.0 blue:125.0/255.0 alpha:1.0];
    }
    return [UIColor colorWithRed:253.0/255.0 green:252.0/255.0 blue:196.0/255.0 alpha:1.0];
}

- (CGFloat)pieChartView:(MCPieChartView *)pieChartView valueForSliceAtIndex:(NSInteger)index {
    return [[valuesForChart objectAtIndex:index] floatValue];
}

- (IBAction)onInviteToEarn:(id)sender{
    ShareReferralCodeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"shareReferralCodeView"];
    KGModal *kgm = [KGModal sharedInstance];
    vc.delegate = kgm;
    kgm.delegateShareRefferralCode = vc;
    [[KGModal sharedInstance] showWithContentViewController:vc andAnimated:YES];
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
