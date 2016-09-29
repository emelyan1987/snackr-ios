//
//  Utils.h
//  Snackr
//
//  Created by Matko Lajbaher on 9/11/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject
+ (NSString *) dateDifference:(NSDate *)date;
+ (NSString *)randomAlphanumericStringWithLength:(NSInteger)length;
@end
