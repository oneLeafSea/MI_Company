//
//  WebRtcNotifyMsg.m
//  IM
//
//  Created by 郭志伟 on 15-3-26.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "WebRtcNotifyMsg.h"
#import "Loglevel.h"
#import "MessageConstants.h"
#import "NSDate+Common.h"

//{
//    content = "{\"rid\":\"8ca23f1c-a837-48cc-9268-059d7c4fad4d\"}";
//    from = xyy;
//    "from_res" = Android;
//    msgid = "f37c088d-6324-4eeb-94b3-d83c0ff192aa";
//    time = "2015-03-26 10:10:32";
//    to = gzw;
//}

@implementation WebRtcNotifyMsg {
    NSMutableDictionary *_dict;
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [self init]) {
        if (![self setup:data]) {
            self = nil;
        }
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = IM_VOICEVIDEO;
    }
    return self;
}

- (instancetype)initWithFrom:(NSString *)from to:(NSString *)to rid:(NSString *)rid {
    if (self = [self init]) {
        _from = from;
        _to = to;
        _rid = rid;
    }
    return self;
}

- (BOOL)setup:(NSData *)data {
    NSDictionary *dict = [self dictFromJsonData:data];
    _dict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    DDLogInfo(@"<-- %@", dict);
    self.qid = [dict objectForKey:@"msgid"];
    if (self.qid == nil) {
        DDLogError(@"ERROR: webrtc msg do not have msgid key.");
        return NO;
    }
    _from = [_dict objectForKey:@"from"];
    _from_res = [_dict objectForKey:@"from_res"];
    _time = [dict objectForKey:@"time"];
    NSString *content = [dict objectForKey:@"content"];
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    _content = [self dictFromJsonData:contentData];
    _rid = [_content objectForKey:@"rid"];
    return YES;
}


- (NSData *)pkgData {
    NSDictionary *dictContent = @{
                                  @"rid":_rid
                                  };
    if (self.contentType) {
        dictContent = @{
                        @"type":self.contentType,
                        @"rid":_rid
                        };
    }
    
    NSData *content = [self jsonDataFromDict:dictContent];
    NSString *body = [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
    self.time = [[NSDate Now] formatWith:nil];
    NSDictionary *dict = @{
                           @"from" : self.from,
                           @"to"   : self.to,
                           @"time" : self.time,
                           @"content" : body,
                           @"msgid": self.qid,
                           @"fromRes":@"iphone"
                           };
    DDLogInfo(@"--> %@", dict);
    NSData *data = [self jsonDataFromDict:dict];
    return data;
}


@end
