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
    NSMutableDictionary *m_dict;
    NSDictionary *m_retDict;
    NSDictionary *m_extDict;
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
    m_retDict = [Utils dictFromJsonData:[ret dataUsingEncoding:NSUTF8StringEncoding]];
    if (!m_retDict) {
        DDLogWarn(@"WARN: m_retDict is nil.");
    }
    
    m_extDict = ext;
    return YES;
}

- (NSString*)grp {
    return [m_extDict objectForKey:@"grp"];
}



@end
