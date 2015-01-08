//
//  RosterItemNotification.h
//  IM
//
//  Created by 郭志伟 on 15-1-7.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "Request.h"

@interface RosterItemNotification : Request

- (instancetype)initWithData:(NSData *)data;
@property(readonly) NSString *uid;

@end
