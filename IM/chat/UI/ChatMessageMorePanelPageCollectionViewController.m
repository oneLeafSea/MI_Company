//
//  ChatMessageMorePanelPageCollectionViewController.m
//  IM
//
//  Created by 郭志伟 on 15-2-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMessageMorePanelPageCollectionViewController.h"
#import "ChatViewMorePanelCellView.h"
#import "ChatMessageMorePanelItemMode.h"

static NSUInteger kCellWidth = 69;
static NSUInteger kCellHeight = 95;
static NSUInteger kInsetOffset = 5;

@interface ChatMessageMorePanelPageCollectionViewController () {
    NSArray *m_panelItems;
}

@end

@implementation ChatMessageMorePanelPageCollectionViewController

static NSString * const reuseIdentifier = @"CollectionCell";

+ (NSUInteger)getPanelItemCount {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSUInteger screenWidth = screenRect.size.width;
    NSUInteger lineCount = screenWidth / (kCellWidth + 2 * kInsetOffset);
    return 2 * lineCount;
}

- (instancetype)initWithPanelItems:(NSArray *) panelItems {
    m_panelItems = panelItems;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self = [super initWithCollectionViewLayout:layout];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[ChatViewMorePanelCellView class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.backgroundColor = [UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark <UICollectionViewDataSource>

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, kInsetOffset, 15, kInsetOffset);
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return m_panelItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
   ChatViewMorePanelCellView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    ChatMessageMorePanelItemMode *itemModel = [m_panelItems objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:itemModel.imageName];
    cell.textLabel.text = itemModel.title;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kCellWidth, kCellHeight);
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessageMorePanelItemMode *item = [m_panelItems objectAtIndex:indexPath.row];
    if ([item.target respondsToSelector:item.selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [item.target performSelector:item.selector];
#pragma clang diagnostic pop
    }
    
}


@end
