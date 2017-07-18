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

@property NSMutableArray *rosterItems;
@property(readonly) NSDictionary *extDict;
@property NSArray *rosterGroup;


- (void)addGroupItemWithName:(NSString *)grpName gid:(NSString *)gid;
- (void)renameGrpItemWithNewName:(NSString *)grpName gid:(NSString *)gid;
- (void)removeGrpWithId:(NSString *)gid;
- (NSDictionary *)getDefaultGroup;
- (NSString *)genGid;
- (NSNumber *)genWeight;
- (BOOL)isDefaultGrp:(NSString *)gid;
- (NSDictionary *)getGrpById:(NSString *)gid;

- (NSArray *) getRosterItemsInGrpId:(NSString *)gid;
//- (void)removeRosterItemWithId:(NSString *)uid;

@end

