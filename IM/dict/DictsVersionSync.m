//
//  DictVersionSync.m
//  WH
//
//  Created by 郭志伟 on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "DictsVersionSync.h"
#import "LogLevel.h"
#import "AFJSONRPCClient.h"
#import "DictsVersionReq.h"
#import "NSJSONSerialization+StrDictConverter.h"

static NSString *kPlistDictName = @"dictname";
static NSString *kPlistType = @"plist";

@interface DictsVersionSync() {
    NSDictionary *m_willUpdateDictNames;
}

@end

@implementation DictsVersionSync

- (instancetype) initWithDictDb:(DictDb *) db {
    if (self = [super init]) {
        if (![self setup:db]) {
            self = nil;
        }
    }
    return self;
}

- (NSArray *)loadDictNamesFromPlist {
    NSArray *plistContent =  [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kPlistDictName ofType:kPlistType]];
    return plistContent;
}

- (BOOL)setup:(DictDb *)db {
    NSArray *dbDictNames = [db.dictsVer allDictNames];
    NSArray *plistDictNames = [self loadDictNamesFromPlist];
    
    // 删除不用的字典
    NSMutableArray *delDictNames = [dbDictNames mutableCopy];
    [delDictNames removeObjectsInArray:plistDictNames];
    
    for (NSString *dn in delDictNames) {
        BOOL ret = [db rmDict:dn];
        if (!ret) {
            DDLogError(@"删除字典%@失败", dn);
        }
    }
    
    // 合并字典
    dbDictNames = [db.dictsVer allDictNames];
    NSMutableSet *set = [NSMutableSet setWithArray:plistDictNames];
    [set addObjectsFromArray:dbDictNames];
    NSArray *mergedDictNames = [set allObjects];
    
    NSMutableDictionary *willUpdateDictNames = [[NSMutableDictionary alloc] initWithCapacity:256];
    for (NSString *dictName in mergedDictNames) {
        NSString *version = db.dictsVer.data[dictName];
        if (version == nil) {
            version = @"0";
        }
        [willUpdateDictNames setValue:version forKey:dictName];
    }
    
    
    m_willUpdateDictNames = willUpdateDictNames;
    return YES;
}

- (void)syncWithToken:(NSString *)token url:(NSString *)url org:(NSString *) org {
    if (token == nil || url == nil || org == 0) {
        if ([self.delegate respondsToSelector:@selector(DictsVersionSync:result:error:)]) {
            NSError *err = [self genError:DictsVersionSyncErrorParam description:@"传入参数错误！"];
            [self.delegate DictsVersionSync:self result:nil error:err];
        }
        return;
    }
    if (m_willUpdateDictNames.count == 0) {
        DDLogWarn(@"m_willUpdateDictNames count is 0!!");
        if ([self.delegate respondsToSelector:@selector(DictsVersionSync:result:error:)]) {
            [self.delegate DictsVersionSync:self result:nil error:nil];
        }
        return;
    }
    
    DictsVersionReq *req = [[DictsVersionReq alloc] initWithToken:token url:url org:org];
    
    NSArray *allKeys = [m_willUpdateDictNames allKeys];
    
    for (NSString *dictName in allKeys) {
        NSString *ver = m_willUpdateDictNames[dictName];
        [req addDictInfo:dictName version:ver];
    }
    
    if ([self.delegate respondsToSelector:@selector(DictsVersionSync:start:)]) {
        [self.delegate DictsVersionSync:self start:YES];
    }
    
    AFJSONRPCClient *client = [AFJSONRPCClient clientWithEndpointURL:req.url];
    [client invokeMethod:req.method withParameters:req.params requestId:req.resultId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resp = responseObject;
            NSString *err = [resp objectForKey:@"error"];
            if (err) {
                NSError * e = [self genError:DictsVersionSyncErrorParam description:err];
                if ([self.delegate respondsToSelector:@selector(DictsVersionSync:result:error:)]) {
                    [self.delegate DictsVersionSync:self result:nil error:e];
                }
            } else {
                NSDictionary *resp = responseObject;
                NSDictionary *results = resp[@"results"];
                NSString *ret = results[@"result"];
                NSArray *arr = [NSJSONSerialization objFromJsonString:ret];
                if ([self.delegate respondsToSelector:@selector(DictsVersionSync:result:error:)]) {
                    [self.delegate DictsVersionSync:self result:arr error:nil];
                }
            }
        } else {
            NSError * err = [self genError:DictsVersionSyncErrorBadResp description:@"返回数据类型不正确！"];
            if ([self.delegate respondsToSelector:@selector(DictsVersionSync:result:error:)]) {
                [self.delegate DictsVersionSync:self result:nil error:err];
            }

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(DictsVersionSync:result:error:)]) {
            [self.delegate DictsVersionSync:self result:nil error:error];
        }
    }];
}

- (NSError *)genError:(NSInteger)errCode description:(NSString *)desp {
    NSError *err = [[NSError alloc] initWithDomain:@"DictsVersionSync class" code:errCode userInfo:@{@"description" : desp}];
    return err;
}

@end
