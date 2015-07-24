//
//  RTMorePanelView.m
//  IM
//
//  Created by 郭志伟 on 15/7/15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMorePanelView.h"
#import <Masonry/Masonry.h>
#import "RTMorePanelItemMode.h"
#import "RTMoreViewCollectionViewCell.h"

static NSUInteger kCellWidth = 69;
static NSUInteger kCellHeight = 95;
static NSUInteger kInsetOffset = 5;

@interface RTMorePanelView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray    *items;

@end

@implementation RTMorePanelView

- (void)rt_configureView {
    [self addSubview:self.collectionView];
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self rt_configureView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self rt_configureView];
}


#pragma mark - Getters
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1];
        [_collectionView registerClass:[RTMoreViewCollectionViewCell class] forCellWithReuseIdentifier:@"RTMoreViewCollectionViewCell"];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
    }
    return _collectionView;
}

- (NSMutableArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

- (void)registerItemWithTitle:(NSString *)title
                       image:(UIImage *)image
                      target:(id)target
                      action:(SEL)selector {
    RTMorePanelItemMode *model = [[RTMorePanelItemMode alloc] initWithTitle:title image:image target:target selector:selector];
    [self.items addObject:model];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView delegate & datasource

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, kInsetOffset, 15, kInsetOffset);
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RTMoreViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RTMoreViewCollectionViewCell" forIndexPath:indexPath];
    
    RTMorePanelItemMode *itemModel = [self.items objectAtIndex:indexPath.row];
    cell.imageView.image = itemModel.image;
    cell.textLabel.text = itemModel.title;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kCellWidth, kCellHeight);
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RTMorePanelItemMode *item = [self.items objectAtIndex:indexPath.row];
    if ([item.target respondsToSelector:item.selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [item.target performSelector:item.selector];
#pragma clang diagnostic pop
    }
    
}

@end
