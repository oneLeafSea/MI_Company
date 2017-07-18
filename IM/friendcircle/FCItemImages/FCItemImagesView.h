//
//  FCItemImagesView.h
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCItemImagesViewModel.h"

@interface FCItemImagesView : UIView

@property(nonatomic, strong) FCItemImagesViewModel *model;

+ (CGFloat) heightForImagesHeight:(FCItemImagesViewModel *)model;
@property(nonatomic, weak) UIViewController   *curVC;

@end
