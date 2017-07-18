//
//  OutputStream.h
//  WH
//
//  Created by guozw on 14-10-9.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Request.h"

typedef NS_ENUM(NSUInteger, OutputStreamMsgError) {
    OutputStreamMsgErrorTimeout,
    OutputStreamMsgErrorStreamWrong,
    OutputStreamMsgErrorStreamClosed
};

/**
 *  kMessageSendInfinite
 **/

//const static NSUInteger kMessageSendInfinite = NSUIntegerMax;

@protocol OutputStreamDelegate;

/**
 * OutputStream send messages and heartbeat to server,
 * control message timeout,
 * notify delegate when the message is sent or not.
 **/

@interface OutputStream : NSObject

/**
 * OutputStream init. when the OutputStream init successfully,
 * the OutputStream thread will be started.
 * @param outputStream.
 * @return return self.
 */

- (instancetype)initWithStream:(NSOutputStream *)outputStream;

/**
 * open the writing stream.
 * A stream must be created before it can be opened.
 */

- (void)open;

/**
 * Close the sender and outputstrem and the Outputstream thread exit.
 */

- (void)close;

/**
 * Send message to server.
 * @param msg the message which will be sent.
 * @param sec specify the message timeout. If timeout value is kMessageSendInfinite. mean infinite.
 **/

- (void)sendWithMessage:(Request *)msg timeout:(NSUInteger)sec;

/**
 * Send message to server without timer.
 **/
// mean no timeout, send the message until done.

- (void)sendWithMessage:(Request *)msg;

/**
 * send heartbeat.
 **/

- (void)sendHB;

- (void)cancel:(Message *)message;

@property(weak) id<OutputStreamDelegate> delegate;
@property(readonly) BOOL opened;
@end

/**
 * OutputStreamDelegate
 **/
@protocol OutputStreamDelegate <NSObject>

- (void)OutputStream:(OutputStream *)outputStream openCompletion:(BOOL)completion;
- (void)OutputStream:(OutputStream *)outputStream closed:(BOOL)closed;
- (void)OutputStream:(OutputStream *)outputStream error:(NSError *)error;
- (void)OutputStream:(OutputStream *)outputStream message:(Message *)message sent:(BOOL)sent error:(NSError *)error;
- (void)OutputStream:(OutputStream *)outputStream cancel:(BOOL)cancelled msg:(Message *)msg;

- (void)OutputStream:(OutputStream *)outputStream message:(Message *)message timeout:(BOOL)timeout;

@end