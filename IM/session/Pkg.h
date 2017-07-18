//
//  bsonPkg.h
//  WH
//
//  Created by 郭志伟 on 14-10-14.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

#pragma mark -Pkg


@protocol PkgDeleage;

@interface Pkg : NSObject

- (instancetype) initWithType:(UInt32) dataType data:(NSData *)data;


@property(assign) UInt32             dataLen;
@property(assign) UInt32             dataType;
@property(nonatomic) NSData          *data;

@property(weak) id<PkgDeleage>       delegate;

@end


@protocol PkgDeleage <NSObject>

- (Message *)parsePkgWithType:(UInt32)type data:(NSData *)data;

@end