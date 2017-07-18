//
//  RosterItemAddResult.h
//  IM
//
//  Created by 郭志伟 on 14-12-18.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Request.h"

typedef NS_ENUM(UInt32, RosterItemAddResultStatus) {
    RosterItemAddResultUnkown,
    RosterItemAddResultRequesting,
    RosterItemAddResultAck,
    RosterItemAddResultError
};

@interface RosterItemAddResult : Request

- (instancetype)initWithFrom:(NSString *)from
                          to:(NSString *)to
                         gid:(NSString *)gid
                        name:(NSString *)name
                         msg:(NSString *)msg;

//- (instancetype)initWithData:(NSData *)data;



@property BOOL accept;
@property(readonly) NSString *msg;
@property(readonly) NSString *from;
@property(readonly) NSString *to;
@property(readonly) NSString *gid;
@property(readonly) NSString *name;
@property RosterItemAddResultStatus status;

@end
