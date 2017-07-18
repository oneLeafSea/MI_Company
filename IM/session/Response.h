//
//  Response.h
//  WH
//
//  Created by 郭志伟 on 14-10-14.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@interface Response : Message

- (BOOL)parseData:(UInt32)type data:(NSData *)data;

@property(nonatomic) NSString *qid;
@end

