//
//  RosterGrpMgrTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-20.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterGrpMgrTableViewController.h"
#import "RosterGrpMgrTableViewCell.h"
#import "RosterGrpMgrModel.h"
#import "AppDelegate.h"
#import "RosterGroup.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "RosterGrpMgrHeadView.h"
#import "LogLevel.h"


@interface RosterGrpMgrTableViewController () <RosterGrpMgrHeadViewDelegate, RosterGrpMgrTableViewCellDelegate, UIAlertViewDelegate>{
    
    __weak IBOutlet UIBarButtonItem *m_cmptBtnItem;
    RosterGrpMgrModel *m_model;
}

@end

@implementation RosterGrpMgrTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setEditing:YES];
    m_model = [[RosterGrpMgrModel alloc] initWithGrpList:[APP_DELEGATE.user.rosterMgr grouplist]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cmptItemTaped:(id)sender {
    if (m_model.dirty) {
        NSArray *newGrp = [m_model genGrp];
    
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [APP_DELEGATE.user.rosterMgr setRosterGrpWithKey:APP_DELEGATE.user.key iv:APP_DELEGATE.user.iv url:APP_DELEGATE.user.imurl token:APP_DELEGATE.user.token grp:newGrp completion:^(BOOL finished) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            m_model = [[RosterGrpMgrModel alloc] initWithGrpList:[APP_DELEGATE.user.rosterMgr grouplist]];
            [self.tableView reloadData];
            if (!finished) {
                [Utils alertWithTip:@"更新组失败！"];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return m_model.grpList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RosterGrpMgrTableViewCell *cell = (RosterGrpMgrTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"RosterGrpMgrCell" forIndexPath:indexPath];
    
    RosterGroup * grp = [m_model.grpList objectAtIndex:indexPath.row];
    cell.grpNameTextField.text = grp.name;
    cell.tag = indexPath.row;
    cell.delegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    RosterGrpMgrHeadView *headView = [[[NSBundle mainBundle] loadNibNamed:@"RosterGrpMgrHeadView" owner:self options:nil] objectAtIndex:0];
    headView.delegate = self;
    return headView;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        RosterGroup *grp = [m_model.grpList objectAtIndex:indexPath.row];
        if (grp.defaultGrp) {
            [Utils alertWithTip:@"默认分组不能删除！"];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            return;
        }
        
        RosterGroup *defGrp = [m_model getDefaultGroup];
        
        if (!defGrp) {
            [Utils alertWithTip:@"默认分组不存在！"];
            return;
        }
        
        if (grp.items.count == 0) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [m_model delGrpWith:grp.gid completion:^(BOOL finished) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (finished) {
                    [m_model.grpList removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                } else {
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [Utils alertWithTip:@"删除分组失败"];
                }
            }];
        } else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [m_model moveGrp:grp toGrp:defGrp completion:^(BOOL finished) {
                if (finished) {
                    [m_model delGrpWith:grp.gid completion:^(BOOL finished) {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        if (finished) {
                            [m_model.grpList removeObjectAtIndex:indexPath.row];
                            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        } else {
                            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                            [Utils alertWithTip:@"删除分组失败"];
                        }
                    }];
                } else {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [Utils alertWithTip:@"删除分组失败"];
                }
            }];

        }
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    RosterGroup* grp = [m_model.grpList objectAtIndex:fromIndexPath.row];
    [m_model.grpList removeObjectAtIndex:fromIndexPath.row];
    [m_model.grpList insertObject:grp atIndex:toIndexPath.row];
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:toIndexPath];
    cell.tag = fromIndexPath.row;
    cell = [self.tableView cellForRowAtIndexPath:fromIndexPath];
    cell.tag = toIndexPath.row;
    
    m_model.dirty = YES;
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

#pragma mark - RosterGrpMgrHeadView delegate
- (void) RosterGrpMgrHeadViewTapped:(RosterGrpMgrHeadView *) headView {
    DDLogInfo(@"RosterGrpMgrHeadView tapped!");
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"添加分组" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    }
    if (buttonIndex == 1) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSString *grpName = [alertView textFieldAtIndex:0].text;
        if (![APP_DELEGATE.user.rosterMgr addGroupWithName:grpName key:APP_DELEGATE.user.key iv:APP_DELEGATE.user.iv url:APP_DELEGATE.user.imurl token:APP_DELEGATE.user.token completion:^(BOOL finished) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (!finished) {
                [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"\"%@\"添加失败!", grpName] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            } else {
                m_model = [[RosterGrpMgrModel alloc] initWithGrpList:[APP_DELEGATE.user.rosterMgr grouplist]];
                [self.tableView reloadData];
            }
        }]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"\"%@\"添加失败!", grpName] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }
    }
}


#pragma mark - RosterGrpMgrTableViewCell delegate.
- (void)RosterGrpMgrTableViewCellTextFieldDidEnd:(RosterGrpMgrTableViewCell *)cell tag:(NSInteger)tag {
    RosterGroup *grp = [m_model.grpList objectAtIndex:tag];
    NSString *text = cell.grpNameTextField.text;
    
    if (text.length == 0) {
        cell.grpNameTextField.text = grp.name;
        return;
    }
    
    grp.name = text;
    m_model.dirty = YES;
//    if (![grp.name isEqualToString:text]) {
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        if (![APP_DELEGATE.user.rosterMgr renameGrpName:text gid:grp.gid key:APP_DELEGATE.user.key iv:APP_DELEGATE.user.iv url:APP_DELEGATE.user.imurl token:APP_DELEGATE.user.token completion:^(BOOL finished) {
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            m_model = [[RosterGrpMgrModel alloc] initWithGrpList:[APP_DELEGATE.user.rosterMgr grouplist]];
//            [self.tableView reloadData];
//        }]) {
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            [Utils alertWithTip:@"修改组名失败！"];
//        }
//    }
}

- (void)RosterGrpMgrTableViewCellTextFieldChanged:(RosterGrpMgrTableViewCell *)cell tag:(NSInteger)tag {
    RosterGroup *grp = [m_model.grpList objectAtIndex:tag];
    NSString *text = cell.grpNameTextField.text;
    grp.name = text;
    m_model.dirty = YES;
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
