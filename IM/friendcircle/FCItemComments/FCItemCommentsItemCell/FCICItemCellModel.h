//
//  FCICItemCellModel.h
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCICItemCellModel : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *uid;
@property(nonatomic, strong) NSString *repliedName;
@property(nonatomic, strong) NSString *repliedUid;

@property(nonatomic, strong) NSString *content;

@property(nonatomic, readonly) BOOL replied;

@end
