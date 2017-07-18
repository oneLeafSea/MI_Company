//
//  FCNPImagePickerView.h
//  IM
//
//  Created by 郭志伟 on 15/6/23.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol FCNPImagePickerViewDelegate;

@interface FCNPImagePickerView : UIView

@property(weak) id<FCNPImagePickerViewDelegate> delegate;

@property(weak) UINavigationController *naviVC;

@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)NSArray *imgArray;
@end

@protocol FCNPImagePickerViewDelegate <NSObject>

- (void)FCNPImagePickerViewDataDidChanged:(FCNPImagePickerView *)pickerView height:(CGFloat)height;

@end