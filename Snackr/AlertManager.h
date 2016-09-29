//
//  AlertManager.h
//  Snackr
//
//  Created by Matko Lajbaher on 9/7/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertManager : NSObject
+(void)showErrorMessage:(NSString*)msg;
+(void)showSuccessMessage:(NSString*)msg;
+(void)showInfoMessage:(NSString*)msg;
@end
