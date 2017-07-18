//
//  AvatarContainerView.h
//  IM
//
//  Created by 郭志伟 on 15/5/6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AvatarContainerViewItem.h"

@interface AvatarContainerView : UIView

+ (instancetype)instanceFromNib;

@property(nonatomic, strong)NSArray *items;

- (void)removeAvatarItemByUid:(NSString *)uid;
- (void)addAvatarItem:(AvatarContainerViewItem *)item;
- (void)setAvatarItemUid:(NSString *)uid Ready:(BOOL)ready;
- (void)refresh;
- (BOOL)isExistItem:(AvatarContainerViewItem *)item;
- (BOOL)isExistUid:(NSString *)uid;

@end
