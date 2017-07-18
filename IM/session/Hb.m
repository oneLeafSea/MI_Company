//
//  Hb.m
//  WH
//
//  Created by guozw on 14-10-13.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Hb.h"

#import "LogLevel.h"

static const NSUInteger kHbInterval = 1;
static const NSUInteger kMaxStick = 120;

@interface Hb() {
    NSTimer  *m_timer;
    BOOL     m_running;
    __weak OutputStream *m_os;
    NSUInteger m_stick;
}

@end

@implementation Hb



- (instancetype)initWithOutputStream:(OutputStream *)stream {
    if (self = [super init]) {
        m_os = stream;
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

#if DEBUG
- (void)dealloc {
    DDLogVerbose(@"Hb dealloc");
}
#endif

- (BOOL)setup {
    m_stick = 0;
    m_running = NO;
    return YES;
}

- (void)start {
    m_timer = [NSTimer scheduledTimerWithTimeInterval:kHbInterval target:self selector:@selector(run) userInfo:nil repeats:YES];
    m_running = YES;
}

- (void)stop {
    m_running = NO;
    [m_timer invalidate];
}


#pragma mark - timer entry.

- (void)run {
    if (m_running) {
        m_stick++;
        if (m_stick >= kMaxStick) {
            [m_os sendHB];
            m_stick = 0;
        }
        
    }
}

- (void)resetStick {
    m_stick = 0;
}

@end
