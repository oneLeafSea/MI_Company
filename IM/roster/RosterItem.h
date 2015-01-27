//
//  RosterItem.h
//  IM
//
//  Created by 郭志伟 on 14-12-24.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RosterItem : NSObject

-(instancetype) initWithDict:(NSDictionary *)item;

@property(readonly) NSString *name;
@property(readonly) NSString *uid;
@property NSString *gid;
@property(readonly) NSString *sign;

@end
