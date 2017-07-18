//
//  MessageQueueNode.h
//  WH
//
//  Created by guozw on 14-10-13.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Request.h"

/**
 *  MessageQueueNode
 **/

@interface MessageQueueNode : NSObject

- (instancetype)initWithMessage:(Request *)msg timeout:(NSUInteger)sec;

@property(assign, readonly)NSUInteger    timeout;
@property(readonly) Request       *msg;
@property(assign)NSUInteger    stick;

@property(assign)               BOOL hb;    // whether heartbeat.

//- (NSData *)basonData;
- (BOOL)isTimeout;

@end
