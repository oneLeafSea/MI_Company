//
//  RosterItemAddReqModel.h
//  IM
//
//  Created by 郭志伟 on 15-1-23.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RosterItemAddReqModel : NSObject

- (instancetype) initWithReqList: (NSArray *)reqList;


@property (nonatomic, readonly) NSArray *reqList;

@end
