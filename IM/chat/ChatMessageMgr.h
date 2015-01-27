//
//  ChatMessageMgr.h
//  IM
//
//  Created by 郭志伟 on 15-1-14.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMessage.h"
#import "FMDB.h"
#import "session.h"

@interface ChatMessageMgr : NSObject

- (instancetype)initWithSelfUid:(NSString *)sid
                            dbq:(FMDatabaseQueue *)dbq
                        session:(Session *)session;


- (BOOL)sendTextMesage:(NSString *)content
               msgType:(ChatMessageType) msgType
                    to:(NSString *)to
            completion:(void (^)(BOOL finished))completion;

- (BOOL)sendVoiceMesage:(NSString *)content
               msgType:(ChatMessageType)msgType
                    to:(NSString *)to
            completion:(void (^)(BOOL finished))completion;

- (BOOL)sendVideoMesage:(NSString *)content
               msgType:(ChatMessageType)msgType
                    to:(NSString *)to
            completion:(void (^)(BOOL  finished))completion;

- (BOOL)sendImageMesage:(NSString *)content
               msgType:(ChatMessageType)msgType
                    to:(NSString *)to
            completion:(void (^)(BOOL finished))completion;

- (NSArray *)loadDbMsgsWithId:(NSString *)Id
                         type:(ChatMessageType)msgtype
                        limit:(UInt32)limit
                       offset:(UInt32)offset;

- (void)reset;

@end
