//
//  Pages.m
//  testGData
//
//  Created by 郭志伟 on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Pages.h"
#import "ModuleConstants.h"
#import "NSString+CheckNumeric.h"

@implementation Pages

- (instancetype)initWithXmlElement:(GDataXMLElement *)e {
    if (self = [super init]) {
        if (![self parse:e]) {
            self = nil;
        }
    }
    return self;
}


- (BOOL)parse:(GDataXMLElement *)e {
    NSString *infiniteSwipe = [[e attributeForName:kInfiniteSwipe] stringValue];
    if ([infiniteSwipe isEqualToString:kNO]) {
        self.infiniteSwipe = NO;
    } else {
        self.infiniteSwipe = YES;
    }
    
    NSString *swipeEnabled = [[e attributeForName:kSwipeEnabled] stringValue];
    if ([swipeEnabled isEqualToString:kNO]) {
        self.swipeEnabled = NO;
    } else {
        self.swipeEnabled = YES;
    }
    
    NSString *selectedIndex = [[e attributeForName:kSelectedIndex] stringValue];
    
    if ([selectedIndex isNumeric]) {
        self.selectedIndex = [selectedIndex integerValue];
    } else {
        self.selectedIndex = 0;
    }
    
    NSError *err = nil;
    BOOL    ret  = YES;
    NSArray *pageArr = [e nodesForXPath:@"./page" error:&err];
    if (err) {
        NSLog(@"parse page tag err: %@", err);
        ret = NO;
        return ret;
    }
    
    if (pageArr.count == 0) {
        NSLog(@"page tag must more than one");
        
    }
    
    NSMutableArray *pages = [[NSMutableArray alloc] init];
    for (GDataXMLElement *page in pageArr) {
        Page *p = [[Page alloc] initWithXmlElement:page];
        if (!p) {
            ret = NO;
            break;
        }
        [pages addObject:p];
    }
    if (ret) {
        _pageArray = pages;
    }
    
    return ret;
}

@end
