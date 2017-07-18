//
//  FCModel.m
//  IM
//
//  Created by 郭志伟 on 15/6/18.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCModel.h"

@interface FCModel() {
    NSMutableArray *_itemModels;
}
@end

@implementation FCModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        if (![self parseDict:dict]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)parseDict:(NSDictionary *)dict {
    _itemModels = [[NSMutableArray alloc] initWithCapacity:10];
    [self addMsgsFromDict:dict];
    [self addRepliesFromDict:dict];
    return YES;
}

- (NSArray *)itemModels {
    return _itemModels;
}

- (void)appendComments:(NSDictionary *)reply {
    NSString *postId = [reply objectForKey:@"ssid"];
    [_itemModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FCItemTableViewCellModel *cellModel = obj;
        if ([cellModel.itemViewModel.modelId isEqualToString:postId]) {
            [cellModel.itemViewModel addCommentViewModel:reply];
        }
    }];
}

- (void)addMsgsFromDict:(NSDictionary *)dict {
    NSArray *msgs = [dict objectForKey:@"msgs"];
    [msgs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *item = obj;
        FCItemTableViewCellModel *cellModel = [[FCItemTableViewCellModel alloc] initWithDict:item];
        if (cellModel) {
            [_itemModels addObject:cellModel];
        }
    }];
}

- (FCItemTableViewCellModel *)getItemModelByModelId:(NSString *)modelId {
    __block FCItemTableViewCellModel *cm = nil;
    [_itemModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FCItemTableViewCellModel *item = obj;
        if ([item.itemViewModel.modelId isEqualToString:modelId]) {
            cm = item;
            *stop = YES;
        }
    }];
    return cm;
}

- (void)addRepliesFromDict:(NSDictionary *)dict {
    NSArray *replies = [dict objectForKey:@"replys"];
    [replies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = obj;
        [self appendComments:dict];
    }];
}

- (void)appendItemsWithDict:(NSDictionary *)dict {
    [self addMsgsFromDict:dict];
    [self addRepliesFromDict:dict];
}

@end
