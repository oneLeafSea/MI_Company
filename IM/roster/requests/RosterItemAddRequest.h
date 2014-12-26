//
//  RosterAddRequest.h
//  IM
//
//  Created by 郭志伟 on 14-12-17.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Request.h"

@interface RosterItemAddRequest : Request

- (instancetype)initWithFrom:(NSString *)from
                     to:(NSString *)to
                    groupId:(NSString *)gid
                     reqmsg:(NSString *)reqmsg;

- (instancetype) initWithData:(NSData *)data;
- (NSData *)pkgData;

@end
