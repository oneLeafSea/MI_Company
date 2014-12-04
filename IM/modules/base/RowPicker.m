//
//  RowPicker.m
//  testGData
//
//  Created by guozw on 14-11-5.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "RowPicker.h"
#import "ModuleConstants.h"

@implementation RowPicker

- (instancetype) initWithXmlElement:(GDataXMLElement *)e {
    if (self = [super initWithXmlElement:e]) {
        if (![self setup:e]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup:(GDataXMLElement *)e {
    self.plist = [[e attributeForName:kRowAttrPlist] stringValue];
    if (self.plist.length == 0) {
        NSLog(@"RowPicker must have a plist attribute");
        return NO;
    }
    return YES;
}

@end
