//
//  Push.h
//  WH
//
//  Created by 郭志伟 on 14-10-14.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
#import "Session.h"
@interface Push : Message

/**
 *
 **/
- (BOOL)parseData:(UInt32)type data:(NSData *)data;

/**
 *
 **/
- (void)returnReceipt:(Session *)sess;


@property (nonatomic, readonly) NSString          * msgID;
@property (nonatomic, readonly) NSString          * pushType;
@property (nonatomic, readonly) NSString          * title;
@property (nonatomic, readonly) NSString          * content;
@property (nonatomic, readonly) NSString          * params;
@property (nonatomic, readonly) NSString          * msgtime;
@property (nonatomic, readonly) NSString          * user;
@property (nonatomic, readonly) NSString          * device;
@property (nonatomic, readonly) NSString          * sid;

@end
