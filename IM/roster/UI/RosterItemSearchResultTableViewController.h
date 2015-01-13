//
//  RosterItemSearchResultTableViewController.h
//  IM
//
//  Created by 郭志伟 on 15-1-12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RosterItemSearchResultTableViewController : UITableViewController

@property(nonatomic, strong) NSArray *searchResult;
@property(nonatomic)         NSString *content;
@property(nonatomic)         NSUInteger curPage;
@property(nonatomic)         NSUInteger pageSz;

@end
