//
//  ChatMessageMorePanelPageCollectionViewController.h
//  IM
//
//  Created by 郭志伟 on 15-2-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMessageMorePanelPageCollectionViewController : UICollectionViewController

+ (NSUInteger)getPanelItemCount;

- (instancetype)initWithPanelItems:(NSArray *) panelItems;

@end
