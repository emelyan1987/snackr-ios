//
//  GroupViewController.m
//  Pods
//
//  Created by Brendan Zhou on 13/03/2015.
//
//

#import "GroupViewController.h"
#import "TWPhotoCollectionViewCell.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface GroupViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    UILabel* titleLabel;
}

@property (strong, nonatomic) NSMutableArray* assets;
@property (strong, nonatomic) ALAssetsLibrary* assetsLibrary;
@property (strong, nonatomic) UICollectionView* collectionView;

@end

@implementation GroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor darkTextColor];
    [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadPhotos];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray*)assets
{
    if (_assets == nil) {
        _assets = [[NSMutableArray alloc] init];
    }
    return _assets;
}

- (ALAssetsLibrary*)assetsLibrary
{
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (void)loadPhotos
{
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset* result, NSUInteger index, BOOL* stop) {
        if (result) {
            [self.assets insertObject:result atIndex:0];
        }
    };
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup* group, BOOL* stop) {
        titleLabel.text = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        
        if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString: titleLabel.text]) {
            [self.assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
            if (self.assets.count) {
                ALAssetRepresentation *rep = [[self.assets objectAtIndex:0] defaultRepresentation];
                UIImage *image = [UIImage imageWithCGImage:[rep fullResolutionImage] scale:[rep scale] orientation:(UIImageOrientation)[rep orientation]];
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectPhotoNotification object:image];
            }
            [self.collectionView reloadData];
            *stop = YES;
        }
    };
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:listGroupBlock failureBlock:^(NSError* error) {
        NSLog(@"Load Photos Error: %@", error);
    }];
}

- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        CGFloat colum = 4.0, spacing = 2.0;
        CGFloat value = floorf((CGRectGetWidth(self.view.bounds) - (colum - 1) * spacing) / colum);
        
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(value, value);
        layout.sectionInset = UIEdgeInsetsMake(44, 0, 0, 0);
        layout.minimumInteritemSpacing = spacing;
        layout.minimumLineSpacing = spacing;
        
        CGRect rect = self.view.frame;
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        
        [_collectionView registerClass:[TWPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"TWPhotoCollectionViewCell"];
        
        rect = CGRectMake(-15, 0, 60, layout.sectionInset.top);
        UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = rect;
        [backBtn setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backToAlbum) forControlEvents:UIControlEventTouchUpInside];
        [_collectionView addSubview:backBtn];
        
        rect = CGRectMake((CGRectGetWidth(_collectionView.bounds) - 200) / 2, 0, 200, layout.sectionInset.top);
        titleLabel = [[UILabel alloc] initWithFrame:rect];
        titleLabel.text = @"";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [_collectionView addSubview:titleLabel];
    }
    return _collectionView;
}

- (void)backToAlbum
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"TWPhotoCollectionViewCell";
    
    TWPhotoCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageWithCGImage:[[self.assets objectAtIndex:indexPath.row] thumbnail]];
    
    return cell;
}

#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    ALAsset* asset = [self.assets objectAtIndex:indexPath.row];
    UIImage* image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectPhotoNotification object:image];
}

@end
