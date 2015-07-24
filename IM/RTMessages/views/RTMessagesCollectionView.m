//
//  RTMessagesCollectionView.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesCollectionView.h"

#import "RTMessagesCollectionViewFlowLayout.h"
#import "RTMessagesCollectionViewCellIncoming.h"
#import "RTMessagesCollectionViewCellOutgoing.h"

#import "RTMessagesTypingIndicatorFooterView.h"
#import "RTMessagesLoadEarlierHeaderView.h"

#import "UIColor+RTMessages.h"

@interface RTMessagesCollectionView()

- (void)rt_configureCollectionView;

@property(nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation RTMessagesCollectionView

@dynamic dataSource;
@dynamic delegate;
@dynamic collectionViewLayout;

- (void)rt_configureCollectionView {
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.backgroundColor = [UIColor whiteColor];
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    self.bounces = YES;
    self.alwaysBounceVertical = YES;
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewDidTapped)];
    [self addGestureRecognizer:self.tap];
    
    [self registerNib:[RTMessagesCollectionViewCellIncoming nib] forCellWithReuseIdentifier:[RTMessagesCollectionViewCellIncoming cellReuseIdentifier]];
    
    [self registerNib:[RTMessagesCollectionViewCellOutgoing nib] forCellWithReuseIdentifier:[RTMessagesCollectionViewCellOutgoing cellReuseIdentifier]];
    [self registerNib:[RTMessagesCollectionViewCellIncoming nib] forCellWithReuseIdentifier:[RTMessagesCollectionViewCellIncoming mediaCellReuseIdentifier]];
    [self registerNib:[RTMessagesCollectionViewCellOutgoing nib] forCellWithReuseIdentifier:[RTMessagesCollectionViewCellOutgoing mediaCellReuseIdentifier]];
    
    [self registerNib:[RTMessagesTypingIndicatorFooterView nib] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
  withReuseIdentifier:[RTMessagesTypingIndicatorFooterView footerReuseIdentifier]];
    
    [self registerNib:[RTMessagesLoadEarlierHeaderView nib] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
  withReuseIdentifier:[RTMessagesLoadEarlierHeaderView headerReuseIdentifier]];
    
    _typingIndicatorDisplaysOnLeft = YES;
    _typingIndicatorMessageBubbleColor = [UIColor rt_messageBubbleLightGrayColor];
    _typingIndicatorEllipsisColor = [_typingIndicatorMessageBubbleColor rt_colorByDarkeningColorWithValue:0.3f];
    
    _loadEarlierMessagesHeaderTextColor = [UIColor rt_messageBubbleBlueColor];
}

- (void)dealloc {
    [self removeGestureRecognizer:self.tap];
    [self.tap removeTarget:self action:@selector(collectionViewDidTapped)];
    self.tap = nil;
}


- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self rt_configureCollectionView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self rt_configureCollectionView];
}

#pragma mark - Typing indicator

- (RTMessagesTypingIndicatorFooterView *)dequeueTypingIndicatorFooterViewForIndexPath:(NSIndexPath *)indexPath {
    RTMessagesTypingIndicatorFooterView *footerView = [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                 withReuseIdentifier:[RTMessagesTypingIndicatorFooterView footerReuseIdentifier]
                                                                                        forIndexPath:indexPath];
    
    [footerView configureWithEllipsisColor:self.typingIndicatorEllipsisColor
                        messageBubbleColor:self.typingIndicatorMessageBubbleColor
                       shouldDisplayOnLeft:self.typingIndicatorDisplaysOnLeft
                         forCollectionView:self];
    
    return footerView;
}

#pragma mark - Load earlier messages header

- (RTMessagesLoadEarlierHeaderView *)dequeueLoadEarlierMessagesViewHeaderForIndexPath:(NSIndexPath *)indexPath {
    RTMessagesLoadEarlierHeaderView *headerView = [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                             withReuseIdentifier:[RTMessagesLoadEarlierHeaderView headerReuseIdentifier]
                                                                                    forIndexPath:indexPath];
    
    return headerView;
}

#pragma mark - Messages collection view cell delegate
- (void)messagesCollectionViewCellDidTapAvatar:(RTMessagesCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    
    [self.delegate collectionView:self
            didTapAvatarImageView:cell.avatarImageView
                      atIndexPath:indexPath];
}

- (void)messagesCollectionViewCellDidTapMessageBubble:(RTMessagesCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    
    [self.delegate collectionView:self didTapMessageBubbleAtIndexPath:indexPath];
}

- (void)messagesCollectionViewCellDidTapCell:(RTMessagesCollectionViewCell *)cell atPosition:(CGPoint)position
{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    
    [self.delegate collectionView:self
            didTapCellAtIndexPath:indexPath
                    touchLocation:position];
}

- (void)messagesCollectionViewCell:(RTMessagesCollectionViewCell *)cell didPerformAction:(SEL)action withSender:(id)sender {
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    
    [self.delegate collectionView:self
                    performAction:action
               forItemAtIndexPath:indexPath
                       withSender:sender];
}

- (void)collectionViewDidTapped {
    [self.delegate collectionViewDidTapped:self];
}


@end
