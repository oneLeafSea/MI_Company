//
//  DictsDownloader.m
//  WH
//
//  Created by guozw on 14-10-23.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "DictsDownloader.h"
#import "DictDownloadReq.h"
#import "AFJSONRPCClient.h"
#import "LogLevel.h"
#import "SSZipArchive.h"

@interface DictsDownloader() {
    NSMutableArray *m_params;
    BOOL           m_stop;
}

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *org;
@property (nonatomic, copy) NSString *user;

@end

@implementation DictsDownloader

- (instancetype) initWithParams:(NSArray *)params {
    if (self = [super init]) {
        m_params = [params mutableCopy];
    }
    return self;
}


- (void)startDownloadWith:(NSString *)token url:(NSString *)url org:(NSString *)org user:(NSString *)user {
    if (m_params.count == 0) {
        return;
    }
    
    if (token == nil || url == nil || org == nil || user == nil) {
        if ([self.delegate respondsToSelector:@selector(DictsDownloader:dictName:version:data:error:)]) {
            NSError *err = [self genError:DictsDownloaderErrorParam description:@"传入参数错误！"];
            [self.delegate DictsDownloader:nil dictName:nil version:nil data:nil error:err];
        }
    }
    
    self.token = token;
    self.url = url;
    self.org = org;
    self.user = user;
    [self downloadWith:self.token url:self.url org:self.org user:self.user];
}

- (void)downloadWith:(NSString *)token url:(NSString *)url org:(NSString *)org user:(NSString *)user {
    if (m_stop || m_params.count == 0) {
        return;
    }
    NSDictionary *dictItem = [m_params objectAtIndex:0];
    DictDownloadReq *req = [[DictDownloadReq alloc] initWithToken:self.token url:self.url org:self.org];
    req.user = self.user;
    req.dictItem = dictItem;
    
    if ([self.delegate respondsToSelector:@selector(DictsDownloader:DownloadingdictName:Downloadingversion:)]) {
        [self.delegate DictsDownloader:self DownloadingdictName:dictItem[@"name"] Downloadingversion:dictItem[@"version"]];
    }
    
    AFJSONRPCClient *client = [AFJSONRPCClient clientWithEndpointURL:req.url];
    
    [client invokeMethod:req.method withParameters:req.params requestId:req.resultId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resp = responseObject;
            NSString *err = [resp objectForKey:@"error"];
            if (!err) {
                NSDictionary *results = resp[@"results"];
                NSString *dictName = results[@"name"];
                NSString *version = results[@"version"];
                NSString *binStr = resp[@"binary"];
                NSData *data = [self getUnzipData:binStr dictName:dictName];
                if ([self.delegate respondsToSelector:@selector(DictsDownloader:dictName:version:data:error:)]) {
                    [self.delegate DictsDownloader:self dictName:dictName version:version data:data error:nil];
                }
            } else {
                DDLogInfo(@"%@", err);
                NSError *error = [self genError:DictsDownloaderErrorParam description:err];
                if ([self.delegate respondsToSelector:@selector(DictsDownloader:dictName:version:data:error:)]) {
                    [self.delegate DictsDownloader:self dictName:nil version:nil data:nil error:error];
                }
            }
        } else {
            NSError *error = [self genError:DictsDownloaderErrorBadResp description:@"错误的返回类型"];
            if ([self.delegate respondsToSelector:@selector(DictsDownloader:dictName:version:data:error:)]) {
                [self.delegate DictsDownloader:self dictName:nil version:nil data:nil error:error];
            }
        }
        [m_params removeObjectAtIndex:0];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(DictsDownloader:dictName:version:data:error:)]) {
            [self.delegate DictsDownloader:self dictName:nil version:nil data:nil error:error];
        }
    }];
    
    
}

- (BOOL)hasNext {
    if (m_params.count > 0) {
        return YES;
    }
    return NO;
}
- (void)downNext {
    [self downloadWith:self.token url:self.token org:self.org user:self.user];
}

- (void)stop {
    m_stop = YES;
}

- (NSData *)getUnzipData:(NSString *)base64Str dictName:(NSString *)dictname {
    NSData *zipData = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *zipFileName = [NSString stringWithFormat:@"%@.zip", dictname];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:zipFileName];
    BOOL ret = [zipData writeToFile:filePath atomically:YES];
    if (!ret) {
        DDLogError(@"保存字典:%@ 错误", dictname);
        return nil;
    }
    
    ret = [SSZipArchive unzipFileAtPath:filePath toDestination:NSTemporaryDirectory()];
    if (!ret) {
        DDLogError(@"解压字典:%@ 错误", dictname);
        return nil;
    }
    NSError *err = nil;
    ret = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&err];
    if (!ret) {
        DDLogError(@"删除zip字典：%@ err: %@", dictname, err);
    }
    
    NSString *unzipFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:dictname];
    NSData *data = [NSData dataWithContentsOfFile:unzipFilePath];
    
    err = nil;
    ret = [[NSFileManager defaultManager] removeItemAtPath:unzipFilePath error:&err];
    if (!ret) {
        DDLogError(@"删除unzip字典：%@ err:%@", dictname, err);
    }
    return data;
    
}

- (NSError *)genError:(NSInteger)errCode description:(NSString *)desp {
    NSError *err = [[NSError alloc] initWithDomain:@"DictsVersionSync class" code:errCode userInfo:@{@"description" : desp}];
    return err;
}

@end
