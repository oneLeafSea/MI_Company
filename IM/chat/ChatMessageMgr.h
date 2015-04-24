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

#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>


@interface ChatMessageMgr : NSObject

- (instancetype)initWithSelfUid:(NSString *)sid
                            dbq:(FMDatabaseQueue *)dbq
                        session:(Session *)session;


- (BOOL)sendTextMesage:(NSString *)content
               msgType:(ChatMessageType) msgType
                    to:(NSString *)to
            completion:(void (^)(BOOL finished, id arguments))completion;

- (BOOL)sendVoiceMesageWithMsgType:(ChatMessageType)msgType
                    to:(NSString *)to
               duration:(NSInteger)duration
              audioPath:(NSString *)audioPath
            completion:(void (^)(BOOL finished, id arguments))completion;


- (void)sendImageMesageWithImgPath:(NSString *)imagPath
                          uuidName:(NSString *)uuidName
                          imgName:(NSString *)imgName
                         msgType:(ChatMessageType)msgType
                              to:(NSString *)to
                      completion:(void (^)(BOOL finished, id argument))completion;

- (void)sendFileMessageWithFilePath:(NSString *)filePath
                             msgType:(ChatMessageType)msgType
                                  to:(NSString *)to
                          completion:(void (^)(BOOL finished, id argument))completion;

- (void)InsertVideoChatWithFrom:(NSString *)from
                       fromName:(NSString *)fromName
                             to:(NSString *)to
                          msgId:(NSString *)msgId
                      connected:(BOOL)connected
                       interval:(NSUInteger)interval;

- (NSArray *)loadDbMsgsWithId:(NSString *)Id
                         type:(ChatMessageType)msgtype
                        limit:(UInt32)limit
                       offset:(UInt32)offset;

- (void)reset;

- (void)updateMsgWithId:(NSString *)msgId status:(ChatMessageStatus)status;

- (ChatMessage *)getLastGrpChatMsgWithGid:(NSString *)gid;

@end
