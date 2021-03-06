//
//  FCItemImagesViewModel.h
//  IM
//
//  Created by 郭志伟 on 15/6/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCIImagesitemCollectionViewCellModel.h"

@interface FCItemImagesViewModel : NSObject

- (instancetype)initWithPostId:(NSString *)postId
                     serverUrl:(NSString *)serverUrl
                thumbServerUrl:(NSString *)thumbServerUrl
                        imgNum:(NSInteger)imgNum;

@property(nonatomic, strong) NSArray *collectionCellModels;

@property(nonatomic, readonly) BOOL hasImages;

@end
