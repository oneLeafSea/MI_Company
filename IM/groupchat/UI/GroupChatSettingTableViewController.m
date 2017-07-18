//
//  GroupChatSettingTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-3-3.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatSettingTableViewController.h"
#import "GroupChatItemListViewController.h"
//#import "ChatHistoryMessageViewController.h"

@interface GroupChatSettingTableViewController ()

@end

@implementation GroupChatSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        GroupChatItemListViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"GroupChatItemListViewController"];
        vc.grp = self.grp;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
@end
