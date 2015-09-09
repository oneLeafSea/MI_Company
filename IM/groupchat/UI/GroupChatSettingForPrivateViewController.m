//
//  GroupChatSettingForPrivateViewController.m
//  IM
//
//  Created by 郭志伟 on 15/9/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatSettingForPrivateViewController.h"

@implementation GroupChatSettingForPrivateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"群设置";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gcsfpCell"];
    cell.textLabel.text = @"测试";
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}





@end
