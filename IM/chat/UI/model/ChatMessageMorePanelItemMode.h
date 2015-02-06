//
//  ChatMessageMorePanelItemMode.h
//  IM
//
//  Created by 郭志伟 on 15-2-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatMessageMorePanelItemMode : NSObject

- (instancetype) initWithTitle:(NSString *)title imageName:(NSString *)imageName target:(id)target selector:(SEL)selector;


@property (nonatomic, assign, readonly) SEL selector;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *imageName;

@property (weak, readonly) id target;

@end
