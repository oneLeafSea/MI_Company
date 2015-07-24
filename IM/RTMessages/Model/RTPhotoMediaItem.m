//
//  RTPhotoMediaItem.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTPhotoMediaItem.h"

#import "RTMessagesMediaPlaceholderView.h"
#import "RTMessagesMediaViewBubbleImageMasker.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+common.h"
#import "RTPhotoView.h"

@interface RTPhotoMediaItem ()

@property (nonatomic, strong) RTPhotoView *photoView;

@end


@implementation RTPhotoMediaItem

#pragma mark - Initialization


- (void)dealloc
{
    _photoView = nil;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _photoView = nil;
}

#pragma mark - Setters

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _photoView = nil;
}



#pragma mark - RTMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.status == RTPhotoMediaItemStatusSending) {
        return nil;
    }
    if (self.photoView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        CGRect frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        RTPhotoView *photoView = [[RTPhotoView alloc] initWithFrame:frame];
        photoView.imgUrl = self.thumbUrl;
        photoView.contentMode = UIViewContentModeScaleAspectFill;
        photoView.clipsToBounds = YES;
        photoView.userInteractionEnabled = YES;
        [RTMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:photoView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.photoView = photoView;
    }
    
    return self.photoView;
}

- (CGSize)mediaViewDisplaySize
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return CGSizeMake(315.0f, 225.0f);
    }
    
    return CGSizeMake(100.0f, 100.0f);
}

- (NSUInteger)mediaHash
{
    return self.hash;
}


#pragma mark - NSObject

- (NSUInteger)hash
{
    return super.hash ^ self.orgUrl.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: image=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.orgUrl, @(self.appliesMediaViewMaskAsOutgoing)];
}

@end
