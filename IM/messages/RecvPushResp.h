//
//  RecvPushResp.h
//  WH
//
//  Created by guozw on 14-10-16.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Response.h"

@interface RecvPushResp : Response

@property(nonatomic, readonly) NSDictionary *respData;
@end
