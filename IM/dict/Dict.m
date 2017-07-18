//
//  Dict.m
//  WH
//
//  Created by guozw on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Dict.h"

@interface Dict() {
    DictData *m_data;
   
}
@end

@implementation Dict

- (instancetype) initWithDictData:(DictData *)data
                          colname:(NSArray *)colname
                         dictName:(NSString *)name
                          version:(NSString *)version{
    if (self = [super init]) {
        m_data = data;
        _colname = colname;
        _name = name;
        _version = version;
    }
    return self;
}

- (DictData *)data {
    NSString *strFmt = [NSString stringWithFormat:@"SELF['%@'] CONTAINS '%@'", @"MC", @"外" ];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:strFmt];
    NSArray * array = [m_data filteredArrayUsingPredicate:predicate];
    return array;
}

@end