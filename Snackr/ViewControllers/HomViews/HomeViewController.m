//
//  HomeViewController.m
//  Snackr
//
//  Created by Snackr on 8/12/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "HomeViewController.h"
#import "MenuViewController.h"
#import "DraggableViewBackground.h"
#import "CameraViewController.h"

@interface HomeViewController ()

@property MenuViewController *menuvc;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setHeaderView];
    [self initView];
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setHeaderView
{
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuBtn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onMenu)];
    [self.navigationItem setLeftBarButtonItem:btnMenu animated:NO];
    
    UIBarButtonItem *onCamera = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraBtn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onCamera)];
    [self.navigationItem setRightBarButtonItem : onCamera];

    UILabel *title = [[UILabel alloc]init];
    [title setFont:[UIFont fontWithName:@"Pacifico" size:28.0f]];
    title.text = @"Snackr";
    title.textColor = [UIColor colorWithRed:(204.0f/255.0f) green:(16.0f/255.0f) blue:(17.0f/255.0f) alpha:1.0f];
    
    float maximumLabelSize =  [title.text boundingRectWithSize:title.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:title.font } context:nil].size.width;
    
    title.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:title];
    
    self.navigationItem.titleView = headerview;
}

- (void) onMenu
{
    // Dismiss keyboard (optional)
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    [self.frostedViewController presentMenuViewController];
}

- (void) onCamera
{
    UINavigationController *post_Nav = [self.storyboard instantiateViewControllerWithIdentifier:@"postViewNav"];
    
    [self.frostedViewController.contentViewController presentViewController:post_Nav animated:YES completion:nil];
}

- (void) initView {
    CGRect frame = CGRectMake(0, 0, self.cardView.frame.size.width, self.cardView.frame.size.height);
    DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:frame viewController:self];
    [self.cardView addSubview:draggableBackground];
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
