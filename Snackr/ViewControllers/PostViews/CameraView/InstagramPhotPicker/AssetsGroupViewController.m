//
//  AssetsGroupViewController.m
//  InstagramPhotoPicker
//
//  Created by Brendan Zhou on 13/03/2015.
//  Copyright (c) 2015 wenzhaot. All rights reserved.
//

#import "AssetsGroupViewController.h"
#import "AssetsGroupViewCell.h"
#import "GroupViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface AssetsGroupViewController () {
    ALAssetsLibrary* assetsLibrary;
}

@end

@implementation AssetsGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkTextColor];
    self.tableView.separatorColor = [UIColor lightGrayColor];
    [self setupGroup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupGroup
{
    if (!assetsLibrary) {
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    if (!self.groups)
        self.groups = [[NSMutableArray alloc] init];
    else
        [self.groups removeAllObjects];
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup* group, BOOL* stop) {
        if (group)
        {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [self.groups addObject:group];
        }
        else
        {
            [self.tableView reloadData];
            if (group == nil) {
                GroupViewController *vc = [[GroupViewController alloc] init];
                vc.assetsGroup = self.groups.firstObject;
                [self.navigationController pushViewController:vc animated:NO];
            }
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError* error) {
        //
    };
    
    // Enumerate Camera roll first
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:resultsBlock
                               failureBlock:failureBlock];
    
    // Then all other groups
    NSUInteger type = ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupPhotoStream;
    
    [assetsLibrary enumerateGroupsWithTypes:type
                                 usingBlock:resultsBlock
                               failureBlock:failureBlock];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.groups.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    AssetsGroupViewCell* cell = [[AssetsGroupViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AssetCell"];
    
    // Configure the cell...
    cell.backgroundColor = [UIColor darkTextColor];
    [cell bind:[self.groups objectAtIndex:indexPath.row] showNumberOfAssets:YES];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    GroupViewController* vc = [[GroupViewController alloc] init];
    vc.assetsGroup = [self.groups objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
