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
    NSDictionary *m_dict;
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
    m_dict = [[NSDictionary alloc] initWithDictionary:item copyItems:YES];
    if (!m_dict) {
        return NO;
    }
    return YES;
}


- (NSString *)uid {
    return [m_dict objectForKey:kRosterKeyUid];
}

- (NSString *)name {
    return [m_dict objectForKey:kRosterKeyUName];
}



@end