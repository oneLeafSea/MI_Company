//
//  RosterItemNotification.m
//  IM
//
//  Created by 郭志伟 on 15-1-7.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItemNotification.h"

@interface RosterItemNotification() {
    NSDictionary *m_dict;
}
@end

@implementation RosterItemNotification

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        m_dict = [self dictFromJsonData:data];
    }
    return self;
}


- (NSString *)uid {
    NSString *uid = [m_dict objectForKey:@"fid"];
    return uid;
}

@end
