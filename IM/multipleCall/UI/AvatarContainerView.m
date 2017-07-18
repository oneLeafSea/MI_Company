//
//  AvatarContainerView.m
//  IM
//
//  Created by 郭志伟 on 15/5/6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "AvatarContainerView.h"
#import "AvatarContainerCellCollectionViewCell.h"
#import "UIImageView+common.h"

#define kCellWidth 80
#define kCellHeight 100

@interface AvatarContainerView() <UICollectionViewDataSource, UICollectionViewDelegate> {
    __weak IBOutlet UICollectionView *_collectionView;
    NSMutableArray      *m_items;
}
@end

@implementation AvatarContainerView

+ (instancetype)instanceFromNib {
    return [[[NSBundle mainBundle]loadNibNamed:@"AvatarContainerView" owner:nil options:nil] lastObject];
}



- (instancetype)initWithFrame:(CGRect)frame {
    return [AvatarContainerView instanceFromNib];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    self.autoresizingMask = UIViewAutoresizingNone;
    self.backgroundColor = [UIColor clearColor];
    
    [_collectionView registerClass:[AvatarContainerCellCollectionViewCell class] forCellWithReuseIdentifier:@"AvatarContainerCellCollectionViewCell"];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    m_items = [[NSMutableArray alloc] init];
}

- (void)setItems:(NSArray *)items {
    m_items = [[NSMutableArray alloc] initWithArray:items];
    [_collectionView reloadData];
}

- (NSArray *)items {
    return m_items;
}

- (void)removeAvatarItemByUid:(NSString *)uid {
    __block AvatarContainerViewItem *item = nil;
    __block NSUInteger index = -1;
    [m_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AvatarContainerViewItem *i = obj;
        if ([i.uid isEqual:uid]) {
            item = i;
            index = idx;
        }
    }];
    if (item) {
        [m_items removeObjectAtIndex:index];
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:index inSection:0];
        [_collectionView deleteItemsAtIndexPaths:@[idxPath]];
    }
    [self ajustPos];
}

- (void)setAvatarItemUid:(NSString *)uid Ready:(BOOL)ready {
    [m_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AvatarContainerViewItem *item = obj;
        if ([item.uid isEqualToString:uid]) {
            item.ready = YES;
            *stop = YES;
        }
    }];
}


- (void)addAvatarItem:(AvatarContainerViewItem *)item {
    
    if ([self isExistItem:item]) {
        [_collectionView reloadData];
        return;
    }
    [m_items addObject:item];
    [_collectionView reloadData];
    [self ajustPos];
}

- (void)refresh {
    [_collectionView reloadData];
}

- (BOOL)isExistUid:(NSString *)uid {
    __block BOOL ret = NO;
    [m_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AvatarContainerViewItem *i = obj;
        if ([i.uid isEqualToString:uid]) {
            ret = YES;
        }
    }];
    return ret;
}

- (BOOL)isExistItem:(AvatarContainerViewItem *)item {
    __block BOOL ret = NO;
    [m_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AvatarContainerViewItem *i = obj;
        if ([i.uid isEqualToString:item.uid]) {
            ret = YES;
        }
    }];
    return ret;
}

- (void)ajustPos {
    CGFloat width = m_items.count * kCellWidth;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGFloat x = (screenWidth - width) / 2;
    CGFloat y = (screenHeight - kCellHeight) / 2;
    if (width > screenWidth) {
        self.frame = CGRectMake(0, y, screenWidth, kCellHeight);
    } else {
        self.frame = CGRectMake(x, y, width, kCellHeight);
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return m_items.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AvatarContainerCellCollectionViewCell";
    AvatarContainerCellCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [AvatarContainerCellCollectionViewCell instanceFromNib];
    }
    AvatarContainerViewItem *item = [m_items objectAtIndex:indexPath.row];
    cell.avatarImgView.image = [UIImage imageWithContentsOfFile:item.imgStrUrl];
    [cell.avatarImgView circle];
    cell.nameLbl.text = item.name;
    cell.speakerImgView.hidden = !item.ready;
    return cell;
}



#pragma mark --     UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kCellWidth, kCellHeight);
}

@end
