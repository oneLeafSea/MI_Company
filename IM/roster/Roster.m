//
//  Roster.m
//  IM
//
//  Created by 郭志伟 on 14-12-24.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Roster.h"
#import "RosterConstants.h"

@interface Roster() {
    NSMutableDictionary *m_dict;
}
@end

@implementation Roster

- (instancetype)init
{
    self = [super init];
    if (self) {
        m_dict = [[NSMutableDictionary alloc] initWithCapacity:32];
    }
    return self;
}

- (NSString *)uid {
   return [m_dict valueForKey:kRosterTableUid];
}

- (void)setUid:(NSString *)uid {
    [m_dict setValue:uid forKey:kRosterTableUid];
}

- (NSString *)desc {
    return [m_dict valueForKey:kRosterTableDesc];
}

- (void)setDesc:(NSString *)desc {
    [m_dict setValue:desc forKey:kRosterTableDesc];
}

- (NSString *)grp {
    return [m_dict valueForKey:kRosterTableGrp];
}

- (void)setGrp:(NSString *)grp {
    [m_dict setValue:grp forKey:kRosterTableGrp];
}

- (NSString *)items {
    return [m_dict valueForKey:kRosterTableItems];
}

- (void)setItems:(NSString *)items {
    [m_dict setValue:items forKey:kRosterTableItems];
}

- (NSString *)ver {
    return [m_dict valueForKey:kRosterTableVer];
}

- (void)setVer:(NSString *)ver {
    [m_dict setValue:ver forKey:kRosterTableVer];
}


@end
