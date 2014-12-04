//
//  ModuleRoot.h
//  testGData
//
//  Created by guozw on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Module.h"

@interface ModuleRoot : Module

- (instancetype) initWithXmlFileName:(NSString *)xmlFileName;

@property(nonatomic)    NSMutableArray *subModules;

@end
