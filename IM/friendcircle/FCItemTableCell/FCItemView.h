//
//  FCItemView.h
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCItemViewModel.h"

@interface FCItemView : UIView

@property(nonatomic, strong) FCItemViewModel *model;

+ (CGFloat)heightForViewModel:(FCItemViewModel *)itemViewModel;

@end
