//
//  RowDecimal.m
//  testGData
//
//  Created by guozw on 14-11-5.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "RowDecimal.h"
#import "ModuleConstants.h"

@implementation RowDecimal

- (instancetype) initWithTag:(NSString *)tag title:(NSString *)title placeholder:(NSString *)placehoulder {
    if (self = [super init]) {
        m_tag = [tag copy];
        self.title = [title copy];
        self.placeholder = placehoulder;
    }
    return self;
}


- (instancetype) initWithXmlElement:(GDataXMLElement *)e {
    if (self = [super initWithXmlElement:e]) {
        if (![self setup:e]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup:(GDataXMLElement *)e {
    self.placeholder = [[e attributeForName:kRowAttrPlaceholder] stringValue];
    self.defaultValue = [[e attributeForName:kRowAttrDefaultValue] stringValue];
    return YES;
}


@end
