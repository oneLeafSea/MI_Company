//
//  Row.m
//  testGData
//
//  Created by 郭志伟 on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Row.h"
#import "ModuleConstants.h"

@implementation Row

- (instancetype)initWithXmlElement:(GDataXMLElement *)e {
    if (self = [super init]) {
        if (![self parse:e]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)parse:(GDataXMLElement *)e {
    NSString *disable = [[e attributeForName:kRowAttrDisable] stringValue];
    if ([disable isEqualToString:kYES]) {
        self.disable = YES;
    } else {
        self.disable = NO;
    }
    
    self.title = [[e attributeForName:kRowAttrTitle] stringValue];
    
    NSString *tag = [[e attributeForName:kRowAttrTag] stringValue];
    if (tag.length == 0) {
        NSLog(@"Row must have a tag");
        return NO;
    }
    m_tag = tag;
    
    NSString *type = [[e attributeForName:kRowAttrType] stringValue];
    if (type.length == 0) {
        NSLog(@"Row must have a type");
        return NO;
    }
    m_type = type;
    
    self.defaultValue = [[e attributeForName:kRowAttrDefaultValue] stringValue];
    
    return YES;
}

- (NSString *)tag {
    return m_tag;
}

- (NSString *)type {
    return m_type;
}

@end
