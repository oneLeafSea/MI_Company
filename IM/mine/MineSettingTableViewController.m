//
//  MineSettingTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-3-6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "MineSettingTableViewController.h"
#import "PwdChangeTableViewController.h"
#import "Appdelegate.h"
#import "LoginViewController.h"
#import "IMConf.h"

@interface MineSettingTableViewController ()

@end

@implementation MineSettingTableViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source and delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2) {
        PwdChangeTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PwdChangeTableViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if (indexPath.row == 6) {
        [APP_DELEGATE.user.session disconnect];
        [APP_DELEGATE.user reset];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"pwd"];
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [APP_DELEGATE changeRootViewController:loginVC];
    }
}
@end
