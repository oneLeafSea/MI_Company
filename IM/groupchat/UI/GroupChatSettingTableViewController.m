//
//  GroupChatSettingTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-3-3.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatSettingTableViewController.h"
#import "GroupChatItemListViewController.h"

@interface GroupChatSettingTableViewController ()

@end

@implementation GroupChatSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
