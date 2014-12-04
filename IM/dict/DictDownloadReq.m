//
//  DictDownloadReq.m
//  WH
//
//  Created by guozw on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "DictDownloadReq.h"
#import "NSJSONSerialization+StrDictConverter.h"
#import "LogLevel.h"

@interface DictDownloadReq() {
    NSMutableDictionary  *m_dictItem;
}
@end

@implementation DictDownloadReq

- (instancetype) initWithToken:(NSString *)token url:(NSString *)url org:(NSString *)org {
    if (self = [super initWithToken:token url:url org:org]) {

    }
    return self;
}


- (NSDictionary *)paramKeyVal {
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:m_dictItem copyItems:YES];
    

    [dict setValue:self.org forKey:@"org"];
    [dict setValue:self.user forKey:@"user"];
    
    return dict;
}

- (NSUInteger)reqCode {
    return ReqCodeDictDownload;
}

- (void)setDictItem:(NSDictionary *)dictItem {
    m_dictItem = [[NSMutableDictionary alloc] init];
    NSArray *allKey = [dictItem allKeys];
    for (NSString *key in allKey) {
        NSObject *obj = [dictItem objectForKey:key];
        if ([obj isKindOfClass:[NSNumber class]]) {
            NSNumber *num = (NSNumber *)obj;
            NSString *strNum = [num stringValue];
            [m_dictItem setValue:strNum forKey:key];
        } else {
            [m_dictItem setValue:obj forKey:key];
        }
        
    }
}

- (NSDictionary *)dictItem {
    return m_dictItem;
}

@end
