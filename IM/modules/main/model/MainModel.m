//
//  MainModel.m
//  dongrun_beijing
//
//  Created by guozw on 14/11/6.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "MainModel.h"

@interface MainModel() {
    __weak ModuleRoot *m_root;
    __weak Module     *m_currentDir;
}

@end

@implementation MainModel

- (instancetype)initWithModuleRoot:(ModuleRoot *)root {
    if (self = [super init]) {
        m_root = root;
        m_currentDir = root;
        _hideBackbtn = YES;
        _mainData = [self genMainData];
    }
    return self;
}

- (void)didSelectedAtIndex:(NSUInteger )idx {
    Module *cm = nil;
    switch (m_currentDir.type) {
        case ModuleTypeDirectory:
        {
            ModuleDirectory *md = (ModuleDirectory *)m_currentDir;
            cm = [md.subModules objectAtIndex:idx];
            _hideBackbtn = NO;
            
        }
            break;
        case ModuleTypeRoot:
        {
            ModuleRoot *mr = (ModuleRoot *)m_currentDir;
            cm = [mr.subModules objectAtIndex:idx];
            _hideBackbtn = NO;
        }
            break;
        default:
            break;
    }
    
    if (cm.type == ModuleTypeDirectory) {
        m_currentDir = cm;
        _mainData = [self genMainData];
        [self.delegate MainModel:self didSelectedDirModule:m_currentDir];
    }
    if (cm.type == ModuleTypeDefault) {
        [self.delegate MainModel:self didSelectedDefaultModule:(ModuleDefault *)cm];
    }
    
    if (cm.type == ModuleTypeQuery) {
        [self.delegate MainModel:self didSelectedQueryModule:(ModuleQuery*)cm];
    }
    
}

- (void)back {
    Module *parent = m_currentDir.parent;
    if (parent == nil) {
        return;
    }
    
    if ([parent isEqual:m_root]) {
        _hideBackbtn = YES;
    }
    m_currentDir = parent;
    _mainData = [self genMainData];
    [self.delegate MainModel:self backToModule:m_currentDir];
    
}

-(NSArray *)genMainData {
    
    if (m_currentDir.type == ModuleTypeDirectory) {
            ModuleDirectory *md = (ModuleDirectory *)m_currentDir;
        if (md.subModules.count == 0) {
            return nil;
        }
        NSMutableArray *mutableArr = [[NSMutableArray alloc] init];
        [md.subModules enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Module *module = obj;
            MainItemData *itemData = [[MainItemData alloc] initWithName:module.name imageName:module.imageName];
            [mutableArr addObject:itemData];
        }];
        return mutableArr;
    }
    
    if (m_currentDir.type == ModuleTypeRoot) {
        ModuleRoot *mr = (ModuleRoot *)m_currentDir;
        if (mr.subModules.count == 0) {
            return nil;
        }
        NSMutableArray *mutableArr = [[NSMutableArray alloc] init];
        [mr.subModules enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Module *module = obj;
            MainItemData *itemData = [[MainItemData alloc] initWithName:module.name imageName:module.imageName];
            [mutableArr addObject:itemData];
        }];
        return mutableArr;
    }
    return nil;
}


@end
