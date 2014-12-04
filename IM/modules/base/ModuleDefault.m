//
//  ModuleDefault.m
//  testGData
//
//  Created by guozw on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "ModuleDefault.h"
#import "ModuleConstants.h"

@interface ModuleDefault() {
    NSString *m_id;
    NSString *m_name;
}
@end

@implementation ModuleDefault

- (instancetype)initWithXmlElement:(GDataXMLElement *)e parent:(Module *)parent {
    
    if (self = [super init]) {
        m_parent = parent;
        if (![self parse:e]) {
            self = nil;
        }
    }
    return self;
    
}

- (NSString *)ID {
    return m_id;
}

- (ModuleType)type {
    return ModuleTypeDefault;
}

- (NSString *)name {
    return m_name;
}


- (BOOL)parse:(GDataXMLElement *)e{
    BOOL ret = YES;
    m_id = [[[e attributeForName:kModuleId] stringValue] copy];
    if (m_id.length == 0) {
        NSLog(@"err int parse ModuleDefault id is null");
        ret = NO;
        return ret;
    }
    m_name = [[[e attributeForName:kModuleName] stringValue] copy];
    self.imageName = [[e attributeForName:kModuleImage] stringValue];
    self.hide = [[[[e attributeForName:kModuleHide] stringValue] lowercaseString]isEqualToString:kYES];
    
    NSError *err = nil;
    NSArray *pages = [e nodesForXPath:@"./pages" error:&err];
    if (pages.count != 1) {
        NSLog(@"a module must have onlye pages! ");
        ret = NO;
        return ret;
    }
    
    _pages = [[Pages alloc] initWithXmlElement:[pages objectAtIndex:0]];
    if (!_pages) {
        ret = NO;
        return ret;
    }
    
    return ret;

}

@end
