//
//  RosterGroupContainer.h
//  IM
//
//  Created by 郭志伟 on 14-12-25.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RosterGroupContainer : NSObject

- (instancetype) initWithItems:(NSArray *)items
                           grps:(NSArray *)grps
                          desc:(NSDictionary *)desc;


@property(readonly) NSDictionary *groups;
@end
