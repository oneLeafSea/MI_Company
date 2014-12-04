//
//  ModuleDirectory.m
//  testGData
//
//  Created by guozw on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "ModuleDirectory.h"
#import "ModuleConstants.h"
#import "ModuleQuery.h"
#import "ModuleDefault.h"
@interface ModuleDirectory() {
    NSString *m_id;
    NSString *m_name;
}
@end

@implementation ModuleDirectory

- (instancetype)initWithXmlElement:(GDataXMLElement *)e parent:(Module *)parent {
    if (self = [super init]) {
        self.subModules = [[NSMutableArray alloc] init];
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
    return ModuleTypeDirectory;
}

- (NSString *)name {
    return m_name;
}

- (BOOL)parse:(GDataXMLElement *)module {
    BOOL ret = YES;
    m_id = [[[module attributeForName:kModuleId] stringValue] copy];
    if (m_id.length == 0) {
        ret = NO;
        return ret;
    }
    m_name = [[[module attributeForName:kModuleName] stringValue] copy];
    self.imageName = [[module attributeForName:kModuleImage] stringValue];
    self.hide = [[[[module attributeForName:kModuleHide] stringValue] lowercaseString]isEqualToString:kYES];
    
    NSArray *subModules = [module nodesForXPath:@"./module" error:nil];
    if (subModules.count == 0) {
        ret = NO;
        return ret;
    }
    
    for (GDataXMLElement *e in subModules) {
        NSString *type = [[e attributeForName:kModuleType] stringValue];
        if ([type isEqualToString:kModuleAttributeTypeDirectory]) {
            ModuleDirectory *subModule = [[ModuleDirectory alloc] initWithXmlElement:e parent:self];
            if (!subModule) {
                ret = NO;
                break;
            }
            if (!subModule.hide) {
                [self.subModules addObject:subModule];
            }
        } else if ([type isEqualToString:kModuleAttributeTypeQuery]){
            ModuleQuery *mq = [[ModuleQuery alloc] initWithXmlElement:e parent:self];
            if (!mq) {
                ret = NO;
                break;
            }
            if (!mq.hide) {
                [self.subModules addObject:mq];
            }
        } else if ([type isEqualToString:kModuleAttributeTypeDefault]){
            ModuleDefault *md = [[ModuleDefault alloc] initWithXmlElement:e parent:self];
            if (!md) {
                ret = NO;
                break;
            }
            if (!md.hide) {
                [self.subModules addObject:md];
            }
        } else {
            ret = NO;
            NSLog(@"unkown module type: %@! in buildiing directory module", type);
            break;
        }
    }
    
    return ret;
}

@end
