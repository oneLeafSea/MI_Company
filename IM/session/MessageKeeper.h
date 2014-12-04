//
//  MessageKeeper.h
//  WH
//
//  Created by guozw on 14-10-13.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Message.h"

@protocol MessageKeeperDelegate;

const static NSUInteger kMessageSendInfinite = NSUIntegerMax;

@interface MessageKeeper : NSObject

- (instancetype)initWithMessageQueue:(NSMutableArray *)msgQueue;

- (void)start;
- (void)stop;

@property(weak)id<MessageKeeperDelegate> delegate;
@property(readonly) BOOL running;

@end

@protocol MessageKeeperDelegate <NSObject>

- (void)MessageKeeper:(MessageKeeper *)keeper timeoutMessage:(Message *) message;

@end