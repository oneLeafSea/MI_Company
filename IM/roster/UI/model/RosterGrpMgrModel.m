//
//  RosterGrpMgrModel.m
//  IM
//
//  Created by 郭志伟 on 15-1-20.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterGrpMgrModel.h"
#import "RosterItem.h"
#import "AppDelegate.h"

@implementation RosterGrpMgrModel

- (instancetype) initWithGrpList:(NSArray *)grplist {
    if (self = [super init]) {
        if (![self setup:grplist]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup:(NSArray *)glist {
    if (!glist) {
        return NO;
    }
    self.grpList = [[NSMutableArray alloc] initWithArray:glist];
    return YES;
}

- (void)moveGrp:(RosterGroup *)fromGrp
          toGrp:(RosterGroup *)toGrp
     completion:(void(^)(BOOL finished))completion {
    
    [APP_DELEGATE.user.rosterMgr moveRosterItems:fromGrp.items toGrpId:toGrp.gid key:APP_DELEGATE.user.key iv:APP_DELEGATE.user.iv url:APP_DELEGATE.user.imurl token:APP_DELEGATE.user.token completion:^(BOOL finished) {
        if (finished) {
            [fromGrp.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                RosterItem *item = obj;
                item.gid = toGrp.gid;
                [toGrp.items addObject:item];
            }];
        }
        completion(finished);
    }];
    
    
}

- (void)delGrpWith:(NSString *)gid  completion:(void(^)(BOOL finished)) completion{
    [APP_DELEGATE.user.rosterMgr delGrpByGid:gid key:APP_DELEGATE.user.key iv:APP_DELEGATE.user.iv url:APP_DELEGATE.user.imurl token:APP_DELEGATE.user.token compeltion:^(BOOL finished) {
        if (finished) {
            completion(finished);
        }
    }];
}

- (NSArray *)genGrp {
    __block NSMutableArray *grp = [[NSMutableArray alloc] init];
    [self.grpList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RosterGroup *rosterGrp = obj;
        NSDictionary *dictGrp = nil;
        if (rosterGrp.defaultGrp) {
             dictGrp = @{
                          @"gid":rosterGrp.gid,
                          @"w":[NSNumber numberWithUnsignedInteger:idx],
                          @"def":[NSNumber numberWithBool:YES],
                          @"n":rosterGrp.name
                          };
        } else {
            dictGrp = @{
                          @"gid":rosterGrp.gid,
                          @"w":[NSNumber numberWithUnsignedInteger:idx],
                          @"n":rosterGrp.name
                          };
        }
        [grp addObject:dictGrp];
    }];
    return grp;
}

- (RosterGroup *) getDefaultGroup {
    __block RosterGroup *grp = nil;
    [self.grpList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RosterGroup *g = obj;
        if (g.defaultGrp) {
            grp = g;
        }
    }];
    return grp;
}

@end
