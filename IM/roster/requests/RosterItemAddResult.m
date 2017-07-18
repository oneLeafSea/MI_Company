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



@end

@implementation RosterItemAddResult

- (instancetype)init {
    if (self = [super init]) {
        self.type = IM_ROSTER_ITEM_ADD_RESULT;
    }
    return self;
}

//- (instancetype)initWithData:(NSData *)data {
//    if (self = [self init]) {
//        NSDictionary *dict = [self dictFromJsonData:data];
//        DDLogInfo(@"<-- %@", dict);
//        self.from = [dict objectForKey:@"from"];
//        self.to = [dict objectForKey:@"to"];
//        self.qid = [dict objectForKey:@"qid"];
//        NSNumber *accept = [dict objectForKey:@"accept"];
//        self.accept = [accept boolValue];
//        self.gid = [dict objectForKey:@"gid"];
//    }
//    return self;
//}

- (instancetype)initWithFrom:(NSString *)from
                          to:(NSString *)to
                         gid:(NSString *)gid
                        name:(NSString *)name
                         msg:(NSString *)msg{
    if (self = [self init]) {
        if (from == nil || to == nil || gid == nil || name == nil) {
            DDLogError(@"ERROR: init RosterItemAddResult.");
            return nil;
        }
        _from = [from copy];
        _to = [to copy];
        _gid = [gid copy];
        _name = [name copy];
        _msg = [msg copy];
    }
    return self;
}

- (NSData *)pkgData {
    
    NSDictionary *msg = [self dictFromJsonData:[self.msg dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableDictionary *m = [[NSMutableDictionary alloc] initWithDictionary:msg];
    [m setObject:self.gid forKey:@"resp_gid"];
    [m setObject:self.name forKey:@"resp_name"];
    NSString *pkgMsg = [[NSString alloc] initWithData:[self jsonDataFromDict:m] encoding:NSUTF8StringEncoding];
    
    NSDictionary *rard = @{
                           @"msgid" : self.qid,
                           @"from": self.from,
                           @"to"  : self.to,
                           @"accept" : [NSNumber numberWithBool:self.accept],
                           @"msg":pkgMsg
                           };
    DDLogInfo(@"--> %@", rard);
    NSData *data = [self jsonDataFromDict:rard];
    return data;
}

@end
