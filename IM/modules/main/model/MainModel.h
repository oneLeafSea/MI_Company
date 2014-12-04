//
//  MainModel.h
//  dongrun_beijing
//
//  Created by guozw on 14/11/6.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Module.h"
#import "ModuleRoot.h"
#import "ModuleDefault.h"
#import "ModuleQuery.h"
#import "ModuleDirectory.h"
#import "MainItemData.h"

@protocol MainModelDelegate;

@interface MainModel : NSObject

- (instancetype)initWithModuleRoot:(ModuleRoot *)root;

- (void)didSelectedAtIndex:(NSUInteger )idx;
- (void)back;


@property(readonly)NSArray *mainData;
@property(readonly)Module  *currentModule;
@property(readonly)BOOL    hideBackbtn;

@property(weak) id<MainModelDelegate> delegate;

@end


@protocol MainModelDelegate <NSObject>

@required
- (void)MainModel:(MainModel *)mainModel didSelectedDirModule:(Module *)module;
- (void)MainModel:(MainModel *)mainModel didSelectedDefaultModule:(ModuleDefault *)module;
- (void)MainModel:(MainModel *)mainModel didSelectedQueryModule:(ModuleQuery *)module;
- (void)MainModel:(MainModel *)mainModel backToModule:(Module *)module;

@end