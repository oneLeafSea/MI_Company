//
//  DictsMgr.m
//  WH
//
//  Created by 郭志伟 on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "DictsMgr.h"
#import "DictDb.h"
#import "Utils.h"
#import "DictsVersionSync.h"
#import "DictsDownloader.h"
#import "LogLevel.h"

@interface DictsMgr() <DictsVersionSyncDelegate, DictsDownloaderDelegate> {
    DictDb           *m_dictDb;
    DictsVersionSync *m_verSync;
    DictsDownloader  *m_downloader;
    BOOL             m_cancel;
    NSMutableDictionary *m_dicts;
}

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *org;

@end

@implementation DictsMgr

- (instancetype)initWithUserId:(NSString *)userId {
    if (self = [super init]) {
        _userId = userId;
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (void)syncDictsWithToken:(NSString *)token url:(NSString *)url org:(NSString *) org {
    
    self.token = token;
    self.url = url;
    self.org = org;
    m_cancel = NO;
    m_verSync = [[DictsVersionSync alloc] initWithDictDb:m_dictDb];
    m_verSync.delegate = self;
    [m_verSync syncWithToken:token url:url org:org];
}

- (void)cancelSyncDicts {
    m_cancel = YES;
}

- (void)removeAllDicts {
    NSArray *allDictName = [m_dictDb.dictsVer allDictNames];
    for (NSString *dictname in allDictName) {
        [m_dictDb rmDict:dictname];
    }
}


- (Dict *)getDictWithName:(NSString *)name {
    Dict *d = m_dicts[name];
    if (d) {
        d.filter = nil;
        return d;
    }
    
    d = [m_dictDb getDictByName:name];
    if (d) {
        [m_dicts setValue:d forKey:name];
    }
    return d;
}


#pragma mark - private method

- (BOOL) setup {
    m_dictDb = [[DictDb alloc] initWithDirectory:[[Utils documentPath] stringByAppendingPathComponent:_userId]];
    if (m_dictDb == nil) {
        return NO;
    }
    m_dicts = [[NSMutableDictionary alloc] initWithCapacity:128];
    return YES;
}

- (void) importDictWithName:(NSString *)dictName
                    version:(NSString *)version
                       data:(NSData *)data
                 completion:(void(^)(BOOL suc)) completion
{
    NSArray * params = @[dictName, version, data, completion];
    [self performSelectorInBackground:@selector(importDictWithParams:) withObject:params];
    
}

- (void) importDictWithParams:(NSArray *)params {
    __block void (^completion)(BOOL suc);
    completion = params[3];
    __block BOOL ret = [m_dictDb importDictWithName:params[0] version:params[1] data:params[2]];
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(ret);
    });
}

- (NSError *)genError:(NSInteger)errCode description:(NSString *)desp {
    NSError *err = [[NSError alloc] initWithDomain:@"DictsVersionSync class" code:errCode userInfo:@{@"description" : desp}];
    return err;
}

#pragma mark - DictsVersionSync delegate

- (void)DictsVersionSync:(DictsVersionSync *)dvs result:(NSArray *)result error:(NSError *)err {
    m_verSync = nil;
    if (err) {
        DDLogError(@"%@", err);
        return;
    }
    if (!result) {
        if ([self.delegate respondsToSelector:@selector(DictsMgr:endSyncVesion:)]) {
            [self.delegate DictsMgr:self endSyncVesion:YES];
        }
        if ([self.delegate respondsToSelector:@selector(DictsMgr:downloadDictSuccess:Error:)]) {
            [self.delegate DictsMgr:self downloadDictSuccess:YES Error:nil];
        }
        return;
    }
    if (m_cancel) {
        if ([self.delegate respondsToSelector:@selector(DictsMgr:cancelled:)]) {
            [self.delegate DictsMgr:self cancelled:YES];
        }
        return;
    }
    if ([self.delegate respondsToSelector:@selector(DictsMgr:endSyncVesion:)]) {
        [self.delegate DictsMgr:self endSyncVesion:YES];
    }
    m_downloader = [[DictsDownloader alloc] initWithParams:result];
    m_downloader.delegate = self;
    [m_downloader startDownloadWith:self.token url:self.url org:self.org user:self.userId];

}

- (void)DictsVersionSync:(DictsVersionSync *)dvs start:(BOOL)suc {
    if (suc) {
        if ([self.delegate respondsToSelector:@selector(DictsMgr:startSyncVesion:)]) {
            [self.delegate DictsMgr:self startSyncVesion:YES];
        }
    }
}


#pragma mark - DictsDownloader delegate

- (void)DictsDownloader:(DictsDownloader *)downloader dictName:(NSString *)dn version:(NSString *)ver data:(NSData *)data error:(NSError *)err {
    if (err) {
        DDLogError(@"%@", err);
        if ([self.delegate respondsToSelector:@selector(DictsMgr:downloadDictSuccess:Error:)]) {
            [self.delegate DictsMgr:self downloadDictSuccess:NO Error:err];
        }
        return;
    }
    
    if (m_cancel) {
        if ([self.delegate respondsToSelector:@selector(DictsMgr:cancelled:)]) {
            [self.delegate DictsMgr:self cancelled:YES];
        }
        return;
    }
    
    [self importDictWithName:dn version:ver data:data completion:^(BOOL suc) {
        if (!suc) {
            NSString *errDesc = [NSString stringWithFormat:@"解析字典:%@错误!", dn];
            DDLogError(errDesc);
            if ([self.delegate respondsToSelector:@selector(DictsMgr:downloadDictSuccess:Error:)]) {
                NSError *err = [self genError:DictsMgrErrorParseDict description:errDesc];
                [self.delegate DictsMgr:self downloadDictSuccess:NO Error:err];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(DictsMgr:downloadedDict:)]) {
                [self.delegate DictsMgr:self downloadedDict:dn];
            }
            if ([m_downloader hasNext]) {
                [m_downloader downNext];
            } else {
                if ([self.delegate respondsToSelector:@selector(DictsMgr:downloadDictSuccess:Error:)]) {
                    [self.delegate DictsMgr:self downloadDictSuccess:YES Error:nil];
                }
            }
        }
    }];
}

- (void)DictsDownloader:(DictsDownloader *)downloader DownloadingdictName:(NSString *)dn Downloadingversion:(NSString *)ver {
    if ([self.delegate respondsToSelector:@selector(DictsMgr:downloadingDict:)]) {
        [self.delegate DictsMgr:self downloadingDict:dn];
    }
}

@end
