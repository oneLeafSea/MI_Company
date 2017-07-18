//
//  RecentMsgItem.h
//  IM
//
//  Created by 郭志伟 on 15-1-21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentMsgItem : NSObject

@property NSString *msgid;
@property NSString *from;
@property NSString *to;
@property NSUInteger msgtype;
@property NSString *content;
@property NSString *ext;
@property NSString *time;
@property NSString *badge;

- (NSDictionary *)dictContent;

@end
