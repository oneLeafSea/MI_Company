//
//  RosterItemSearchResultTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItemSearchResultTableViewController.h"
#import "RosterItemSearchResultItemTableViewCell.h"
#import "RosterItemReqMsgTableViewController.h"
#import "AppDelegate.h"
#import "Utils.h"

@interface RosterItemSearchResultTableViewController ()

@end

@implementation RosterItemSearchResultTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.searchResult.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RosterItemSearchResultItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RosterItemSearchResultItem" forIndexPath:indexPath];
    NSDictionary *dict = [self.searchResult objectAtIndex:indexPath.row];
    cell.nameAndIdLabel.text = [NSString stringWithFormat:@"%@(%@)", [dict objectForKey:@"name"], [dict objectForKey:@"uname"]];
    cell.orgLabel.text = [dict objectForKey:@"jgmc"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *itemInfo = [self.searchResult objectAtIndex:indexPath.row];
    if ([APP_DELEGATE.user.rosterMgr exsitsItemByUid:[itemInfo objectForKey:@"uname"]]) {
        NSString *name = [itemInfo objectForKey:@"name"];
        [Utils alertWithTip:[NSString stringWithFormat:@"%@已经是你的好友！", name]];
        return;
    }
    if ([APP_DELEGATE.user.uid isEqualToString:[itemInfo objectForKey:@"uname"]]) {
        [Utils alertWithTip:@"不能添加自己为好友！"];
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RosterItemReqMsgTableViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"RosterItemReqMsgTableViewController"];
    vc.itemInfo = [self.searchResult objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
