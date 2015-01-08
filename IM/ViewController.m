//
//  ViewController.m
//  IM
//
//  Created by guozw on 14/11/24.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "ViewController.h"
#import "LoginProcedures.h"
#import "session.h"
#import "rosterMgr.h"
#import "User.h"
#import "AppDelegate.h"
#import "RosterNotification.h"
#import "IMAck.h"

@interface ViewController () <LoginProceduresDelegate> {
    LoginProcedures *m_lp;
    NSString *uid;
    NSString *name;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
#if (TARGET_IPHONE_SIMULATOR)
    uid = @"gzw";
    name = @"郭志伟";
#else
    uid = @"wjw";
    name = @"王家万";
#endif

}

- (void)viewWillAppear:(BOOL)animated {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRosterItemAddReq:) name:kRosterItemAddRequest object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRosterItemAddRequest object:nil];
}

- (IBAction)sendRIAReq:(id)sender {
    User *user = APP_DELEGATE.user;
    [user.rosterMgr addItemWithTo:uid groupId:@"122" reqmsg:@"hello" selfName:name];
}

- (IBAction)login:(id)sender {
    if (APP_DELEGATE.user) {
        [APP_DELEGATE.user reset];
    }
    m_lp = [[LoginProcedures alloc]init];
    m_lp.delegate = self;
#if (TARGET_IPHONE_SIMULATOR)
//    [m_lp loginWithUserId:@"gzw" pwd:@"8" timeout:30];
    [m_lp loginWithUserId:@"wjw" pwd:@"12345" timeout:30];
#else
    [m_lp loginWithUserId:@"gzw" pwd:@"8" timeout:30];
#endif
}


- (IBAction)delRosterItem:(id)sender {
    User *user = APP_DELEGATE.user;
    [user.rosterMgr delItemWithUid:uid];
}

- (IBAction)getRoster:(id)sender {
    User *u = APP_DELEGATE.user;
    [u.rosterMgr getRosterWithKey:u.key iv:u.iv url:@"http://10.22.1.110:8040/" token:u.token];

}

//- (void)handleRosterItemAddReq:(NSNotification *)notification {
//    RosterItemAddRequest *req = (RosterItemAddRequest *)notification.object;
//    
//    IMAck *ack = [[IMAck alloc] initWithMsgid:req.qid ackType:req.type err:nil];
//    [m_sess post:ack];
//    
//    RosterItemAddResult *result = [[RosterItemAddResult alloc] initWithFrom:req.to to:req.from gid:req.gid];
//    result.qid = req.qid;
//    result.msg = [req.msg copy];
//    result.accept = YES;
//    result.respGid = @"99899";
//    result.respName = @"王家万";
//    [m_sess post:result];
//}
- (IBAction)setRoster:(id)sender {
    User *u = APP_DELEGATE.user;
    [u.rosterMgr setRosterGrpWithKey:u.key iv:u.iv url:@"http://10.22.1.110:8040/" token:u.token];
}
- (IBAction)setSign:(id)sender {
    User *u = APP_DELEGATE.user;
    [u.rosterMgr setRosterSignatureWithKey:u.key iv:u.iv url:@"http://10.22.1.110:8040/" token:u.token];
}

- (IBAction)setAvatar:(id)sender {
    User *u = APP_DELEGATE.user;
    [u.rosterMgr setRosterAvatarWithKey:u.key iv:u.iv url:@"http://10.22.1.110:8040/" token:u.token];
}
- (IBAction)setRosterItemName:(id)sender {
    User *u = APP_DELEGATE.user;
    [u.rosterMgr setRosterItemNameWithKey:u.key iv:u.iv url:@"http://10.22.1.110:8040/" token:u.token];
}
- (IBAction)setRosterItemGid:(id)sender {
    User *u = APP_DELEGATE.user;
    [u.rosterMgr setRosterItemGidWithKey:u.key iv:u.iv url:@"http://10.22.1.110:8040/" token:u.token];
}

- (IBAction)acceptAddRosterItem:(id)sender {

//    [APP_DELEGATE.user.rosterMgr acceptRosterItemId:uid grouId:@"122" name:name accept:YES];
}

- (IBAction)rejectAddRosteritem:(id)sender {
//    [APP_DELEGATE.user.rosterMgr acceptRosterItemId:uid grouId:@"122" name:name accept:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loginProceduresWaitingSvrTime:(LoginProcedures *)proc {
    
}

- (void)loginProcedures:(LoginProcedures *)proc login:(BOOL)suc {
    
}

- (void)loginProcedures:(LoginProcedures *)proc recvPush:(BOOL)suc {
    
}

- (void)loginProceduresConnectFail:(LoginProcedures *)proc timeout:(BOOL)timeout error:(NSError *)error {
    
}


@end
