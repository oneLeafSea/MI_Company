//
//  RosterItemDelRequest.h
//  IM
//
//  Created by 郭志伟 on 15-1-6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Request.h"

typedef NS_ENUM(UInt32, RosterItemDelRequestStatus){
    RosterItemDelRequestStatusUnkown,
    RosterItemDelRequestRequesting,
    RosterItemDelRequestStatusACK,
    RosterItemDelRequestStatusError
};

@interface RosterItemDelRequest : Request

- (instancetype)initWithFrom:(NSString *)from to:(NSString *)to;

@property(readonly)NSString *from;
@property(readonly)NSString *to;
@property RosterItemDelRequestStatus status;
@end
