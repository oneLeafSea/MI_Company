//
//  OsItemsVerTb.h
//  IM
//
//  Created by 郭志伟 on 15-3-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface OsItemsVerTb : NSObject

- (instancetype)initWithDbq:(FMDatabaseQueue *)dbq;


- (NSString *)DbVer;

- (BOOL)updateVer:(NSString *)ver;

@end
