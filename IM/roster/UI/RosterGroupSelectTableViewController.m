//
//  RosterGroupSelectTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-13.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterGroupSelectTableViewController.h"
#import "AppDelegate.h"
#import "RosterGroup.h"
#import "MBProgressHUD.h"


@interface RosterGroupSelectTableViewController () <UIAlertViewDelegate> {
    NSArray *m_grouplist;
}

@end

@implementation RosterGroupSelectTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    m_grouplist = [APP_DELEGATE.user.rosterMgr grouplist];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    
    return m_grouplist.count + 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0 || indexPath.row == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"separatorCell" forIndexPath:indexPath];
        return cell;
    }
    
    if (indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addGroupCell" forIndexPath:indexPath];
        return cell;
    }
    
    NSInteger grpIdx = indexPath.row - 3;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupItemCell" forIndexPath:indexPath];
    if (_selectedIndex == grpIdx) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    RosterGroup *grp = [m_grouplist objectAtIndex:grpIdx];
    cell.textLabel.text = grp.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0 || indexPath.row == 2) {
        return;
    }
    
    if (indexPath.row == 1) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"添加分组" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        av.alertViewStyle = UIAlertViewStylePlainTextInput;
        [av show];
        return;
    }
    
    _selectedIndex = indexPath.row - 3;
    [self.tableView reloadData];
    if ([self.delegate respondsToSelector:@selector(RosterGroupSelectTableViewController:didSelectedGrp:)]) {
        [self.delegate RosterGroupSelectTableViewController:self didSelectedGrp:[m_grouplist objectAtIndex:_selectedIndex]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 2) {
        return 20.0f;
    }
    return 44.0f;
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    }
    
    if (buttonIndex == 1) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSString *grpName = [alertView textFieldAtIndex:0].text;
        if (![APP_DELEGATE.user.rosterMgr addGroupWithName:grpName key:APP_DELEGATE.user.key iv:APP_DELEGATE.user.iv url:[APP_DELEGATE.user imurl] token:APP_DELEGATE.user.token completion:^(BOOL finished) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (!finished) {
                [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"\"%@\"添加失败!", grpName] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            } else {
                m_grouplist = [APP_DELEGATE.user.rosterMgr grouplist];
                _selectedIndex = [APP_DELEGATE.user.rosterMgr indexOfGrpWithName:grpName];
                [self.tableView reloadData];
                if ([self.delegate respondsToSelector:@selector(RosterGroupSelectTableViewController:didSelectedGrp:)]) {
                    [self.delegate RosterGroupSelectTableViewController:self didSelectedGrp:[m_grouplist objectAtIndex:_selectedIndex]];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        }]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"\"%@\"添加失败!", grpName] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
