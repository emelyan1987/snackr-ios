//
//  BackEndManager.h
//  Snackr
//
//  Created by Matko Lajbaher on 9/5/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackEndManager : NSObject
+(NSURL*) getUrl:(NSString*)urlString;
+(NSString*) getFullUrlString:(NSString*)urlString;
+(BOOL) isValidEmail:(NSString *)checkString;
+(NSData*) post:(NSString *)urlString postString:(NSString *)postString;
@end
