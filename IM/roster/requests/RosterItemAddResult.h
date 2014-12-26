//
//  RosterItemAddResult.h
//  IM
//
//  Created by 郭志伟 on 14-12-18.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Request.h"

@interface RosterItemAddResult : Request

- (instancetype)initWithFrom:(NSString *)from
                          to:(NSString *)to
                         gid:(NSString *)gid;

- (instancetype)initWithData:(NSData *)data;

- (NSData *)pkgData;

@property BOOL accept;

@end
