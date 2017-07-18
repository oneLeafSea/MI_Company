//
//  RTMessagesCollectionViewFlowLayoutInvalidationContext.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesCollectionViewFlowLayoutInvalidationContext.h"

@implementation RTMessagesCollectionViewFlowLayoutInvalidationContext

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.invalidateFlowLayoutDelegateMetrics = NO;
        self.invalidateFlowLayoutAttributes = NO;
        _invalidateFlowLayoutMessagesCache = NO;
    }
    return self;
}

+ (instancetype)context
{
    RTMessagesCollectionViewFlowLayoutInvalidationContext *context = [[RTMessagesCollectionViewFlowLayoutInvalidationContext alloc] init];
    context.invalidateFlowLayoutDelegateMetrics = YES;
    context.invalidateFlowLayoutAttributes = YES;
    return context;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: invalidateFlowLayoutDelegateMetrics=%@, invalidateFlowLayoutAttributes=%@, invalidateDataSourceCounts=%@, invalidateFlowLayoutMessagesCache=%@>",
            [self class], @(self.invalidateFlowLayoutDelegateMetrics), @(self.invalidateFlowLayoutAttributes), @(self.invalidateDataSourceCounts), @(self.invalidateFlowLayoutMessagesCache)];
}

@end
