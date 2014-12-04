//
//  swipeBtnBarView.m
//  testPagesMgr
//
//  Created by 郭志伟 on 14-11-2.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "SwipeBtnBarView.h"

const NSUInteger kSelectedBarHeight = 5;

typedef NS_ENUM(NSUInteger, swipeDirection) {
    swipeDirectionLeft,
    swipeDirectionRight,
    swipeDirectionNone
};

@interface SwipeBtnBarView() {
    UIView * m_selectedBar;
    NSUInteger m_selectedOptionIndex;
}

@end

@implementation SwipeBtnBarView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self setup];
    }
    return self;
}



-(void)moveToIndex:(NSUInteger)index animated:(BOOL)animated {
//    if (m_selectedOptionIndex != index) {
        swipeDirection direction = swipeDirectionRight;
        if (index < m_selectedOptionIndex) {
            direction = swipeDirectionLeft;
        }
        m_selectedOptionIndex = index;
        [self updateSelectedBarPositionWithAnimation:animated swipeDirection:direction];
//    }
}

-(void)updateSelectedBarPositionWithAnimation:(BOOL)animation swipeDirection:(swipeDirection)direction {
    CGRect frame = m_selectedBar.frame;
    UICollectionViewCell * cell = [self.dataSource collectionView:self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:m_selectedOptionIndex inSection:0]];
    if (cell){
        if (direction != swipeDirectionNone){
            [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:m_selectedOptionIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }
    }
    else{
        NSLog(@"Log");
    }
//    NSLog(@"%@", cell.frame);
    frame.size.width = cell.frame.size.width;
    frame.origin.x = cell.frame.origin.x;
    frame.origin.y = self.frame.size.height - kSelectedBarHeight;
    if (animation){
        [UIView animateWithDuration:0.3 animations:^{
            [m_selectedBar setFrame:frame];
        }];
    }
    else{
        m_selectedBar.frame = frame;
    }
}


#pragma mark -private method

- (void)setup {
    m_selectedOptionIndex = 0;
    [self initSelectedBar];
    [self addSubview:m_selectedBar];
}

- (void)initSelectedBar {
    if (m_selectedBar) return;
    m_selectedBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kSelectedBarHeight, self.frame.size.width, kSelectedBarHeight)];
    m_selectedBar.layer.zPosition = 9999;
    m_selectedBar.backgroundColor = [UIColor orangeColor];
}

@end
