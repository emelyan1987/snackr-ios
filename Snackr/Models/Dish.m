//
//  Dish.m
//  Snackr
//
//  Created by Matko Lajbaher on 9/10/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "Dish.h"
#import "BackEndManager.h"
#import "FTWCache.h"


@implementation Dish


-(UIImage*)getImage
{
    NSString *photoUrlString = self.photoUrl;
    NSURL *url = [NSURL URLWithString:[BackEndManager getFullUrlString:[NSString stringWithFormat:@"uploads/%@", photoUrlString]]];
    
    if([photoUrlString isEqual:[NSNull null]]) return nil;
    NSData *cachedData = [FTWCache objectForKey:photoUrlString];
    if (cachedData) {
        return [UIImage imageWithData:cachedData];
    }
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    UIImage *imageFromData = [UIImage imageWithData:data];
    
    [FTWCache setObject:data forKey:photoUrlString];
    
    return imageFromData;
}

@end



