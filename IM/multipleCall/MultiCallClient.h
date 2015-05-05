//
//  MultiCallClient.h
//  IM
//
//  Created by 郭志伟 on 15/5/4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "session.h"

@protocol MultiCallClientDelegate;

typedef NS_ENUM(NSInteger, MultiCallClientState) {
    // Disconnected from servers.
    kMultiCallClientStateDisconnected,
    // Connecting to servers.
    kMultiCallClientStateConnecting,
    // Connected to servers.
    kMultiCallClientStateeConnected,
    kMultiCallClientStateLeave,
    kMultiCallClientStateTimeout
};

@interface MultiCallClient : NSObject

- (instancetype)initWithDelegate:(id<MultiCallClientDelegate>)delegate
                      roomServer:(NSURL *)url
                          iceUrl:(NSString *)iceUrl
                           token:(NSString *)token
                             key:(NSString *)key
                              iv:(NSString *)iv
                             uid:(NSString *)uid
                         invited:(BOOL)invited;


@property(nonatomic, readonly) BOOL invited;
@property(nonatomic, readonly) NSString *iceUrl;
@property(nonatomic, readonly) NSString *token;
@property(nonatomic, readonly) NSString *key;
@property(nonatomic, readonly) NSString *iv;
@property(nonatomic, weak) id<MultiCallClientDelegate> delegate;

@property(nonatomic, readonly) NSString *uid;
@property(nonatomic, readonly) NSString *roomId;
@property(nonatomic, readonly) NSURL    *serverHost;
@property(nonatomic, readonly) MultiCallClientState state;


- (void)createRoomId:(NSString *)rid
             session:(Session *)session
         talkingUids:(NSArray *)talkingUids;

- (void)joinRoomId:(NSString *)rid;

@end


@protocol MultiCallClientDelegate <NSObject>

- (void)MultiCallClient:(MultiCallClient *)cli didLeaveWithUid:(NSString *)uid deivce:(NSString *)device;
- (void)MultiCallClient:(MultiCallClient *)cli didJoinedWithUid:(NSString *)uid deivce:(NSString *)device;
- (void)MultiCallClient:(MultiCallClient *)cli didChangeState:(MultiCallClientState)state;

@end