//
//  BackEndManager.m
//  Snackr
//
//  Created by Matko Lajbaher on 9/5/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "BackEndManager.h"


static const NSString *webHost = @"http://ec2-54-148-9-12.us-west-2.compute.amazonaws.com/snackr/web";
//static const NSString *webHost = @"http://192.168.2.15/snackr/web";



@implementation BackEndManager

+(NSURL*) getUrl:(NSString*)urlString
{
    NSString *fullUrlString = [NSString stringWithFormat:@"%@/%@", webHost, urlString]; 
    return [NSURL URLWithString:fullUrlString];
}
+(NSString*) getFullUrlString:(NSString*)urlString
{
    NSString *fullUrlString = [NSString stringWithFormat:@"%@/%@", webHost, urlString];
    return fullUrlString;
}
+(BOOL) isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+(NSData*) post:(NSString *)urlString postString:(NSString *)postString
{
    NSData *returnData = [[NSData alloc]init];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[BackEndManager getUrl:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    if(postString != nil)
    {
        NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postString length]];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];
    }
    
    //Send the Synchronous Request
    returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    
    
    //Get the Result of Request
    NSString *response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
    
    bool debug = YES;
    
    if (debug && response) {
        NSLog(@"Response >>>> %@",response);
    }
    
    return returnData;
}
@end
