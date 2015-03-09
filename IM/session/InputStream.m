//
//  InputStream.m
//  WH
//
//  Created by guozw on 14-10-9.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "InputStream.h"


#import "NSMutableData+stream.h"
#import "MessageParser.h"
#import "LogLevel.h"

static const NSUInteger kRunLoopInterval = 1;

@interface InputStream() <NSStreamDelegate, MessageParserDelegate> {
    NSInputStream       *m_is;
    NSThread            *m_ist;  // inpustream thread.
    BOOL                m_end;
    MessageParser       *m_parser;
}

// inputstream thread method
- (void)ist_open;
- (void)ist_close;
@end

@implementation InputStream

- (instancetype)initWithStream:(NSInputStream *)inputStream {
    if (self = [super init]) {
        m_is = inputStream;
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

#if DEBUG
- (void)dealloc {
    DDLogInfo(@"%@ dealloc", NSStringFromClass([self class]));
}
#endif

- (BOOL)setup {
    m_ist = [[NSThread alloc]initWithTarget:self selector:@selector(run) object:nil];
    [m_ist start];
    return YES;
}

- (void)open {
    [self performSelector:@selector(ist_open) onThread:m_ist withObject:nil waitUntilDone:NO];
}

- (void)close {
    [self performSelector:@selector(ist_close) onThread:m_ist withObject:nil waitUntilDone:NO];
}

- (NSStreamStatus)streamStatus {
    return m_is.streamStatus;
}

- (BOOL)opened {
    if (m_is.streamStatus == NSStreamStatusOpen || m_is.streamStatus == NSStreamStatusReading) {
        return YES;
    }
    return NO;
}

#pragma mark - input thread method

- (void)ist_open {
    [m_is scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    m_is.delegate = self;
    [m_is open];
}

- (void)ist_close {
    DDLogInfo(@"close the inputstream.");
    m_end = YES;
}

#pragma mark -thread entry

- (void)run {
    do {
        @autoreleasepool {
            NSRunLoop *runloop = [NSRunLoop currentRunLoop];
            [runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:kRunLoopInterval]];
        }
    } while (!m_end);
    [m_is close];
    DDLogInfo(@"inputstream thread will exit.");
}

#pragma -mark NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
            DDLogVerbose(@"No event has occurred in inputStream ");
            break;
        case NSStreamEventOpenCompleted:
            DDLogVerbose(@"inputstream OpenCompleted.");
            m_parser = [[MessageParser alloc]initWithParserFormat:MessageParserFormatterBson];
            m_parser.delegate = self;
            if ([self.delegate respondsToSelector:@selector(InputStream:openCompletion:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate InputStream:self openCompletion:YES];
                });
            }
            break;
        case NSStreamEventEndEncountered:
            DDLogInfo(@"NSStreamEventEndEncountered in InputStream!");
            if ([self.delegate respondsToSelector:@selector(InputStream:closed:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate InputStream:self closed:YES];
                });
            }
            m_end = YES;
            break;
        case NSStreamEventErrorOccurred:
            DDLogError(@"An error has occurred on the input stream. %@", aStream.streamError);
            [self postError:aStream.streamError];
            m_end = YES;
            break;
        case NSStreamEventHasBytesAvailable:
        {
            DDLogVerbose(@"NSStreamEventHasBytesAvailable");
            uint8_t buf[1024] = {0};
            NSInteger read = [m_is read:buf maxLength:sizeof(buf)];
            if (read <= 0) {
//                m_end = YES;
                DDLogWarn(@"read val is %ld", (long)read);
                return;
            }
            [m_parser parseBuf:buf len:read];
        }
            break;
        case NSStreamEventHasSpaceAvailable:
        {
            DDLogWarn(@"oh, my god! in inputstream");
        }
            break;
        default:
            break;
    }

}

#pragma mark - throw a error to delegate

- (void)postError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(InputStream:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate InputStream:self error:error];
        });
    }
}

#pragma mark - MessageParser delegate

- (void)parser:(MessageParser *)parser message:(Message *)msg {
    if ([self.delegate respondsToSelector:@selector(InputStream:newMessage:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate InputStream:self newMessage:msg];
        });
    }
}

- (void)parser:(MessageParser *)parser Error:(NSError *)err {
    [self postError:err];
    m_end = YES;
}

- (void)parserHbRecved {
    
}


@end
