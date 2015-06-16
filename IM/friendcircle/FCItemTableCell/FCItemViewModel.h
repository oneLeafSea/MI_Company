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

@property(nonatomic, strong) NSString *avatarImg;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *org;
@property(nonatomic, strong) NSString *time;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) NSString *position;


@property(nonatomic, strong) FCItemCommentsViewModel *commentsViewModel;
@property(nonatomic, strong) FCItemImagesViewModel *imgViewModel;

@end
