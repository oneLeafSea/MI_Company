//
//  AvatarContainerViewItem.h
//  IM
//
//  Created by 郭志伟 on 15/5/6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AvatarContainerViewItem : NSObject

- (instancetype)initWithUid:(NSString *)uid
                       name:(NSString *)name
                  imgStrUrl:(NSString *)imgStrUrl;

@property(nonatomic, copy)NSString *uid;
@property(nonatomic, copy)NSString *name;
@property(nonatomic, strong) NSString *imgStrUrl;
@property(nonatomic)      BOOL ready;

@end
