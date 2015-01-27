//
//  LoginProcedures.h
//  WH
//
//  Created by guozw on 14-10-16.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"

@protocol LoginProceduresDelegate;

/**
 * LoginProcedures 
 * @note You should set key IP and port in NSUserDefaults.
 **/

@interface LoginProcedures : NSObject

/**
 * @param sess Session instance.
 * @param userId 
 * @param pwd password.
 * @return if vaule is YES mean success. else fail.
 **/

- (BOOL)loginWithUserId:(NSString *)userId
                     pwd:(NSString *)pwd
                 timeout:(NSTimeInterval)timeout;

- (void)stop;

@property(weak) id<LoginProceduresDelegate> delegate;
@property(readonly) NSString *userId;
@property(readonly) NSString *pwd;
@end


@protocol LoginProceduresDelegate <NSObject>

- (void)loginProceduresWaitingSvrTime:(LoginProcedures *)proc;
- (void)loginProcedures:(LoginProcedures *)proc login:(BOOL)suc error:(NSString *)error;
- (void)loginProcedures:(LoginProcedures *)proc recvPush:(BOOL)suc error:(NSString *)error;
- (void)loginProceduresConnectFail:(LoginProcedures *)proc timeout:(BOOL)timeout error:(NSError *)error;

- (void)loginProcedures:(LoginProcedures *)proc getRoster:(BOOL)suc;
@end