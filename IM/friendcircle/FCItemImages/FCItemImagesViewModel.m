//
//  FCItemImagesViewModel.m
//  IM
//
//  Created by 郭志伟 on 15/6/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCItemImagesViewModel.h"


@implementation FCItemImagesViewModel

- (BOOL)hasImages {
    if (self.collectionCellModels.count == 0) {
        return NO;
    }
    return YES;
}

@end
