//
//  Page.m
//  testGData
//
//  Created by 郭志伟 on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Page.h"
#import "ModuleConstants.h"

@interface Page() {
    
}

@end

@implementation Page

- (instancetype)initWithXmlElement:(GDataXMLElement *)e {
    if (self = [super init]) {
        if (![self parse:e]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)parse:(GDataXMLElement *)e {
    
    BOOL ret = YES;
    _title = [[e attributeForName:kTitle] stringValue];
    
    if (_title.length == 0) {
        ret = NO;
        NSLog(@"page must have a title.");
        return ret;
    }
    
    NSError *err = nil;
    NSArray *eSects = [e nodesForXPath:@"./section" error:&err];
    
    if (eSects.count == 0) {
        NSLog(@"page must have more than one section!");
        ret = NO;
        return ret;
    }
    
    NSMutableArray *sections = [[NSMutableArray alloc]init];
    for (GDataXMLElement *eSect in eSects) {
        Section *s = [[Section alloc] initWithXmlElement:eSect];
        if (!s) {
            ret = NO;
            break;
        }
        [sections addObject:s];
    }
    
    if (ret) {
        _sections = sections;
    }
    
    return ret;
}

//- (BOOL)parseRowsWithXmlElement:(GDataXMLElement *)e section:(Section *)s {
//    
//    return YES;
//}



@end
