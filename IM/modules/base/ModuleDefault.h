//
//  ModuleDefault.h
//  testGData
//
//  Created by guozw on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Module.h"
#import "GDataXMLNode.h"
#import "Pages.h"

@interface ModuleDefault : Module

- (instancetype)initWithXmlElement:(GDataXMLElement *)e parent:(Module *)parent;

@property(readonly) Pages *pages;

@end
