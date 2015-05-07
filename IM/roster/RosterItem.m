//
//  RosterItem.m
//  IM
//
//  Created by 郭志伟 on 14-12-24.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "RosterItem.h"
#import "RosterConstants.h"

@interface RosterItem() {
    NSMutableDictionary *m_dict;
}


@end

@implementation RosterItem

-(instancetype) initWithDict:(NSDictionary *)item {
    if (self = [super init]) {
        if (![self setup:item]) {
            self = nil;
        }
    }
    
    return self;
}

- (BOOL) setup:(NSDictionary *) item {
    m_dict = [[NSMutableDictionary alloc] initWithDictionary:item copyItems:YES];
    if (!m_dict) {
        return NO;
    }
    return YES;
}

- (instancetype)initWithUid:(NSString *)uid
                       name:(NSString *)name {
    if (self = [super init]) {
        m_dict = [[NSMutableDictionary alloc] init];
        [m_dict setObject:uid forKey:@"fid"];
        [m_dict setObject:name forKey:@"fname"];
    }
    return self;
}


- (NSString *)uid {
    return [m_dict objectForKey:@"fid"];
}

- (NSString *)name {
    return [m_dict objectForKey:@"fname"];
}

- (NSString *)gid {
    return [m_dict objectForKey:kRosterKeyGid];
}

- (void) setGid:(NSString *)gid {
    [m_dict setObject:gid forKey:kRosterKeyGid];
}

- (NSString *)sign {
    return [m_dict objectForKey:@"sign"];
}

@end
