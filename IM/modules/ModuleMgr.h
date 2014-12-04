//
//  ModuleMgr.h
//  dongrun_beijing
//
//  Created by guozw on 14-11-5.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModuleRoot.h"
#import "Module.h"

@interface ModuleMgr : NSObject

- (Module *)currentModule;

@property(readonly) ModuleRoot *root;
@property(readonly) Module     *currentModule;
@end
