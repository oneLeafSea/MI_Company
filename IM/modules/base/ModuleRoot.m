//
//  ModuleRoot.m
//  testGData
//
//  Created by guozw on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "ModuleRoot.h"
#import "GDataXMLNode.h"
#import "ModuleConstants.h"
#import "ModuleDefault.h"
#import "ModuleDirectory.h"
#import "ModuleQuery.h"


static NSString *kRootID = @"ROOT_ID";
static NSString *kRootName = @"ROOT_NAME";

@interface ModuleRoot() {
    NSString *m_xmlFileName;
}
@end

@implementation ModuleRoot

- (instancetype) initWithXmlFileName:(NSString *)xmlFileName {
    if (self = [super init]) {
        m_xmlFileName = [xmlFileName copy];
        _subModules = [[NSMutableArray alloc]init];
        if (![self parse]) {
            self = nil;
        }
    }
    return self;
}


- (NSString *)ID {
    return kRootID;
}

- (ModuleType)type {
    return ModuleTypeRoot;
}

- (NSString *)name {
    return kRootName;
}


- (BOOL)parse {
    NSString *type = [m_xmlFileName pathExtension];
    NSString *xmlName = [m_xmlFileName stringByDeletingPathExtension];
    if (type.length == 0 || xmlName == 0) {
        return NO;
    }
    
    NSString *xmlPath = [[NSBundle mainBundle] pathForResource:xmlName ofType:type];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:xmlPath];
    
    NSError *err = nil;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&err];
    if (err) {
        NSLog(@"err in load parse %@", err);
        return NO;
    }
    
    NSArray *modules = [doc nodesForXPath:@"/app/modules/module" error:&err];
    if (err) {
        NSLog(@"err in get modules %@", err);
    }
    
    if (modules.count == 0) {
        NSLog(@"the modules tag is empty!");
        return NO;
    }
    
    BOOL ret = YES;
    for (GDataXMLElement *e in modules) {
        NSString *type = [[e attributeForName:kModuleType] stringValue];
        if ([type isEqualToString:kModuleAttributeTypeDirectory]) {
            ModuleDirectory *dirModule = [[ModuleDirectory alloc] initWithXmlElement:e parent:self];
            if (!dirModule) {
                ret = NO;
                break;
            }
            if (!dirModule.hide) {
                [self.subModules addObject:dirModule];
            }
        } else if ([type isEqualToString:kModuleAttributeTypeQuery]){
            ModuleQuery *queryModule = [[ModuleQuery alloc] initWithXmlElement:e parent:self];
            if (!queryModule) {
                ret = NO;
                break;
            }
            if (!queryModule.hide) {
                [self.subModules addObject:queryModule];
            }
        } else if ([type isEqualToString:kModuleAttributeTypeDefault]){
            ModuleDefault *md = [[ModuleDefault alloc]initWithXmlElement:e parent:self];
            if (!md) {
                ret = NO;
                break;
            }
            if (!md.hide) {
                [self.subModules addObject:md];
            }
        } else {
            ret = NO;
            NSLog(@"unkown module type: %@!", type);
            break;
        }
    }
    
    return ret;
}


@end
