//
//  RTMessageData.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTMessageMediaData.h"

@protocol RTMessageData <NSObject>

- (NSString *)senderId;

- (NSString *)senderDisplayName;

- (NSDate *)date;

- (BOOL)isMediaMessage;

- (NSUInteger)messageHash;

@optional

- (NSString *)text;

- (id<RTMessageMediaData>)media;

@end
