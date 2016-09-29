//
//  MySubmissionViewController.m
//  Snackr
//
//  Created by Snackr on 8/20/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "MySubmissionViewController.h"
//#import "ASFSharedViewTransition.h"
#import "MySubmissionDetailViewController.h"
#import "MySubmissionViewCell.h"
#import "AFNetworking.h"
#import "BackEndManager.h"
#import "AlertManager.h"
#import "Dish.h"
#import "Utils.h"

#import "UIImageView+Network.h"

#define ITEMS_PAGE_SIZE 3
#define ITEM_CELL_IDENTIFIER @"mySubmissionViewCell"
#define LOADING_CELL_IDENTIFIER @"LoadingItemCell"

@interface MySubmissionViewController ()
{
    NSMutableArray *dishes;
    int pageNo;
}
@end

@implementation MySubmissionViewController

-(void) loadDish
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager.requestSerializer setTimeoutInterval:20];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    int count = 3;

    int start = pageNo * count;
    
    NSDictionary *params = @{@"start":[NSNumber numberWithInt:start], @"count":[NSNumber numberWithInt:count]};
    [manager GET:[BackEndManager getFullUrlString:@"dish/submittedlist"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSDictionary *jsonResult = (NSDictionary*)responseObject;
        
        
        if([[jsonResult objectForKey:@"success"] boolValue] == YES)
        {
            NSDictionary *dicData = [jsonResult objectForKey:@"data"];
            for (NSDictionary *dicDish in dicData) {
                Dish *dish = [[Dish alloc] init];
                dish.no = [[dicDish objectForKey:@"id"] intValue];
                dish.title = [dicDish objectForKey:@"title"];
                NSString *price = [dicDish objectForKey:@"price"];
                if(![price isEqual:[NSNull null]])
                    dish.price = [price doubleValue];
                
                NSString *photoUrl = [dicDish objectForKey:@"photo"];
                dish.photoUrl = photoUrl;
                
                
                dish.distance = [dicDish objectForKey:@"distance"];
                Restaurant *rest = [[Restaurant alloc] init];
                NSDictionary *dicRest = [dicDish objectForKey:@"restaurant"];
                rest.no = [[dicRest objectForKey:@"id"] intValue];
                rest.title = [dicRest objectForKey:@"title"];
                NSString *tel = [dicRest objectForKey:@"tel"];
                rest.tel = [tel isEqual:[NSNull null]] ? @"" : tel;
                rest.address = [dicRest objectForKey:@"address"];
                rest.location = [dicRest objectForKey:@"location"];
                rest.zipCode = [dicRest objectForKey:@"zip_code"];
                dish.restaurant = rest;
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *date = [formatter dateFromString:[dicDish objectForKey:@"created_time"]];
                
                dish.createdTime = date;
                NSString *views = [dicDish objectForKey:@"views"];
                if(![views isEqual:[NSNull null]])
                    dish.views = [views intValue];
                else
                    dish.views = 0;
                
                NSString *likes = [dicDish objectForKey:@"likes"];
                if(![likes isEqual:[NSNull null]])
                    dish.likes = [likes intValue];
                else
                    dish.likes = 0;
                
                [dishes addObject:dish];
            }
            
            [self.myLists reloadData];
        } else {
            NSString *msg = (NSString*)[jsonResult objectForKey:@"msg"];
            [AlertManager showErrorMessage:msg];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        //[AlertManager showErrorMessage:@"Connection failure"];
    }];
    
    pageNo ++;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.myLists registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:LOADING_CELL_IDENTIFIER];
    
    dishes = [[NSMutableArray alloc] init];
    
    pageNo = 0;
    [self loadDish];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.topView.blurRadius = 20;
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

- (IBAction)onBack:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UICollectionViewDelegate &  UICollectionViewDataSource
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return dishes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger itemIndex = indexPath.item;
    if (itemIndex < dishes.count) {
        if(itemIndex == (dishes.count - ITEMS_PAGE_SIZE) && itemIndex%ITEMS_PAGE_SIZE == 0){
            [self fetchMoreItems];
        }
        return [self itemCellForIndexPath:indexPath];
    } else {
        [self fetchMoreItems];
        return [self loadingCellForIndexPath:indexPath];
    }
}

- (UICollectionViewCell *)itemCellForIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier  = @"mySubmissionViewCell";
    
    MySubmissionViewCell * cell = (MySubmissionViewCell * ) [self.myLists dequeueReusableCellWithReuseIdentifier:ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
    
    // Update the custom cell with some text
    Dish *dish = [dishes objectAtIndex:indexPath.row];
    
    
    NSString *photoUrlString = dish.photoUrl;
    NSURL *imageURL = [NSURL URLWithString:[BackEndManager getFullUrlString:[NSString stringWithFormat:@"uploads/%@", photoUrlString]]];
    [cell.food_photo loadImageFromURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder.png"] cachingKey:photoUrlString];
    
    
    cell.labelViews.text = [NSString stringWithFormat:@"%d Views", dish.views]; //NSLog([NSString stringWithFormat:@"%d", dish.views]);
    cell.labelLiked.text = [NSString stringWithFormat:@"%d people liked this", dish.likes]; //NSLog([NSString stringWithFormat:@"%d", dish.likes]);
    cell.labelDate.text = [Utils dateDifference:dish.createdTime]; //NSLog([Utils dateDifference:dish.createdTime]);
    
    return cell;
}

- (UICollectionViewCell *)loadingCellForIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"LoadingItemCell";
    UICollectionViewCell *cell = (UICollectionViewCell *)[self.myLists dequeueReusableCellWithReuseIdentifier:LOADING_CELL_IDENTIFIER forIndexPath:indexPath];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = cell.center;
    [cell addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
    
    return cell;
}

- (void)fetchMoreItems {
    NSLog(@"FETCHING MORE ITEMS ******************");
    
    [self loadDish];
}
#pragma mark - ASFSharedViewTransitionDataSource

- (UIView *)sharedView
{
    return [_myLists cellForItemAtIndexPath:[[_myLists indexPathsForSelectedItems] firstObject]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *selectedIndexPath = [[_myLists indexPathsForSelectedItems] firstObject];
    
    // Set the thing on the view controller we're about to show
    if (selectedIndexPath != nil) {
        MySubmissionDetailViewController *detailVC = segue.destinationViewController;
        Dish *dish = dishes[selectedIndexPath.row];
        
        detailVC.dish = dish;
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
