//
//  MessageKeeper.m
//  WH
//
//  Created by guozw on 14-10-13.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "MessageKeeper.h"
#import "MessageQueueNode.h"
#import "LogLevel.h"


const NSUInteger        kMkTimerInterval = 1;

@interface MessageKeeper() {
    __weak NSMutableArray *m_msgQueue;
    NSTimer        *m_timer;
    BOOL            m_end;
}

@end

@implementation MessageKeeper


#if DEBUG
- (void)dealloc {
    DDLogInfo(@"%@ dealloc", NSStringFromClass([self class]));
}
#endif

- (instancetype)initWithMessageQueue:(NSMutableArray *)msgQueue {
    if (self = [super init]) {
        m_msgQueue = msgQueue;
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
 }

- (BOOL)setup {
    return YES;
}

- (void)start {
   m_timer = [NSTimer scheduledTimerWithTimeInterval:kMkTimerInterval target:self selector:@selector(run) userInfo:nil repeats:YES];
}

- (void)stop {
    m_end = YES;
    [m_timer invalidate];
}

- (BOOL)running {
    return !m_end;
}

#pragma mark timer entry.

- (void)run {
    if (!m_end) {
        DDLogVerbose(@"keeper start run");
        NSMutableArray *timeoutedNodes = [[NSMutableArray alloc]initWithCapacity:32];
        for (MessageQueueNode* mqn in m_msgQueue) {
            if (mqn.timeout == kMessageSendInfinite) {
                continue;
            }
            mqn.stick++;
            if ([mqn isTimeout]) {
                DDLogInfo(@" # qid: %@ type:%x. timeout", mqn.msg.qid, (unsigned int)mqn.msg.type);
                [timeoutedNodes addObject:mqn];
            }
        }
        
        if (timeoutedNodes.count == 0) {
            return;
        }
        
        for (MessageQueueNode *timeoutMqn in timeoutedNodes) {
            if ([self.delegate respondsToSelector:@selector(MessageKeeper:timeoutMessage:)]) {
                [self.delegate MessageKeeper:self timeoutMessage:timeoutMqn.msg];
            }
        }
        [m_msgQueue removeObjectsInArray:timeoutedNodes];
        [timeoutedNodes removeAllObjects];
    }
}

@end
