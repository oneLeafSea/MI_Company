//
//  DictsDownloader.h
//  WH
//
//  Created by guozw on 14-10-23.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DictsDownloaderDelegate;

typedef NS_ENUM(NSUInteger, DictsDownloaderError) {
    DictsDownloaderErrorParam          = 1,
    DictsDownloaderErrorBadResp        = 2
};

@interface DictsDownloader : NSObject

- (instancetype) initWithParams:(NSArray *)params;

- (void)startDownloadWith:(NSString *)token url:(NSString *)url org:(NSString *)org user:(NSString *)user;

- (BOOL)hasNext;
- (void)downNext;

- (void)stop;

@property(weak) id<DictsDownloaderDelegate> delegate;
@end


@protocol DictsDownloaderDelegate <NSObject>

- (void)DictsDownloader:(DictsDownloader *)downloader dictName:(NSString *)dn version:(NSString *)ver data:(NSData *)data error:(NSError *)err;

- (void)DictsDownloader:(DictsDownloader *)downloader DownloadingdictName:(NSString *)dn Downloadingversion:(NSString *)ver;
@end