//
//  InputStream.h
//  WH
//
//  Created by guozw on 14-10-9.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@protocol InputStreamDelegate;

/**
 * InputSteam receive data from server,
 * parse the data into message structure,
 * then post the message to the delegate in main thread.
 **/

@interface InputStream : NSObject

/**
 * InputStream init. when the InputStream init successfully,
 * the inputstream thread will be started.
 * @param inputStream.
 * @return return self.
 */
- (instancetype)initWithStream:(NSInputStream *)inputStream;

/**
 * open the receiving stream.
 * A stream must be created before it can be opened. 
 * Once opened, a stream cannot be closed and reopened.
 */
- (void)open;

/**
 * Close the receiver and inputstrem and the Inputstream thread exit.
 */
- (void)close;


@property(weak) id<InputStreamDelegate>     delegate;
@property (readonly) BOOL opened;
@end

/**
 * InputStreamDelegate
 **/

@protocol InputStreamDelegate <NSObject>

- (void)InputStream:(InputStream *)inputStream openCompletion:(BOOL)completion;
- (void)InputStream:(InputStream *)inputStream closed:(BOOL)close;
- (void)InputStream:(InputStream *)inputStream newMessage:(Message *)newMsg;
- (void)InputStream:(InputStream *)inputStream error:(NSError *)err;

@end