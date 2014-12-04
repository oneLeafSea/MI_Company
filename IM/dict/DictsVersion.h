//
//  DictVersions.h
//  WH
//
//  Created by 郭志伟 on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSDictionary DVData;

@interface DictsVersion : NSObject

- (instancetype) initWithDvData:(NSDictionary *)dvd;

- (NSArray *)allDictNames;

@property(readonly) DVData *data;

@end
