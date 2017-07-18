//
//  FCItemViewModel.h
//  IM
//
//  Created by 郭志伟 on 15/6/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FCItemImagesViewModel.h"
#import "FCItemCommentsViewModel.h"

@interface FCItemViewModel : NSObject

@property(nonatomic, copy) NSString *avatarImg;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *org;
@property(nonatomic, copy) NSString *time;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, copy) NSString *position;
@property(nonatomic, copy) NSString *uid;
@property(nonatomic, copy) NSString *imgNum;
@property(nonatomic, copy) NSString *modelId;
@property(nonatomic, copy) NSString *lon;
@property(nonatomic, copy) NSString *lat;


@property(nonatomic, strong) FCItemCommentsViewModel *commentsViewModel;
@property(nonatomic, strong) FCItemImagesViewModel *imgViewModel;

- (void)addCommentViewModel:(NSDictionary *)dict;

@end
