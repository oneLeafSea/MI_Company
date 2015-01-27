//
//  RecentViewModle.h
//  IM
//
//  Created by 郭志伟 on 15-1-21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentViewModle : NSObject

- (instancetype)initWithDbData:(NSArray *)dbData;

@property(readonly) NSArray *msgList;

@end
