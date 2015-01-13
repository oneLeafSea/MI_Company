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
    NSMutableDictionary *m_grp;
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
    _rosterItems = [Utils arrayFromJsonData:[ret dataUsingEncoding:NSUTF8StringEncoding]];
    if (!_rosterItems) {
        DDLogWarn(@"WARN: m_retDict is nil.");
    }
    
    _extDict = ext;
    NSString *grp = [self.extDict objectForKey:@"grp"];
    NSDictionary *dict = [Utils dictFromJsonData:[grp dataUsingEncoding:NSUTF8StringEncoding]];
    m_grp = [[NSMutableDictionary alloc] initWithDictionary:dict copyItems:YES];
    return YES;
}


- (NSDictionary *)rosterGroup {
    return m_grp;
}

- (void)addGroupItemWithName:(NSString *)grpName gid:(NSString *)gid {
    [m_grp setObject:grpName forKey:gid];
}

- (NSString *)genGid {
    __block NSInteger maxgid = -1;
    [m_grp enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *gid = key;
        NSInteger intGid = [gid integerValue];
        if (intGid > maxgid) {
            maxgid = intGid;
        }
    }];
    return [NSString stringWithFormat:@"%ld", maxgid+1];
}


@end
