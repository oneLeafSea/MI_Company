//
//  RowSelectorPickerViewInline.m
//  testGData
//
//  Created by guozw on 14-11-5.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "RowSelectorPickerViewInline.h"
#import "ModuleConstants.h"

@implementation RowSelectorPickerViewInline

- (instancetype) initWithXmlElement:(GDataXMLElement *)e {
    if (self = [super initWithXmlElement:e]) {
        if (![self setup:e]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup:(GDataXMLElement *)e {
    self.plistName = [[e attributeForName:kRowAttrPlist] stringValue];
    if (self.plistName.length == 0) {
        NSLog(@"row RowSelectorPickerViewInline must have a plist attribute!");
        return NO;
    }
    return YES;
}

@end
