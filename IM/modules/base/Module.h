//
//  Module.h
//  testGData
//
//  Created by guozw on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ModuleType) {
    ModuleTypeDirectory         = 0,
    ModuleTypeQuery             = 1,
    ModuleTypeDefault           = 2,
    ModuleTypeRoot              = 3
};

@interface Module : NSObject {
@protected
    Module      *m_parent;
}

@property(nonatomic, readonly) NSString            *ID;
@property(nonatomic, readonly) NSString            *name;
@property(nonatomic)           NSString            *imageName;
@property(readonly)            ModuleType           type;
@property                      BOOL                 hide;
@property(readonly)            Module              *parent;

@end
