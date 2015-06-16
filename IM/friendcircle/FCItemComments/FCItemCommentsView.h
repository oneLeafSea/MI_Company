//
//  FCItemCommentsView.h
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCItemCommentsViewModel.h"

@interface FCItemCommentsView : UIView

@property(nonatomic, strong) FCItemCommentsViewModel *model;

+ (CGFloat)heightForCommentsView:(FCItemCommentsViewModel *)model;

@end
