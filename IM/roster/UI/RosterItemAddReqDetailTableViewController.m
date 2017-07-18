//
//  RosterItemAddReqDetailTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-23.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItemAddReqDetailTableViewController.h"
#import "RosterGroupSelectTableViewController.h"
#import "AppDelegate.h"

@interface RosterItemAddReqDetailTableViewController ()<RosterGroupSelectTableViewControllerDelegate> {
    
    __weak IBOutlet UIImageView *avatarImgView;
    __weak IBOutlet UILabel *nameLbl;
    __weak IBOutlet UILabel *detailLbl;
    __weak IBOutlet UILabel *reqmsgLbl;
    
    __weak IBOutlet UIButton *acceptBtn;
    __weak IBOutlet UIButton *rejectBtn;
    __weak IBOutlet UILabel *resultLbl;
}

@end

@implementation RosterItemAddReqDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self initStatus];
    
}

- (void) initStatus {
    if (self.req.status == RosterItemAddReqStatusACK) {
        resultLbl.hidden = NO;
        resultLbl.text = @"已同意";
        acceptBtn.hidden = YES;
        rejectBtn.hidden = YES;
    } else if (self.req.status == RosterItemAddReqStatusReject) {
        resultLbl.hidden = NO;
        resultLbl.text = @"已拒绝";
        acceptBtn.hidden = YES;
        rejectBtn.hidden = YES;
    } else if (self.req.status == RosterItemAddReqStatusRequesting) {
        resultLbl.hidden = YES;
        acceptBtn.hidden = NO;
        rejectBtn.hidden = NO;
    }
    reqmsgLbl.text = self.req.reqmsg;
    nameLbl.text = self.req.selfName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)accept:(id)sender {
    RosterGroupSelectTableViewController *grpSelVc = [[self storyboard] instantiateViewControllerWithIdentifier:@"RosterGroupSelect"];
    grpSelVc.delegate = self;
    [self.navigationController pushViewController:grpSelVc animated:YES];
}

- (IBAction)reject:(id)sender {
    [APP_DELEGATE.user.rosterMgr acceptRosterItemWithMsgid:self.req.qid groupId:@"1" name:APP_DELEGATE.user.name accept:NO];
    self.req.status = RosterItemAddReqStatusReject;
    [self initStatus];
    if ([self.delegate respondsToSelector:@selector(RosterItemAddReqDetailTableViewControllerChanged)]) {
        [self.delegate RosterItemAddReqDetailTableViewControllerChanged];
    }
}

- (void) RosterGroupSelectTableViewController:(RosterGroupSelectTableViewController *) controller didSelectedGrp:(RosterGroup *)grp {
    [APP_DELEGATE.user.rosterMgr acceptRosterItemWithMsgid:self.req.qid groupId:grp.gid name:APP_DELEGATE.user.name accept:YES];
    self.req.status = RosterItemAddReqStatusACK;
    [self initStatus];
    if ([self.delegate respondsToSelector:@selector(RosterItemAddReqDetailTableViewControllerChanged)]) {
        [self.delegate RosterItemAddReqDetailTableViewControllerChanged];
    }
}


@end
