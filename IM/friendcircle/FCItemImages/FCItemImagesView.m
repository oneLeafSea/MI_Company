//
//  FCItemImagesView.m
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCItemImagesView.h"

#import <Masonry.h>

#import "FCIImagesitemCollectionViewCell.h"
#import "FCConstants.h"
#import "MWPhotoBrowser.h"

@interface FCItemImagesView() <UICollectionViewDelegate, UICollectionViewDataSource, MWPhotoBrowserDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSArray        *photos;

@end

@implementation FCItemImagesView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}



- (void)setup {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = [FCItemImagesView getItemSz];
    layout.minimumLineSpacing = FC_IMAGES_MARGIN;
    layout.minimumInteritemSpacing = FC_IMAGES_MARGIN;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[FCIImagesitemCollectionViewCell class] forCellWithReuseIdentifier:@"FCIImagesitemCollectionViewCell"];
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

+ (CGSize) getItemSz {
    CGSize screenSz = [UIScreen mainScreen].bounds.size;
    CGFloat screenWidth = screenSz.width;
    CGFloat itemWidth = (screenWidth - FC_IMAGES_LEFT_OFFSET - FC_IMAGES_RIGHT_OFFSET - (FC_IMAGES_COUNT_PER_LINE - 1) * FC_IMAGES_MARGIN) / FC_IMAGES_COUNT_PER_LINE;
    return CGSizeMake(itemWidth, itemWidth);
}

- (void)setModel:(FCItemImagesViewModel *)model {
    _model = model;
    [self.collectionView reloadData];
}

+ (CGFloat) heightForImagesHeight:(FCItemImagesViewModel *)model {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat imgsViewWidth = screenWidth - FC_IMAGES_LEFT_OFFSET - FC_IMAGES_RIGHT_OFFSET;
    CGFloat ImgViewWidth = (imgsViewWidth - (FC_IMAGES_COUNT_PER_LINE - 1) * FC_IMAGES_MARGIN) / FC_IMAGES_COUNT_PER_LINE;
    CGFloat imgViewHeight = ImgViewWidth;
    NSInteger row = ceil(model.collectionCellModels.count / FC_IMAGES_COUNT_PER_LINE);
    CGFloat height = row * imgViewHeight + (row - 1) * FC_IMAGES_MARGIN;
    return height;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = self.model.collectionCellModels.count;
    return count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FCIImagesitemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FCIImagesitemCollectionViewCell" forIndexPath:indexPath];
    cell.model = [self.model.collectionCellModels objectAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    [self showImgs:indexPath.row];
}

- (NSArray *)photos {
    if (!_photos) {
        NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:self.model.collectionCellModels.count];
        [self.model.collectionCellModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FCIImagesitemCollectionViewCellModel *cvcm = obj;
            MWPhoto *photo = [[MWPhoto alloc] initWithURL:cvcm.imgurl];
            [photos addObject:photo];
        }];
        _photos = photos;
    }
    return _photos;
}

- (void)showImgs:(NSInteger)index {
    BOOL displayActionButton = NO;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    enableGrid = NO;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:index];

    [self.curVC.navigationController pushViewController:browser animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count)
        return [self.photos objectAtIndex:index];
    return nil;
}

@end
