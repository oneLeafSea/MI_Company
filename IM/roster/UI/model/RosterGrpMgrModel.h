//
//  RosterGrpMgrModel.h
//  IM
//
//  Created by 郭志伟 on 15-1-20.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RosterGroup.h"

@interface RosterGrpMgrModel : NSObject

- (instancetype) initWithGrpList:(NSArray *)grplist;

- (RosterGroup *) getDefaultGroup;

- (void)moveGrp:(RosterGroup *)fromGrp toGrp:(RosterGroup *)toGrp completion:(void(^)(BOOL finished))completion;

- (void)delGrpWith:(NSString *)gid completion:(void(^)(BOOL finished)) completion;

- (NSArray *)genGrp;

@property (nonatomic, strong) NSMutableArray *grpList;

@property BOOL dirty;

@end
