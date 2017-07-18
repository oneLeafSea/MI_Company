//
//  RosterGroupContainer.m
//  IM
//
//  Created by 郭志伟 on 14-12-25.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "RosterGroupContainer.h"
#import "RosterItem.h"
#import "RosterGroup.h"
#import "LogLevel.h"
#import "RosterConstants.h"

@interface RosterGroupContainer()

@end

@implementation RosterGroupContainer

- (instancetype)initWithItems:(NSArray *)items
                           grps:(NSArray *)grps
                          desc:(NSDictionary *)desc {
    if (self = [super init]) {
        if (![self parseItems:items grps:grps desc:desc]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)parseItems:(NSArray *)items
               grps:(NSArray *)grps
              desc:(NSDictionary *)desc {
    if (items.count == 0) {
        return YES;
    }
    
    NSMutableDictionary *groups = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dict in grps) {
        RosterGroup *rg = [[RosterGroup alloc] init];
        rg.gid = [dict objectForKey:kRosterKeyGid];
        rg.name = [dict objectForKey:kRosterKeyGName];
        [groups setValue:rg forKey:rg.gid];
    }
    
    for (NSDictionary *item in items) {
        RosterItem *ri = [[RosterItem alloc] initWithDict:item];
        NSString *gid = [desc objectForKey:ri.uid];
        if (!gid) {
            DDLogError(@"ERROR: can't find gid from uid(%@)", ri.uid);
            return NO;
        }
        RosterGroup *rg = [groups objectForKey:gid];
        [rg.items addObject:ri];
    }
    
    _groups = groups;
    
    return YES;
}

@end
