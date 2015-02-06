//
//  ChatViewMorePanelView.m
//  IM
//
//  Created by 郭志伟 on 15-2-3.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatViewMorePanelView.h"
#import "ChatViewMorePanelCellView.h"

@interface ChatViewMorePanelView()<UICollectionViewDataSource, UICollectionViewDelegate> {
    
    UICollectionView *m_collectionView;
}
@end

@implementation ChatViewMorePanelView

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        m_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 210) collectionViewLayout:layout];
        [m_collectionView registerClass:[ChatViewMorePanelCellView class] forCellWithReuseIdentifier:@"CollectionCell"];
        m_collectionView.backgroundColor = [UIColor whiteColor];
        m_collectionView.pagingEnabled = YES;
        m_collectionView.delegate = self;
        m_collectionView.dataSource = self;
        [self addSubview:m_collectionView];
        [self setConstraint];
       
    }
    return self;
}

- (void)setConstraint {
    NSDictionary *viewsDictionary =
    NSDictionaryOfVariableBindings(m_collectionView);
    m_collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[m_collectionView]|" options:0 metrics:nil views:viewsDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[m_collectionView]|" options:0 metrics:nil views:viewsDictionary]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChatViewMorePanelCellView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    NSLog(@"%ld", (long)indexPath.row);
    switch (indexPath.row) {
        case 1:
            cell.imageView.image = [UIImage imageNamed:@"chatmsg_pic"];
            cell.textLabel.text = @"照片";
            break;
        case 2:
            cell.imageView.image = [UIImage imageNamed:@"chatmsg_video"];
            cell.textLabel.text = @"视频";
            break;
        case 3:
            cell.imageView.image = [UIImage imageNamed:@"chatmsg_folder"];
            cell.textLabel.text = @"文件";
            break;
        case 4:
            cell.imageView.image = [UIImage imageNamed:@"chatmsg_phone"];
            cell.textLabel.text = @"通话";
            break;
        default:
            break;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(69, 95);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", indexPath);
}

@end
