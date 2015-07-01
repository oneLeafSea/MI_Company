//
//  FCNPImagePickerView.m
//  IM
//
//  Created by 郭志伟 on 15/6/23.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCNPImagePickerView.h"

#import <Masonry.h>

#import "FCNPImagePickerCollectionViewCell.h"
#import "CTAssetsPickerController.h"
#import "MWPhotoBrowser.h"
#import "UIImage+Common.h"

#define FCNP_IMAGE_PICKER_ROW_COUNT 4.0f
#define FCNP_IMAGE_PICKER_INTERVAL 3.0f
#define FCNP_IMAGE_PICKER_MARGIN 15.0f
#define FCNP_IMAGE_PICKER_MAX_COUNT 9

@interface FCNPImagePickerView()<UICollectionViewDelegate, UICollectionViewDataSource, CTAssetsPickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MWPhotoBrowserDelegate> {
    BOOL _imgFlags[9];
}



@property(readonly) CGSize itemSize;

@property(nonatomic, assign) NSInteger maxImgs;

@end

@implementation FCNPImagePickerView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
        self.maxImgs = FCNP_IMAGE_PICKER_MAX_COUNT;
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [self resetImgFlags];
    }
    return self;
}

#pragma mark -overrid
- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 111);
}


#pragma mark - private method
- (NSInteger)getCellCount {
    return self.imgArray.count + 1;
}

- (void)showActionSheet {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameralAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
            imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imgPicker.delegate = self;
            [self.naviVC presentViewController:imgPicker animated:YES completion:nil];
        }
    }];
    [alertVC addAction:cameralAction];
    UIAlertAction *assestsAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        CTAssetsPickerController *assetsPickerVC = [[CTAssetsPickerController alloc] init];
        assetsPickerVC.delegate = self;
        assetsPickerVC.assetsFilter = [ALAssetsFilter allPhotos];
        [self.naviVC presentViewController:assetsPickerVC animated:YES completion:nil];
    }];
    [alertVC addAction:assestsAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [alertVC addAction:cancelAction];
    [self.naviVC presentViewController:alertVC animated:YES completion:nil];
}


- (void)showImageViewerAtIndex:(NSInteger)index {
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = YES;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    browser.enableSwipeToDismiss = NO;
    [browser setCurrentPhotoIndex:index];
    [self.naviVC pushViewController:browser animated:YES];
}

#pragma mark - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self getCellCount];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FCNPImagePickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FCNPImagePickerCollectionViewCell" forIndexPath:indexPath];
    if (indexPath.row == self.imgArray.count) {
        cell.imgView.image = [UIImage imageNamed:@"fc_imgpicker_add"];
        return cell;
    }
    cell.imgView.image = self.imgArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (indexPath.row == [self getCellCount] - 1) {
        if (self.imgArray.count >= self.maxImgs) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"注意" message:[NSString stringWithFormat:@"图片不能超过%ld张", (long)self.maxImgs] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
            [av show];
            return;
        }
        [self showActionSheet];
    }
    
    [self showImageViewerAtIndex:indexPath.row];
}

#pragma mark - getter & setter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = self.itemSize;
        layout.footerReferenceSize = CGSizeMake(0.0f, 0.0f);
        layout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        layout.minimumInteritemSpacing = 0.0;
        layout.minimumLineSpacing = FCNP_IMAGE_PICKER_INTERVAL;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[FCNPImagePickerCollectionViewCell class] forCellWithReuseIdentifier:@"FCNPImagePickerCollectionViewCell"];
    }
    return _collectionView;
}

- (void)setImgArray:(NSArray *)imgArray {
    _imgArray = imgArray;
    [self.collectionView reloadData];
    if ([self.delegate respondsToSelector:@selector(FCNPImagePickerViewDataDidChanged:height:)]) {
        [self.delegate FCNPImagePickerViewDataDidChanged:self height:self.collectionView.collectionViewLayout.collectionViewContentSize.height];
    }
}

- (CGSize)itemSize {
    CGFloat sWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat itemWidth = (sWidth - 30 - 3.0*4) / 4;
    CGFloat itemHeight = itemWidth;
    return CGSizeMake(itemWidth, itemHeight);
}

#pragma mark -assetsPickerController delegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:self.imgArray];
    [picker.selectedAssets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ALAsset *a = obj;
        UIImage *img = [UIImage imageWithCGImage:[a.defaultRepresentation fullScreenImage]];
        [mutableArray addObject:img];
    }];
    self.imgArray = mutableArray;
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group {
    return ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos);
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset {
    if (picker.selectedAssets.count + self.imgArray.count >= self.maxImgs) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"注意" message:[NSString stringWithFormat:@"图片不能超过%ld张", (long)self.maxImgs] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [av show];
        return NO;
    }
    return YES;
}

#pragma mark -imagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    img = [img fixOrientation];
    img = [self imageWithImage:img scaledToWidth:1080];
   
    UIImage *small = [UIImage imageWithCGImage:img.CGImage scale:0.1 orientation:UIImageOrientationUp];
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:self.imgArray];
    [mutableArray addObject:small];
    self.imgArray = mutableArray;
}

- (UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.imgArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    MWPhoto *p = [[MWPhoto alloc] initWithImage:self.imgArray[index]];
    return p;
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return _imgFlags[index];
}
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    _imgFlags[index] = selected;
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:FCNP_IMAGE_PICKER_MAX_COUNT];
    [self.imgArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BOOL selected = _imgFlags[idx];
        if (selected) {
            [mutableArray addObject:obj];
        }
    }];
    self.imgArray = mutableArray;
    [self resetImgFlags];
}

- (void)resetImgFlags {
    for (NSInteger n = 0; n < sizeof(_imgFlags); n++) {
        _imgFlags[n] = YES;
    }
}


@end
