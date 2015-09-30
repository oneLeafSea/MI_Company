//
//  FuncViewController.m
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FuncViewController.h"
#import "UITableViewCell+Extenssion.h"
#import <Masonry.h>
#import "FriendCircleViewController.h"
#import "FuncFcTableViewCell.h"
#import "AppDelegate.h"
#import "WorkReportViewController.h"

@interface FuncViewController () <UITableViewDataSource, UITableViewDelegate>


@end

@implementation FuncViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- private method
- (void) setupTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:240 / 255.0 alpha:1.0];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[FuncFcTableViewCell class] forCellReuseIdentifier:@"FuncFcTableViewCell"];
}


#pragma mark -- tablview delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return [UITableViewCell separatorCell];
    }
    
    if (indexPath.row == 1) {
        FuncFcTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FuncFcTableViewCell" forIndexPath:indexPath];
        cell.badgeShow = USER.fcMgr.hasNewNotification;
        cell.imageView.image = [UIImage imageNamed:@"fc_log"];
        cell.textLabel.text = @"朋友圈";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
    if (indexPath.row == 2) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
        cell.imageView.image = [UIImage imageNamed:@"workreport_icon"];
        cell.textLabel.text = @"工作日志";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"demo"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 20.0f;
    }
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        FriendCircleViewController *vc = [[FriendCircleViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if (indexPath.row == 2) {
        WorkReportViewController *vc = [[WorkReportViewController alloc] initWithNibName:@"WorkReportViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -- private method
- (UITableViewCell *)getFuncCellWithTitle:(NSString *)title image:(UIImage *) image {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"indexCell"];
    cell.imageView.image = image;
    cell.textLabel.text = title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

@end
