//
//  MultiSelectViewController.h
//  MultiSelectTableViewController
//
//  Created by molon on 6/7/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiSelectItem.h"

@protocol MultiSelectViewControllerDelegate;

@interface MultiSelectViewController : UIViewController

@property (nonatomic, strong) NSArray *items;

@property(weak) id<MultiSelectViewControllerDelegate> delegate;

@end


@protocol MultiSelectViewControllerDelegate <NSObject>

- (void)MultiSelectViewController:(MultiSelectViewController *)controller didConfirmWithSelectedItems:(NSArray *)selectedItems;

@end