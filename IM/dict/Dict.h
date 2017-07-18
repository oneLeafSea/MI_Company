//
//  Dict.h
//  WH
//
//  Created by guozw on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NSArray DictData;

@interface Dict : NSObject


- (instancetype) initWithDictData:(DictData *)data
                          colname:(NSArray *)colname
                         dictName:(NSString *)name
                          version:(NSString *)version;
@property(readonly)  DictData  *data;
@property(nonatomic) NSString  *filter;
@property(readonly)  NSArray   *colname;
@property(readonly)  NSString  *name;
@property(readonly)  NSString  *version;
@end
