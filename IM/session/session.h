//
//  session.h
//  WH
//
//  Created by guozw on 14-10-9.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Request.h"
#import "Message.h"

@class Session;

@protocol SessionDelegate <NSObject>

- (void)session:(Session *)sess connected:(BOOL)connected timeout:(BOOL)timeout error:(NSError *)error;
- (void)session:(Session *)sess serverTime:(NSString *)serverTime;
- (void)sessionDied:(Session *)sess error:(NSError *)err;
@end

extern NSString *kSessionConnected;
extern NSString *kSessionDied;
extern NSString *kSessionTimeout;
extern NSString *kSessionServerTime;

@interface Session : NSObject
/**
* Asynchronous connect the server with params. when the operation complete, it will call the session delegate.
* @param IP IPV4 addr like 192.168.1.1.
* @param port server's port.
* @param tls YES Using Networking Securely else NO.
* @return success if the value is YES else fail.
*/
- (BOOL)connectToIP:(NSString *)IP port:(UInt32)port TLS:(BOOL)tls;

/**
 * Asynchronous connect the server with params. when the operation complete, it will call the session delegate.
 * @param IP IPV4 addr like 192.168.1.1.
 * @param port server's port to be connected.
 * @param tls YES Using Networking Securely else NO.
 * @param timeout if timeout value is 0, session will connect to server until system timeout.
 * @return success if the value is YES else fail.
 */
- (BOOL)connectToIP:(NSString *)IP port:(UInt32)port TLS:(BOOL)tls timeout:(NSTimeInterval)timeout;

/**
 * Stop the Session and the session thread exit.
*/
- (void)disconnect;

/**
 *
 */
//- (void)sendMessage:(Message *)msg;

/**
 * send a request which need response to server
 **/

- (void)request:(Request *)req;

/**
 * cancel a request
 **/

- (void)cancelRequest:(Request *)req;

/**
 * send a request without response
 **/

- (void)post:(Request *)req;



@property(weak) id<SessionDelegate> delegate;
@end
