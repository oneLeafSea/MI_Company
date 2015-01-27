//
//  RosterItemAddReqTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-22.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItemAddReqTableViewController.h"
#import "RosterItemAddReqModel.h"
#import "AppDelegate.h"
#import "RosterItemAddReqTableViewCell.h"
#import "RosterItemAddRequest.h"
#import "RosterItemAddReqDetailTableViewController.h"
#import "RosterNotification.h"
#import "RosterGroupSelectTableViewController.h"


@interface RosterItemAddReqTableViewController ()<RosterItemAddReqTableViewCellDelegate, RosterGroupSelectTableViewControllerDelegate, RosterItemAddReqDetailTableViewControllerDelegate> {
    RosterItemAddReqModel *m_model;
    RosterItemAddRequest *m_selReq;
}

@end

@implementation RosterItemAddReqTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    m_model = [[RosterItemAddReqModel alloc] initWithReqList:[APP_DELEGATE.user.rosterMgr getAllRosterItemReqButMe:APP_DELEGATE.user.uid]];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRosterItemAddReqControllerDismiss object:nil];
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
    return m_model.reqList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RosterItemAddReqTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RosterItemAddReqTableViewCell" forIndexPath:indexPath];
    
    RosterItemAddRequest *req = [m_model.reqList objectAtIndex:indexPath.row];
    cell.nameLbl.text = req.selfName;
    cell.reqmsgLbl.text = req.reqmsg;
    cell.tag = indexPath.row;
    if (req.status == RosterItemAddReqStatusACK) {
        cell.acceptBtn.hidden = YES;
        cell.acceptLbl.text = @"已同意";
        cell.acceptLbl.hidden = NO;
    }
    
    if (req.status == RosterItemAddReqStatusRequesting) {
        cell.acceptBtn.hidden = NO;
        cell.acceptLbl.hidden = YES;
    }
    
    if (req.status == RosterItemAddReqStatusReject) {
        cell.acceptBtn.hidden = YES;
        cell.acceptLbl.text = @"已拒绝";
        cell.acceptLbl.hidden = NO;
    }
    cell.delegate = self;
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (IBAction)delAll:(id)sender {
    [APP_DELEGATE.user.rosterMgr delAllRosterItemReq];
    m_model = [[RosterItemAddReqModel alloc] initWithReqList:[APP_DELEGATE.user.rosterMgr getAllRosterItemReqButMe:APP_DELEGATE.user.uid]];
    [self.tableView reloadData];
}


- (void)RosterItemAddReqTableViewCellAcceptBtnTapped:(RosterItemAddReqTableViewCell *)cell {
    NSInteger cellIndex = cell.tag;
    m_selReq = [m_model.reqList objectAtIndex:cellIndex];
    RosterGroupSelectTableViewController *grpSelVc = [[self storyboard] instantiateViewControllerWithIdentifier:@"RosterGroupSelect"];
    grpSelVc.delegate = self;
    [self.navigationController pushViewController:grpSelVc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RosterItemAddReqDetailTableViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"RosterItemAddReqDetailTableViewController"];
    vc.req = [m_model.reqList objectAtIndex:indexPath.row];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) RosterGroupSelectTableViewController:(RosterGroupSelectTableViewController *) controller didSelectedGrp:(RosterGroup *)grp {
    [APP_DELEGATE.user.rosterMgr acceptRosterItemWithMsgid:m_selReq.qid groupId:grp.gid name:APP_DELEGATE.user.name accept:YES];
    m_model = [[RosterItemAddReqModel alloc] initWithReqList:[APP_DELEGATE.user.rosterMgr getAllRosterItemReqButMe:APP_DELEGATE.user.uid]];
    [self.tableView reloadData];
}

- (void)RosterItemAddReqDetailTableViewControllerChanged {
    m_model = [[RosterItemAddReqModel alloc] initWithReqList:[APP_DELEGATE.user.rosterMgr getAllRosterItemReqButMe:APP_DELEGATE.user.uid]];
    [self.tableView reloadData];
}
@end
