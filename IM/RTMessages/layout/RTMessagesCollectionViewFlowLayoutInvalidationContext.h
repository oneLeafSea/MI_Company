//
//  RTMessagesCollectionViewFlowLayoutInvalidationContext.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTMessagesCollectionViewFlowLayoutInvalidationContext : UICollectionViewFlowLayoutInvalidationContext

@property (nonatomic, assign) BOOL invalidateFlowLayoutMessagesCache;

+ (instancetype)context;

@end
