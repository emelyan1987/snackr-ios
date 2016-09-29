//
//  ConfigManager.m
// 


#import "ConfigManager.h"

@implementation ConfigManager

//+ (void) setFirstHome : (NSString *) isfirst{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//         [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    
//    [config_dic setObject:isfirst forKey:@"firsthome"];
//    
//    [config_dic writeToFile:config_path atomically:YES];
//}
//
//+ (NSString *) getFirstHome{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    NSString * firsthome  = [config_dic valueForKey:@"firsthome"];
//    return firsthome;
//}
//
//+ (void) setFirstSearch : (NSString *) isfirst{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    
//    [config_dic setObject:isfirst forKey:@"firstsearch"];
//    
//    [config_dic writeToFile:config_path atomically:YES];
//}
//
//+ (NSString *) getFirstSearch{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    NSString * firstsearch  = [config_dic valueForKey:@"firstsearch"];
//    return firstsearch;
//}
//
//
//+ (void) setFirstPost : (NSString *) isfirst{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    
//    [config_dic setObject:isfirst forKey:@"firstpost"];
//    
//    [config_dic writeToFile:config_path atomically:YES];
//}
//
//+ (NSString *) getFirstPost{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    NSString * firstpost  = [config_dic valueForKey:@"firstpost"];
//    return firstpost;
//}
//
//+ (void) setFirstProfile : (NSString *) isfirst{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    
//    [config_dic setObject:isfirst forKey:@"firstprofile"];
//    
//    [config_dic writeToFile:config_path atomically:YES];
//}
//
//+ (NSString *) getFirstProfile{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    NSString * firstprofile  = [config_dic valueForKey:@"firstprofile"];
//    return firstprofile;
//}
//
//+ (void) setFirstAlert : (NSString *) isfirst{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    
//    [config_dic setObject:isfirst forKey:@"firstalert"];
//    
//    [config_dic writeToFile:config_path atomically:YES];
//}
//
//+ (NSString *) getFirstAlert{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    NSString * firstalert  = [config_dic valueForKey:@"firstalert"];
//    return firstalert;
//}
//
//+ (void) setFirstRecipe : (NSString *) isfirst{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    
//    [config_dic setObject:isfirst forKey:@"firstrecipe"];
//    
//    [config_dic writeToFile:config_path atomically:YES];
//}
//
//+ (NSString *) getFirstRecipe{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    NSString * firstrecipe  = [config_dic valueForKey:@"firstrecipe"];
//    return firstrecipe;
//}
//
//+ (void) setFirstSaveDlg : (NSString *) isfirst{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    
//    [config_dic setObject:isfirst forKey:@"firstsavedlg"];
//    
//    [config_dic writeToFile:config_path atomically:YES];
//}
//
//+ (NSString *) getFirstSaveDlg{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    NSString * firstsavedlg  = [config_dic valueForKey:@"firstsavedlg"];
//    return firstsavedlg;
//}
//
//+ (void) setFirstAddRecipe : (NSString *) isfirst{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    
//    [config_dic setObject:isfirst forKey:@"firstaddrecipe"];
//    
//    [config_dic writeToFile:config_path atomically:YES];
//}
//
//+ (NSString *) getFirstAddRecipe{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    NSString * firstaddrecipe  = [config_dic valueForKey:@"firstaddrecipe"];
//    return firstaddrecipe;
//}
//
//
//+ (void) rememberUserInfo:(User*)userinfo {
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    [config_dic setObject:userinfo.UID forKey:@"ID"];
//    [config_dic setObject:userinfo.UFULLNAME forKey:@"FULLNAME"];
//    [config_dic setObject:userinfo.UUSERNAME forKey:@"USERNAME"];
//    [config_dic setObject:userinfo.UTOKEN forKey:@"TOKEN"];
//    [config_dic setObject:userinfo.UEMAIL forKey:@"EMAIL"];
//    [config_dic setObject:userinfo.UPASSWORD forKey:@"PASSWORD"];
//    [config_dic setObject:userinfo.UPHOTO forKey:@"PHOTO"];
//    [config_dic setObject:userinfo.UTHUMBNAIL forKey:@"THUMBNAIL"];
//    [config_dic setObject:userinfo.UBIO forKey:@"BIO"];
//    [config_dic setObject:userinfo.UFOLLOWINGS forKey:@"followings"];
//    [config_dic setObject:userinfo.UFOLLOWERS forKey:@"followers"];
//    [config_dic setObject:userinfo.UFBID forKey:@"fb_id"];
//    [config_dic setObject:userinfo.UTWITTERID forKey:@"twitter_id"];
//    
//    [config_dic writeToFile:config_path atomically:YES];
//}
//
//+ (void) clearAllInfo {
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] init];
//    
//    [config_dic writeToFile:config_path atomically:YES];
//}
//
//+ (User*) getRememberedUserinfo {
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    
//    User *userinfo = [[User alloc] init];
//    userinfo.UID = [config_dic objectForKey:@"ID"];
//    userinfo.UFULLNAME = [config_dic objectForKey:@"FULLNAME"];
//    userinfo.UUSERNAME = [config_dic objectForKey:@"USERNAME"];
//    userinfo.UTOKEN = [config_dic objectForKey:@"TOKEN"];
//    userinfo.UEMAIL = [config_dic objectForKey:@"EMAIL"];
//    userinfo.UPASSWORD = [config_dic objectForKey:@"PASSWORD"];
//    userinfo.UPHOTO = [config_dic objectForKey:@"PHOTO"];
//    userinfo.UTHUMBNAIL = [config_dic objectForKey:@"THUMBNAIL"];
//    userinfo.UBIO = [config_dic objectForKey:@"BIO"];
//    userinfo.UFOLLOWERS = [config_dic objectForKey:@"followers"];
//    userinfo.UFOLLOWINGS = [config_dic objectForKey:@"followings"];
//    userinfo.UFBID = [config_dic objectForKey:@"fb_id"];
//    userinfo.UTWITTERID = [config_dic objectForKey:@"twitter_id"];
//    
//    return userinfo;
//}
//
//+ (void) setDeviceToken : (NSString *) token{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    
//    [config_dic setObject:token forKey:@"device_token"];
//    
//    [config_dic writeToFile:config_path atomically:YES];
//}
//
//+ (NSString *) getDeviceToken{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    NSString * token  = [config_dic valueForKey:@"device_token"];
//    return token;
//}
//
//+ (void) remenberMyLocation : (NSArray *) locations{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    
//    [config_dic setObject:locations forKey:@"locations"];
//    
//    [config_dic writeToFile:config_path atomically:YES];
//}
//
//+ (NSArray *) getMyLocations{
//    NSString *config_path = [self dataFilePath];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
//        [self initConfigFile];
//    }
//    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
//    NSArray * locations  = [config_dic valueForKey:@"locations"];
//    return locations;
//}

+ (void) setIsFistComment : (NSString *) flag{
    NSString *config_path = [self dataFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
        [self initConfigFile];
    }
    
    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
    
    [config_dic setObject:flag forKey:@"isFirstComment"];
    [config_dic writeToFile:config_path atomically:YES];
}

+ (NSString *) getIsFirstComment {
    NSString *config_path = [self dataFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
        [self initConfigFile];
    }
    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
    NSString * flag = [config_dic valueForKey:@"isFirstComment"];
    return flag;
}

+ (void) setIsSwipeDownComment : (NSString *) flag{
    NSString *config_path = [self dataFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
        [self initConfigFile];
    }
    
    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
    
    [config_dic setObject:flag forKey:@"isSwipeDownComment"];
    [config_dic writeToFile:config_path atomically:YES];
}

+ (NSString *) getIsSwipeDownComment {
    NSString *config_path = [self dataFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:config_path]) {
        [self initConfigFile];
    }
    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
    NSString * flag = [config_dic valueForKey:@"isSwipeDownComment"];
    return flag;
}


+ (void) initConfigFile {
    NSString *config_path = [self dataFilePath];
    NSMutableDictionary *config_dic = [[NSMutableDictionary alloc] init];
    [config_dic writeToFile:config_path atomically:YES];
}

+(NSString *)dataFilePath {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [path objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"config"];
}

@end
