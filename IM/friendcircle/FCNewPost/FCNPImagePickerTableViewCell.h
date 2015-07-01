//
//  FCNPImagePickerTableViewCell.h
//  IM
//
//  Created by 郭志伟 on 15/6/24.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FCNPImagePickerTableViewCellDelegate;

@interface FCNPImagePickerTableViewCell : UITableViewCell

@property(weak, nonatomic)UINavigationController *naviController;

@property(weak) id<FCNPImagePickerTableViewCellDelegate> delegate;

@property(readonly)NSArray* imgArray;

@end


@protocol FCNPImagePickerTableViewCellDelegate <NSObject>

- (void)imagePickerTableViewCell:(FCNPImagePickerTableViewCell *)cell heightShouldChanged:(CGFloat)height;

@end