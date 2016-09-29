//
//  BCRecordSessionManager.h
//  BirdCage
//
//  Created by Brendan Zhou on 8/01/2015.
//  Copyright (c) 2015 Bizar Mobile Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import "SCRecorder.h"

@interface BCRecordSessionManager : NSObject

- (void)saveRecordSession:(SCRecordSession *)recordSession;

- (void)removeRecordSession:(SCRecordSession *)recordSession;

- (BOOL)isSaved:(SCRecordSession *)recordSession;

- (void)removeRecordSessionAtIndex:(NSInteger)index;

- (NSArray *)savedRecordSessions;

+ (BCRecordSessionManager *)sharedInstance;

@end
