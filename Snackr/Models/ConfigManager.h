//
//  ConfigManager.h
//


#import <Foundation/Foundation.h>

@interface ConfigManager : NSObject

+ (void) initConfigFile;
+ (NSString *)dataFilePath;

+ (void) setIsFistComment : (NSString *) flag;
+ (NSString *) getIsFirstComment;
+ (void) setIsSwipeDownComment : (NSString *) flag;
+ (NSString *) getIsSwipeDownComment;

@end
