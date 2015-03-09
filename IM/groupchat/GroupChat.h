//
//  GroupChat.h
//  IM
//
//  Created by 郭志伟 on 15-3-2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt32, GropuChatype) {
    GropuChatypePrivate = 1,
    GropuChatypePublic  = 2
};

@interface GroupChat : NSObject

- (instancetype)initWithGid:(NSString *)gid
                      gname:(NSString *)gname
                  creatorId:(NSString *)creatorId
                creatorName:(NSString *)creatorName
                       type:(GropuChatype)type
                       exit:(BOOL)exit;


- (BOOL)parseItems:(NSArray *)result;

@property(nonatomic, strong) NSString *gid;
@property(nonatomic, strong) NSString *gname;
@property(nonatomic, strong) NSString *creatorId;
@property(nonatomic, strong) NSString *creatorName;
@property(nonatomic, strong) NSString *createTime;
@property(nonatomic)         GropuChatype type;
@property(nonatomic)         BOOL     exit;

@property(nonatomic)        NSArray  *items;


@end
