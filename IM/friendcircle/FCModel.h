//
//  FCModel.h
//  IM
//
//  Created by 郭志伟 on 15/6/18.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCItemTableViewCellModel.h"

@interface FCModel : NSObject

- (instancetype)initWithDict:(NSDictionary *)dict;

- (void)appendItemsWithDict:(NSDictionary *)dict;

- (FCItemTableViewCellModel *)getItemModelByModelId:(NSString *)modelId;

@property(nonatomic, strong, readonly) NSArray *itemModels;

@end
