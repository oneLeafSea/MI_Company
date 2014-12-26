//
//  RosterItemAddResult.m
//  IM
//
//  Created by 郭志伟 on 14-12-18.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "RosterItemAddResult.h"
#import "MessageConstants.h"
#import "LogLevel.h"

@interface RosterItemAddResult()

@property(copy) NSString *from;
@property(copy) NSString *to;
@property(copy) NSString *gid;

@end

@implementation RosterItemAddResult

- (instancetype)init {
    if (self = [super init]) {
        self.type = MSG_ROSTER_ITME_ADD_RESULT;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [self init]) {
        NSDictionary *dict = [self dictFromJsonData:data];
        DDLogInfo(@"<-- %@", dict);
        self.from = [dict objectForKey:@"from"];
        self.to = [dict objectForKey:@"to"];
        self.qid = [dict objectForKey:@"qid"];
        NSNumber *accept = [dict objectForKey:@"accept"];
        self.accept = [accept boolValue];
        self.gid = [dict objectForKey:@"gid"];
    }
    return self;
}

- (instancetype)initWithFrom:(NSString *)from
                          to:(NSString *)to
                         gid:(NSString *)gid {
    if (self = [self init]) {
        self.from = from;
        self.to = to;
        self.gid = gid;
    }
    return self;
}

- (NSData *)pkgData {
    NSDictionary *rard = @{
                           @"qid" : self.qid,
                           @"from": self.from,
                           @"to"  : self.to,
                           @"accept" : [NSNumber numberWithBool:self.accept],
                           @"gid" : self.gid
                           };
    DDLogInfo(@"--> %@", rard);
    NSData *data = [self jsonDataFromDict:rard];
    return data;
}

@end
