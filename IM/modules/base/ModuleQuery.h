//
//  ModuleQuery.h
//  testGData
//
//  Created by guozw on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Module.h"
#import "GDataXMLNode.h"

@interface ModuleQuery : Module

- (instancetype)initWithXmlElement:(GDataXMLElement *)e  parent:(Module *)parent;

@end
