//
//  DictVersionSync.h
//  WH
//
//  Created by 郭志伟 on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DictDb.h"

@protocol DictsVersionSyncDelegate;

typedef NS_ENUM(NSUInteger, DictsVersionSyncError) {
    DictsVersionSyncErrorParam          = 1,
    DictsVersionSyncErrorBadResp        = 2
};

@interface DictsVersionSync : NSObject

- (instancetype) initWithDictDb:(DictDb *) db;

- (void)syncWithToken:(NSString *)token url:(NSString *)url org:(NSString *) org;


@property id<DictsVersionSyncDelegate> delegate;

@end


@protocol DictsVersionSyncDelegate <NSObject>

- (void)DictsVersionSync:(DictsVersionSync *)dvs start:(BOOL)suc;
- (void)DictsVersionSync:(DictsVersionSync *)dvs result:(NSArray *)result error:(NSError *)err;

@end