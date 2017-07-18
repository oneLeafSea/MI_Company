//
//  RosterGroup.h
//  IM
//
//  Created by 郭志伟 on 14-12-25.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RosterGroup : NSObject

@property(copy) NSString       *gid;
@property NSMutableArray       *items;
@property(copy) NSString       *name;
@property       BOOL           defaultGrp;
@property   NSInteger          weight;

@end
