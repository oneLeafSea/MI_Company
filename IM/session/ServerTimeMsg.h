//
//  ServerTimeMsg.h
//  WH
//
//  Created by guozw on 14-10-16.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Message.h"

@interface ServerTimeMsg : Message

- (instancetype)initWithTime:(NSString *)time;

@property(nonatomic, readonly) NSString *svrTime;
@end
