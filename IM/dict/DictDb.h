//
//  DictDb.h
//  WH
//
//  Created by 郭志伟 on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dict.h"
#import "DictsVersion.h"

/**
 * dictory database.
 **/

@interface DictDb : NSObject

/**
 * dictDb init.
 **/
- (instancetype) initWithDirectory:(NSString *)dir;

/**
 * close database.
 **/
- (void) close;

/**
 * get dict from database.
 **/

- (Dict *) getDictByName:(NSString *)dictName;

/**
 * remove dict by given dictName.
 **/

- (BOOL) rmDict:(NSString *)dictName;


- (BOOL) importDictWithName:(NSString *) dictName version:(NSString *)version data:(NSData *) data;



@property(readonly) DictsVersion *dictsVer;
@end
