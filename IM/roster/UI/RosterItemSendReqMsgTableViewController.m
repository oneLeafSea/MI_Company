//
//  RosterItemSendReqMsgTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-13.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItemSendReqMsgTableViewController.h"
#import "RosterGroupSelectTableViewController.h"
#import "LogLevel.h"
#import "AppDelegate.h"
#import "Utils.h"

@interface RosterItemSendReqMsgTableViewController () <RosterGroupSelectTableViewControllerDelegate> {
    RosterGroup *m_selectedGrp;
}

@end

@implementation RosterItemSendReqMsgTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.nameIdLabel.text = [NSString stringWithFormat:@"%@(%@)", [self.itemInfo objectForKey:@"name"], [self.itemInfo objectForKey:@"uname"]];
    self.reqMsgLabel.text = self.reqMsg;
    m_selectedGrp = [[APP_DELEGATE.user.rosterMgr grouplist] objectAtIndex:0];
    self.grpLabel.text = m_selectedGrp.name;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMsg:(id)sender {
    if (![APP_DELEGATE.user.rosterMgr addItemWithTo:[self.itemInfo objectForKey:@"uname"] groupId:m_selectedGrp.gid reqmsg:self.reqMsg selfName:APP_DELEGATE.user.name]) {
        [Utils alertWithTip:@"发送请求发生错误！"];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    DDLogInfo(@"%d , %d", indexPath.section, indexPath.row);
    if (indexPath.section == 1 && indexPath.row == 0) {
        RosterGroupSelectTableViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"RosterGroupSelect"];
        vc.delegate = self;
        vc.selectedIndex = [APP_DELEGATE.user.rosterMgr indexOfGrpWithName:m_selectedGrp.name];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -- RosterGroupSelectTableViewControllerDelegate
- (void) RosterGroupSelectTableViewController:(RosterGroupSelectTableViewController *) controller didSelectedGrp:(RosterGroup *)grp {
    m_selectedGrp = grp;
    self.grpLabel.text = grp.name;
    
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
