//
//  RTMessagesCollectionViewFlowLayout.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesCollectionViewFlowLayout.h"
#import "RTMessagesCollectionViewLayoutAttributes.h"
#import "RTMessagesCollectionViewFlowLayoutInvalidationContext.h"
#import "RTMessagesCollectionView.h"

#import "UIImage+RTMessages.h"
#import "RTMessageData.h"

const CGFloat kRTMessagesCollectionViewCellLabelHeightDefault = 20.0f;
const CGFloat kRTMessagesCollectionViewAvatarSizeDefault = 38.0f;

@interface RTMessagesCollectionViewFlowLayout()

@property (strong, nonatomic) NSCache *messageBubbleCache;
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (strong, nonatomic) NSMutableSet *visibleIndexPaths;
@property (assign, nonatomic) CGFloat latestDelta;
@property (assign, nonatomic, readonly) NSUInteger bubbleImageAssetWidth;

- (void)rt_configureFlowLayout;
- (void)rt_didReceiveApplicationMemoryWarningNotification:(NSNotification *)notification;
- (void)rt_didReceiveDeviceOrientationDidChangeNotification:(NSNotification *)notification;

- (void)rt_resetLayout;
- (void)rt_resetDynamicAnimator;

- (void)rt_configureMessageCellLayoutAttributes:(RTMessagesCollectionViewLayoutAttributes *)layoutAttributes;

- (CGSize)rt_avatarSizeForIndexPath:(NSIndexPath *)indexPath;

- (UIAttachmentBehavior *)rt_springBehaviorWithLayoutAttributesItem:(UICollectionViewLayoutAttributes *)item;

- (void)rt_addNewlyVisibleBehaviorsFromVisibleItems:(NSArray *)visibleItems;
- (void)rt_removeNoLongerVisibleBehaviorsFromVisibleItemsIndexPaths:(NSSet *)visibleItemsIndexPaths;
- (void)rt_adjustSpringBehavior:(UIAttachmentBehavior *)springBehavior forTouchLocation:(CGPoint)touchLocation;

@end

@implementation RTMessagesCollectionViewFlowLayout

@dynamic collectionView;

- (void)rt_configureFlowLayout {
    [super awakeFromNib];
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.sectionInset = UIEdgeInsetsMake(10.0f, 4.0f, 10.0f, 4.0f);
    self.minimumLineSpacing = 4.0f;
    
    _bubbleImageAssetWidth = [UIImage rt_bubbleCompactImage].size.width;
    _messageBubbleCache = [NSCache new];
    _messageBubbleCache.name = @"RTMessagesCollectionViewFlowLayout.messageBubbleCache";
    _messageBubbleCache.countLimit = 200;
    _messageBubbleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        _messageBubbleLeftRightMargin = 240.0f;
    }
    else {
        _messageBubbleLeftRightMargin = 50.0f;
    }
    
    _messageBubbleTextViewFrameInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 6.0f);
    _messageBubbleTextViewTextContainerInsets = UIEdgeInsetsMake(7.0f, 14.0f, 7.0f, 14.0f);
    CGSize defaultAvatarSize = CGSizeMake(kRTMessagesCollectionViewAvatarSizeDefault, kRTMessagesCollectionViewAvatarSizeDefault);
    _incomingAvatarViewSize = defaultAvatarSize;
    _outgoingAvatarViewSize = defaultAvatarSize;
    
    _springinessEnabled = NO;
    _springResistanceFactor = 1000;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rt_didReceiveApplicationMemoryWarningNotification:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rt_didReceiveDeviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (instancetype)init {
    if (self = [super init]) {
        [self rt_configureFlowLayout];
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self rt_configureFlowLayout];
}

+ (Class)layoutAttributesClass {
     return [RTMessagesCollectionViewLayoutAttributes class];
}

+ (Class)invalidationContextClass {
    return [RTMessagesCollectionViewFlowLayoutInvalidationContext class];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _messageBubbleFont = nil;
    
    [_messageBubbleCache removeAllObjects];
    _messageBubbleCache = nil;
    
    [_dynamicAnimator removeAllBehaviors];
    _dynamicAnimator = nil;
    
    [_visibleIndexPaths removeAllObjects];
    _visibleIndexPaths = nil;
}

#pragma mark - Setters
- (void)setSpringinessEnabled:(BOOL)springinessEnabled {
    if (_springinessEnabled == springinessEnabled) {
        return;
    }
    _springinessEnabled = springinessEnabled;
    if (!springinessEnabled) {
        [_dynamicAnimator removeAllBehaviors];
        [_visibleIndexPaths removeAllObjects];
    }
    [self invalidateLayoutWithContext:[RTMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setMessageBubbleFont:(UIFont *)messageBubbleFont {
    if ([_messageBubbleFont isEqual:messageBubbleFont]) {
        return;
    }
    
    NSParameterAssert(messageBubbleFont != nil);
    _messageBubbleFont = messageBubbleFont;
    [self invalidateLayoutWithContext:[RTMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setMessageBubbleLeftRightMargin:(CGFloat)messageBubbleLeftRightMargin {
    NSParameterAssert(messageBubbleLeftRightMargin >= 0.0f);
    _messageBubbleLeftRightMargin = ceilf(messageBubbleLeftRightMargin);
    [self invalidateLayoutWithContext:[RTMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setMessageBubbleTextViewTextContainerInsets:(UIEdgeInsets)messageBubbleTextContainerInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_messageBubbleTextViewTextContainerInsets, messageBubbleTextContainerInsets)) {
        return;
    }
    
    _messageBubbleTextViewTextContainerInsets = messageBubbleTextContainerInsets;
    [self invalidateLayoutWithContext:[RTMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setIncomingAvatarViewSize:(CGSize)incomingAvatarViewSize {
    if (CGSizeEqualToSize(_incomingAvatarViewSize, incomingAvatarViewSize)) {
        return;
    }
    
    _incomingAvatarViewSize = incomingAvatarViewSize;
    [self invalidateLayoutWithContext:[RTMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setOutgoingAvatarViewSize:(CGSize)outgoingAvatarViewSize {
    if (CGSizeEqualToSize(_outgoingAvatarViewSize, outgoingAvatarViewSize)) {
        return;
    }
    
    _outgoingAvatarViewSize = outgoingAvatarViewSize;
    [self invalidateLayoutWithContext:[RTMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setCacheLimit:(NSUInteger)cacheLimit {
    self.messageBubbleCache.countLimit = cacheLimit;
}

#pragma mark - Getters

- (CGFloat)itemWidth {
    return CGRectGetWidth(self.collectionView.frame) - self.sectionInset.left - self.sectionInset.right;
}

- (UIDynamicAnimator *)dynamicAnimator {
    if (!_dynamicAnimator) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    }
    return _dynamicAnimator;
}

- (NSMutableSet *)visibleIndexPaths {
    if (!_visibleIndexPaths) {
        _visibleIndexPaths = [NSMutableSet new];
    }
    return _visibleIndexPaths;
}

- (NSUInteger)cacheLimit {
    return self.messageBubbleCache.countLimit;
}

#pragma mark - Notifications
- (void)rt_didReceiveApplicationMemoryWarningNotification:(NSNotification *)notification {
    [self rt_resetLayout];
}

- (void)rt_didReceiveDeviceOrientationDidChangeNotification:(NSNotification *)notification {
    [self rt_resetLayout];
    [self invalidateLayoutWithContext:[RTMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

#pragma mark - Collection view flow layout

- (void)invalidateLayoutWithContext:(RTMessagesCollectionViewFlowLayoutInvalidationContext *)context
{
    if (context.invalidateDataSourceCounts) {
        context.invalidateFlowLayoutAttributes = YES;
        context.invalidateFlowLayoutDelegateMetrics = YES;
    }
    
    if (context.invalidateFlowLayoutAttributes
        || context.invalidateFlowLayoutDelegateMetrics) {
        [self rt_resetDynamicAnimator];
    }
    
    if (context.invalidateFlowLayoutMessagesCache) {
        [self rt_resetLayout];
    }
    
    [super invalidateLayoutWithContext:context];
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    if (self.springinessEnabled) {
        //  pad rect to avoid flickering
        CGFloat padding = -100.0f;
        CGRect visibleRect = CGRectInset(self.collectionView.bounds, padding, padding);
        
        NSArray *visibleItems = [super layoutAttributesForElementsInRect:visibleRect];
        NSSet *visibleItemsIndexPaths = [NSSet setWithArray:[visibleItems valueForKey:NSStringFromSelector(@selector(indexPath))]];
        
        [self rt_removeNoLongerVisibleBehaviorsFromVisibleItemsIndexPaths:visibleItemsIndexPaths];
        
        [self rt_addNewlyVisibleBehaviorsFromVisibleItems:visibleItems];
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributesInRect = [super layoutAttributesForElementsInRect:rect];
    
    if (self.springinessEnabled) {
        NSMutableArray *attributesInRectCopy = [attributesInRect mutableCopy];
        NSArray *dynamicAttributes = [self.dynamicAnimator itemsInRect:rect];
        
        //  avoid duplicate attributes
        //  use dynamic animator attribute item instead of regular item, if it exists
        for (UICollectionViewLayoutAttributes *eachItem in attributesInRect) {
            
            for (UICollectionViewLayoutAttributes *eachDynamicItem in dynamicAttributes) {
                if ([eachItem.indexPath isEqual:eachDynamicItem.indexPath]
                    && eachItem.representedElementCategory == eachDynamicItem.representedElementCategory) {
                    
                    [attributesInRectCopy removeObject:eachItem];
                    [attributesInRectCopy addObject:eachDynamicItem];
                    continue;
                }
            }
        }
        
        attributesInRect = attributesInRectCopy;
    }
    
    [attributesInRect enumerateObjectsUsingBlock:^(RTMessagesCollectionViewLayoutAttributes *attributesItem, NSUInteger idx, BOOL *stop) {
        if (attributesItem.representedElementCategory == UICollectionElementCategoryCell) {
            [self rt_configureMessageCellLayoutAttributes:attributesItem];
        }
        else {
            attributesItem.zIndex = -1;
        }
    }];
    
    return attributesInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RTMessagesCollectionViewLayoutAttributes *customAttributes = (RTMessagesCollectionViewLayoutAttributes *)[super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (customAttributes.representedElementCategory == UICollectionElementCategoryCell) {
        [self rt_configureMessageCellLayoutAttributes:customAttributes];
    }
    
    return customAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    if (self.springinessEnabled) {
        UIScrollView *scrollView = self.collectionView;
        CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
        
        self.latestDelta = delta;
        
        CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
        
        [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
            [self rt_adjustSpringBehavior:springBehaviour forTouchLocation:touchLocation];
            [self.dynamicAnimator updateItemUsingCurrentState:[springBehaviour.items firstObject]];
        }];
    }
    
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    
    return NO;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger index, BOOL *stop) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            
            if (self.springinessEnabled && [self.dynamicAnimator layoutAttributesForCellAtIndexPath:updateItem.indexPathAfterUpdate]) {
                *stop = YES;
            }
            
            CGFloat collectionViewHeight = CGRectGetHeight(self.collectionView.bounds);
            
            RTMessagesCollectionViewLayoutAttributes *attributes = [RTMessagesCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:updateItem.indexPathAfterUpdate];
            
            if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
                [self rt_configureMessageCellLayoutAttributes:attributes];
            }
            
            attributes.frame = CGRectMake(0.0f,
                                          collectionViewHeight + CGRectGetHeight(attributes.frame),
                                          CGRectGetWidth(attributes.frame),
                                          CGRectGetHeight(attributes.frame));
            
            if (self.springinessEnabled) {
                UIAttachmentBehavior *springBehaviour = [self rt_springBehaviorWithLayoutAttributesItem:attributes];
                [self.dynamicAnimator addBehavior:springBehaviour];
            }
        }
    }];
}

#pragma mark - Invalidation utilities
- (void)rt_resetLayout {
    [self.messageBubbleCache removeAllObjects];
    [self rt_resetDynamicAnimator];
}

- (void)rt_resetDynamicAnimator {
    if (self.springinessEnabled) {
        [self.dynamicAnimator removeAllBehaviors];
        [self.visibleIndexPaths removeAllObjects];
    }
}

#pragma mark - Message cell layout utilities

- (CGSize)messageBubbleSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<RTMessageData> messageItem = [self.collectionView.dataSource collectionView:self.collectionView messageDataForItemAtIndexPath:indexPath];
    
    NSValue *cachedSize = [self.messageBubbleCache objectForKey:@([messageItem messageHash])];
    if (cachedSize != nil) {
        return [cachedSize CGSizeValue];
    }
    
    CGSize finalSize = CGSizeZero;
    
    if ([messageItem isMediaMessage]) {
        finalSize = [[messageItem media] mediaViewDisplaySize];
    }
    else {
        CGSize avatarSize = [self rt_avatarSizeForIndexPath:indexPath];
        
        //  from the cell xibs, there is a 2 point space between avatar and bubble
        CGFloat spacingBetweenAvatarAndBubble = 2.0f;
        CGFloat horizontalContainerInsets = self.messageBubbleTextViewTextContainerInsets.left + self.messageBubbleTextViewTextContainerInsets.right;
        CGFloat horizontalFrameInsets = self.messageBubbleTextViewFrameInsets.left + self.messageBubbleTextViewFrameInsets.right;
        
        CGFloat horizontalInsetsTotal = horizontalContainerInsets + horizontalFrameInsets + spacingBetweenAvatarAndBubble;
        CGFloat maximumTextWidth = self.itemWidth - avatarSize.width - self.messageBubbleLeftRightMargin - horizontalInsetsTotal;
        
        CGRect stringRect = [[messageItem text] boundingRectWithSize:CGSizeMake(maximumTextWidth, CGFLOAT_MAX)
                                                             options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                          attributes:@{ NSFontAttributeName : self.messageBubbleFont }
                                                             context:nil];
        
        CGSize stringSize = CGRectIntegral(stringRect).size;
        
        CGFloat verticalContainerInsets = self.messageBubbleTextViewTextContainerInsets.top + self.messageBubbleTextViewTextContainerInsets.bottom;
        CGFloat verticalFrameInsets = self.messageBubbleTextViewFrameInsets.top + self.messageBubbleTextViewFrameInsets.bottom;
        
        //  add extra 2 points of space, because `boundingRectWithSize:` is slightly off
        //  not sure why. magix. (shrug) if you know, submit a PR
        CGFloat verticalInsets = verticalContainerInsets + verticalFrameInsets + 2.0f;
        
        //  same as above, an extra 2 points of magix
        CGFloat finalWidth = MAX(stringSize.width + horizontalInsetsTotal, self.bubbleImageAssetWidth) + 2.0f;
        
        finalSize = CGSizeMake(finalWidth, stringSize.height + verticalInsets);
    }
    
    [self.messageBubbleCache setObject:[NSValue valueWithCGSize:finalSize] forKey:@([messageItem messageHash])];
    
    return finalSize;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize messageBubbleSize = [self messageBubbleSizeForItemAtIndexPath:indexPath];
    RTMessagesCollectionViewLayoutAttributes *attributes = (RTMessagesCollectionViewLayoutAttributes *)[self layoutAttributesForItemAtIndexPath:indexPath];
    
    CGFloat finalHeight = messageBubbleSize.height;
    finalHeight += attributes.cellTopLabelHeight;
    finalHeight += attributes.messageBubbleTopLabelHeight;
    finalHeight += attributes.cellBottomLabelHeight;
    
    return CGSizeMake(self.itemWidth, ceilf(finalHeight));
}

- (void)rt_configureMessageCellLayoutAttributes:(RTMessagesCollectionViewLayoutAttributes *)layoutAttributes
{
    NSIndexPath *indexPath = layoutAttributes.indexPath;
    
    CGSize messageBubbleSize = [self messageBubbleSizeForItemAtIndexPath:indexPath];
    
    layoutAttributes.messageBubbleContainerViewWidth = messageBubbleSize.width;
    
    layoutAttributes.textViewFrameInsets = self.messageBubbleTextViewFrameInsets;
    
    layoutAttributes.textViewTextContainerInsets = self.messageBubbleTextViewTextContainerInsets;
    
    layoutAttributes.messageBubbleFont = self.messageBubbleFont;
    
    layoutAttributes.incomingAvatarViewSize = self.incomingAvatarViewSize;
    
    layoutAttributes.outgoingAvatarViewSize = self.outgoingAvatarViewSize;
    
    layoutAttributes.cellTopLabelHeight = [self.collectionView.delegate collectionView:self.collectionView
                                                                                layout:self
                                                      heightForCellTopLabelAtIndexPath:indexPath];
    
    layoutAttributes.messageBubbleTopLabelHeight = [self.collectionView.delegate collectionView:self.collectionView
                                                                                         layout:self
                                                      heightForMessageBubbleTopLabelAtIndexPath:indexPath];
    
    layoutAttributes.cellBottomLabelHeight = [self.collectionView.delegate collectionView:self.collectionView
                                                                                   layout:self
                                                      heightForCellBottomLabelAtIndexPath:indexPath];
}

- (CGSize)rt_avatarSizeForIndexPath:(NSIndexPath *)indexPath
{
    id<RTMessageData> messageData = [self.collectionView.dataSource collectionView:self.collectionView messageDataForItemAtIndexPath:indexPath];
    NSString *messageSender = [messageData senderId];
    
    if ([messageSender isEqualToString:[self.collectionView.dataSource senderId]]) {
        return self.outgoingAvatarViewSize;
    }
    
    return self.incomingAvatarViewSize;
}

#pragma mark - Spring behavior utilities
- (UIAttachmentBehavior *)rt_springBehaviorWithLayoutAttributesItem:(UICollectionViewLayoutAttributes *)item
{
    if (CGSizeEqualToSize(item.frame.size, CGSizeZero)) {
        // adding a spring behavior with zero size will fail in in -prepareForCollectionViewUpdates:
        return nil;
    }
    
    UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];
    springBehavior.length = 1.0f;
    springBehavior.damping = 1.0f;
    springBehavior.frequency = 1.0f;
    return springBehavior;
}

- (void)rt_addNewlyVisibleBehaviorsFromVisibleItems:(NSArray *)visibleItems {

    NSIndexSet *indexSet = [visibleItems indexesOfObjectsPassingTest:^BOOL(UICollectionViewLayoutAttributes *item, NSUInteger index, BOOL *stop) {
        return ![self.visibleIndexPaths containsObject:item.indexPath];
    }];
    
    NSArray *newlyVisibleItems = [visibleItems objectsAtIndexes:indexSet];
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger index, BOOL *stop) {
        UIAttachmentBehavior *springBehaviour = [self rt_springBehaviorWithLayoutAttributesItem:item];
        [self rt_adjustSpringBehavior:springBehaviour forTouchLocation:touchLocation];
        [self.dynamicAnimator addBehavior:springBehaviour];
        [self.visibleIndexPaths addObject:item.indexPath];
    }];
}

- (void)rt_removeNoLongerVisibleBehaviorsFromVisibleItemsIndexPaths:(NSSet *)visibleItemsIndexPaths {
    NSArray *behaviors = self.dynamicAnimator.behaviors;
    
    NSIndexSet *indexSet = [behaviors indexesOfObjectsPassingTest:^BOOL(UIAttachmentBehavior *springBehaviour, NSUInteger index, BOOL *stop) {
        UICollectionViewLayoutAttributes *layoutAttributes = [springBehaviour.items firstObject];
        return ![visibleItemsIndexPaths containsObject:layoutAttributes.indexPath];
    }];
    
    NSArray *behaviorsToRemove = [self.dynamicAnimator.behaviors objectsAtIndexes:indexSet];
    
    [behaviorsToRemove enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger index, BOOL *stop) {
        UICollectionViewLayoutAttributes *layoutAttributes = [springBehaviour.items firstObject];
        [self.dynamicAnimator removeBehavior:springBehaviour];
        [self.visibleIndexPaths removeObject:layoutAttributes.indexPath];
    }];
}

- (void)rt_adjustSpringBehavior:(UIAttachmentBehavior *)springBehavior forTouchLocation:(CGPoint)touchLocation
{
    UICollectionViewLayoutAttributes *item = [springBehavior.items firstObject];
    CGPoint center = item.center;
    
    //  if touch is not (0,0) -- adjust item center "in flight"
    if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
        CGFloat distanceFromTouch = fabs(touchLocation.y - springBehavior.anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / self.springResistanceFactor;
        
        if (self.latestDelta < 0.0f) {
            center.y += MAX(self.latestDelta, self.latestDelta * scrollResistance);
        }
        else {
            center.y += MIN(self.latestDelta, self.latestDelta * scrollResistance);
        }
        item.center = center;
    }
}


@end
