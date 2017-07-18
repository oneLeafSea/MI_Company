//
//  RTViewController.m
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTViewController.h"

@implementation RTViewController

- (UITableView *)createTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    return tableView;
}

@end
