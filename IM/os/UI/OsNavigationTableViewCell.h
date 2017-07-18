//
//  OsNavigationTableViewCell.h
//  IM
//
//  Created by 郭志伟 on 15-3-5.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OsNavigationTableViewCellDelegate;

@interface OsNavigationTableViewCell : UITableViewCell

- (void)setCollectionData:(NSArray *)collectionData;
@property(weak) id<OsNavigationTableViewCellDelegate> delgate;

@end

@protocol OsNavigationTableViewCellDelegate <NSObject>

- (void)OsNavigationTableViewCell:(OsNavigationTableViewCell *)cell tappedAtIndex:(NSInteger)index;

@end