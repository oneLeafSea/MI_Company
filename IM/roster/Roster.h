//
//  Roster.h
//  IM
//
//  Created by 郭志伟 on 14-12-24.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Roster : NSObject

- (instancetype) initWithResult:(NSString *)result ext:(NSDictionary *)ext;

@property(readonly) NSArray *rosterItems;
@property(readonly) NSDictionary *extDict;
@property(readonly) NSDictionary *rosterGroup;

- (void)addGroupItemWithName:(NSString *)grpName gid:(NSString *)gid;
- (NSString *)genGid;

@end

