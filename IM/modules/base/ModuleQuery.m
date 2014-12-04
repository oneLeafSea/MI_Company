//
//  ModuleQuery.m
//  testGData
//
//  Created by guozw on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "ModuleQuery.h"
#import "ModuleConstants.h"

@interface ModuleQuery() {
    NSString *m_id;
    NSString *m_name;
}
@end


@implementation ModuleQuery

- (instancetype)initWithXmlElement:(GDataXMLElement *)e parent:(Module *)parent {
    
    if (self = [super init]) {
        m_parent = parent;
        if (![self parse:e]) {
            self = nil;
        }
    }
    return nil;
}

- (NSString *)ID {
    return m_id;
}

- (ModuleType)type {
    return ModuleTypeQuery;
}

- (NSString *)name {
    return m_name;
}

- (BOOL)parse:(GDataXMLElement *)e {
    
    BOOL ret = YES;
    m_id = [[[e attributeForName:kModuleId] stringValue] copy];
    if (m_id.length == 0) {
        NSLog(@"err int parse ModuleQuery id is null");
        ret = NO;
        return ret;
    }
    m_name = [[[e attributeForName:kModuleName] stringValue] copy];
    self.imageName = [[e attributeForName:kModuleImage] stringValue];
    self.hide = [[[[e attributeForName:kModuleHide] stringValue] lowercaseString]isEqualToString:kYES];
    return ret;
}

@end
