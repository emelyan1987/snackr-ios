//
//  BCVideoPickerController.h
//  BirdCage
//
//  Created by Brendan Zhou on 2/02/2015.
//  Copyright (c) 2015 Bizar Mobile Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecordSession.h"

@interface BCVideoPickerController : UIViewController

@property (nonatomic, copy) void(^cropBlock)(SCRecordSession *session);

@end
