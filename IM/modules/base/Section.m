//
//  Section.m
//  testGData
//
//  Created by 郭志伟 on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Section.h"
#import "ModuleConstants.h"
#import "RowFactory.h"

@implementation Section

- (instancetype)initWithXmlElement:(GDataXMLElement *)e {
    if (self = [super init]) {
        if (![self parse:e]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)parse:(GDataXMLElement *)e {
    _title = [[e attributeForName:kTitle] stringValue];
    
    if (_title.length == 0) {
        _title = nil;
    }
    
    BOOL ret = YES;
    NSError *err = nil;
    NSArray *eRows = [e nodesForXPath:@"./row" error:&err];
    
    if (err) {
        NSLog(@"err in parse section: %@", err);
        ret = NO;
        return ret;
    }
    
    if (eRows.count == 0) {
        NSLog(@"section must have more than a row.");
        ret = NO;
        return ret;
    }
    
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    for (GDataXMLElement *eRow in eRows) {
        NSError *err = nil;
        Row *row = [RowFactory produceRow:eRow error:&err];
        if (err || !row) {
            NSLog(@"err in build row :%@", err);
            ret = NO;
            break;
        }
        [rows addObject:row];
    }
    
    if (ret) {
        _rows = rows;
    }
    return ret;
}



@end
