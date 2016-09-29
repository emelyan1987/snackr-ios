//
//  NSMutableArray+Queue.h
//  Snackr
//
//  Created by Matko Lajbaher on 9/13/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)

- (void) enqueue: (id)item;
- (id) dequeue;
- (id) peek;

@end
