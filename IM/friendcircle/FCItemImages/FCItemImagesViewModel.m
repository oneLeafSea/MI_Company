//
//  FCItemImagesViewModel.m
//  IM
//
//  Created by 郭志伟 on 15/6/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCItemImagesViewModel.h"
#import "NSString+URL.h"

@interface FCItemImagesViewModel()

@property(copy, nonatomic) NSString *postId;
@property(copy, nonatomic) NSString *servrUrl;
@property(assign) NSInteger imgNum;
@property(copy, nonatomic) NSString *thumbServrUrl;

@end


@implementation FCItemImagesViewModel

- (instancetype)initWithPostId:(NSString *)postId
                     serverUrl:(NSString *)serverUrl
                thumbServerUrl:(NSString *)thumbServerUrl
                        imgNum:(NSInteger)imgNum {
    if (self = [super init]) {
        self.postId = postId;
        self.servrUrl = serverUrl;
        self.imgNum = imgNum;
        self.thumbServrUrl = thumbServerUrl;
    }
    return self;
}

- (NSArray *)collectionCellModels {
    
    if (self.imgNum == 0) {
        return nil;
    }
    NSMutableArray *cellModels = [[NSMutableArray alloc] initWithCapacity:self.imgNum];
    for (NSInteger n = 0; n < self.imgNum; n++) {
        FCIImagesitemCollectionViewCellModel *cvcm = [[FCIImagesitemCollectionViewCellModel alloc] init];
        NSString *fileName = [NSString stringWithFormat:@"%@%d.jpg",self.postId, n+1];
        cvcm.imgThumbUrl = [[NSURL alloc] initWithString:[self.thumbServrUrl stringByAppendingPathComponent:[fileName URLEncodedString]]];
        cvcm.imgurl = [[NSURL alloc] initWithString:[self.servrUrl stringByAppendingPathComponent:[fileName URLEncodedString]]];
        [cellModels addObject:cvcm];
    }
    return cellModels;
}

- (BOOL)hasImages {
    if (self.collectionCellModels.count == 0) {
        return NO;
    }
    return YES;
}

@end
