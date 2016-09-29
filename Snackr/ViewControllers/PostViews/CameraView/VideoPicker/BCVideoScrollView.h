//
//  BCVideoScrollView.h
//  BirdCage
//
//  Created by Brendan Zhou on 2/02/2015.
//  Copyright (c) 2015 Bizar Mobile Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SCRecordSession.h"

#define kExportDidFinishNotification @"kExportDidFinishNotification"

@interface BCVideoScrollView : UIScrollView

- (void)displayVideo:(AVAsset*)asset;
- (void)capture;

@end
