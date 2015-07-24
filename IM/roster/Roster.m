//
//  Roster.m
//  IM
//
//  Created by 郭志伟 on 14-12-24.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Roster.h"
#import "RosterConstants.h"
#import "Utils.h"
#import "LogLevel.h"

@interface Roster() {
    NSMutableArray *m_grp;
}
@end

@implementation Roster

- (instancetype) initWithResult:(NSString *)result ext:(NSDictionary *)ext {
    if (self = [super init]) {
        if (![self setup:result ext:ext]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup:(NSString *)ret ext:(NSDictionary *)ext {
    if (ret == nil || ext == nil) {
        return NO;
    }
    _rosterItems = [[NSMutableArray alloc] initWithArray:[Utils arrayFromJsonData:[ret dataUsingEncoding:NSUTF8StringEncoding]] copyItems:YES];
    if (!_rosterItems) {
        DDLogWarn(@"WARN: m_retDict is nil.");
    }
    
    _extDict = ext;
    NSString *grp = [self.extDict objectForKey:@"grp"];
    NSArray *arr = [Utils arrayFromJsonData:[grp dataUsingEncoding:NSUTF8StringEncoding]];
    m_grp = [[NSMutableArray alloc] initWithArray:arr copyItems:YES];
    return YES;
}


- (NSArray *)rosterGroup {
    return m_grp;
}

- (void)setRosterGroup:(NSArray *)rosterGroup {
    m_grp = [[NSMutableArray alloc] initWithArray:rosterGroup copyItems:YES];
}

- (BOOL)isDefaultGrp:(NSString *)gid {
    __block BOOL ret = NO;
    [m_grp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *grp = obj;
        if ([grp objectForKey:@"def"]) {
            ret = YES;
            *stop = YES;
        }
    }];
    return ret;
}

- (void)addGroupItemWithName:(NSString *)grpName gid:(NSString *)gid {
    
    NSDictionary *newItem = @{
                              @"gid":gid,
                              @"n":grpName
                              };
    [m_grp addObject:newItem];
}

- (NSDictionary *)getGrpById:(NSString *)gid {
    __block NSDictionary *ret = nil;
    [m_grp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *grp = obj;
        if ([gid isEqualToString:grp[@"gid"]]) {
            ret = grp;
            *stop = YES;
        }
    }];
    return ret;
}

- (void)renameGrpItemWithNewName:(NSString *)grpName gid:(NSString *)gid {
    BOOL def = NO;
    if ([self isDefaultGrp:gid]) {
        def = YES;
    }
    NSDictionary *grpItem = [self getGrpById:gid];
    NSMutableDictionary *newItem = [[NSMutableDictionary alloc] initWithDictionary:grpItem copyItems:YES];
    [newItem setObject:grpName forKey:@"n"];
    [m_grp removeObject:grpItem];
    [m_grp addObject:newItem];
}

- (void)removeGrpWithId:(NSString *)gid {
    __block NSDictionary *searchGrp = nil;
    [m_grp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *item = obj;
        if ([gid isEqualToString:[item objectForKey:@"gid"]]) {
            searchGrp = item;
            *stop = YES;
        }
    }];
    if (searchGrp) {
        [m_grp removeObject:searchGrp];
    }
}

- (NSDictionary *)getDefaultGroup {
    __block NSDictionary *defaultGrp = nil;
    [m_grp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *grp = obj;
        if (grp[@"def"]) {
            defaultGrp = grp;
            *stop = YES;
        }
    }];
    return defaultGrp;
}

- (NSString *)genGid {
    __block NSInteger maxgid = -1;
    [m_grp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *grp = obj;
        NSString *gid = [grp objectForKeyedSubscript:@"gid"];
        NSInteger intGid = [gid integerValue];
        if (intGid > maxgid) {
            maxgid = intGid;
        }
    }];
    return [NSString stringWithFormat:@"%ld", maxgid+1];
}

- (NSNumber *)genWeight {
    __block NSInteger maxWeight = -1;
    [m_grp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *grp = obj;
        NSNumber* weight = [grp objectForKeyedSubscript:@"w"];
        NSInteger intWeight = [weight integerValue];
        if (intWeight > maxWeight) {
            maxWeight = intWeight;
        }
    }];
    return [NSNumber numberWithInteger:maxWeight + 1];
}

- (NSArray *) getRosterItemsInGrpId:(NSString *)gid {
    __block NSMutableArray *ret = [[NSMutableArray alloc] init];
    [self.rosterItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSDictionary *ri = obj;
        
    }];
    return ret;
}


@end
