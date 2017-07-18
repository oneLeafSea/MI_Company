//
//  RecentMsgItem.m
//  IM
//
//  Created by 郭志伟 on 15-1-21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RecentMsgItem.h"
#import "Utils.h"

@implementation RecentMsgItem

- (NSDictionary *)dictContent {
    NSData *data = [self.content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *cnt = [Utils dictFromJsonData:data];
    return cnt;
}

@end
