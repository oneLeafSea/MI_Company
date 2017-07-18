//
//  RTMorePanelView.h
//  IM
//
//  Created by 郭志伟 on 15/7/15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTMorePanelView : UIView

- (void)registerItemWithTitle:(NSString *)title
                       image:(UIImage *)image
                      target:(id)target
                      action:(SEL)selector;


@end
