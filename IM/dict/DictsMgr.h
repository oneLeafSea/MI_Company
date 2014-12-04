//
//  DictsMgr.h
//  WH
//
//  Created by 郭志伟 on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dict.h"

@protocol DictsMgrDelegate;

typedef NS_ENUM(NSUInteger, DictsMgrError) {
    DictsMgrErrorParseDict          = 1,
    DictsMgrErrorDownloadDictError  = 2
};

@interface DictsMgr : NSObject

- (instancetype)initWithUserId:(NSString *)userId;

- (void)syncDictsWithToken:(NSString *)token url:(NSString *)url org:(NSString *) org;

- (void)cancelSyncDicts;

- (void)removeAllDicts;

- (Dict *)getDictWithName:(NSString *)name;


@property (readonly)NSString     *userId;
@property (weak)    id<DictsMgrDelegate> delegate;
@end


@protocol DictsMgrDelegate <NSObject>
- (void)DictsMgr:(DictsMgr *)mgr startSyncVesion:(BOOL) success;
- (void)DictsMgr:(DictsMgr *)mgr endSyncVesion:(BOOL) success;
- (void)DictsMgr:(DictsMgr *)mgr downloadDictSuccess:(BOOL) suc Error:(NSError *)err;
- (void)DictsMgr:(DictsMgr *)mgr downloadingDict:(NSString *)dn;
- (void)DictsMgr:(DictsMgr *)mgr downloadedDict:(NSString *)dn;
- (void)DictsMgr:(DictsMgr *)mgr cancelled:(BOOL) cancel;

@end