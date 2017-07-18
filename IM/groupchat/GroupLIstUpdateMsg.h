//
//  GroupLIstUpdateMsg.h
//  IM
//
//  Created by 郭志伟 on 15/9/21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "Request.h"

@interface GroupLIstUpdateMsg : Request

@property(nonatomic, copy) NSString *from;
@property(nonatomic, copy) NSString *to;

@end
