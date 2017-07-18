//
//  Request.h
//  WH
//
//  Created by guozw on 14-10-9.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
#import "Response.h"

@protocol RequestDelegate;

@interface Request : Message

- (NSData *)pkgData;

@property(nonatomic) NSString *qid;
@property(weak) id<RequestDelegate> delegate;

@end


@protocol RequestDelegate <NSObject>

- (void)request:(Request *)req response:(Response *)resp;

- (void)request:(Request *)req error:(NSError *)error;

@end
