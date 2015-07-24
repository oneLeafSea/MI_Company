//
//  RTMessage.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTMessageData.h"

typedef NS_ENUM(UInt32, RTMessageStatus) {
    RTMessageStatusUnkown,
    RTMessageStatusSending,
    RTMessageStatusSent,
    RTMessageStatusRecved,
    RTMessageStatusRecving,
    RTMessageStatusSendError,
    RTMessageStatusRecvError
};

@interface RTMessage : NSObject <RTMessageData, NSCoding, NSCopying>

@property (copy, nonatomic, readonly) NSString *senderId;

@property (copy, nonatomic, readonly) NSString *senderDisplayName;

@property (copy, nonatomic, readonly) NSDate *date;

@property (assign, nonatomic, readonly) BOOL isMediaMessage;

@property (copy, nonatomic, readonly) NSString *text;

@property (copy, nonatomic, readonly) id<RTMessageMediaData> media;


@property (nonatomic, assign) RTMessageStatus status;


#pragma mark - Initialization

+ (instancetype)messageWithSenderId:(NSString *)senderId
                        displayName:(NSString *)displayName
                               text:(NSString *)text;

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                            text:(NSString *)text;
+ (instancetype)messageWithSenderId:(NSString *)senderId
                        displayName:(NSString *)displayName
                              media:(id<RTMessageMediaData>)media;

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                           media:(id<RTMessageMediaData>)media;

@end
