//
//  PopMenuItemView.h
//  IM
//
//  Created by 郭志伟 on 15/5/4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PopMenuItem.h"

@interface PopMenuItemView : UITableViewCell

@property (nonatomic, strong) PopMenuItem *popMenuItem;

- (void)setupPopMenuItem:(PopMenuItem *)popMenuItem atIndexPath:(NSIndexPath *)indexPath isBottom:(BOOL)isBottom;

@end
