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

@interface ViewController () <LoginProceduresDelegate, RosterMgrDelgate> {
    LoginProcedures *m_lp;
    Session         *m_sess;
    RosterMgr       *m_rosterMgr;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    



}

- (IBAction)sendRIAReq:(id)sender {
//    [m_rosterMgr addItem:@"wjw" groupId:@"122" reqmsg:@"hello"];
    [m_rosterMgr addItemWithTo:@"wjw" groupId:@"122" reqmsg:@"hello" session:m_sess];
}

- (IBAction)login:(id)sender {
    m_lp = [[LoginProcedures alloc]init];
    m_lp.delegate = self;
//    if (m_sess) {
//        [m_sess disconnect];
//    }
    m_sess = [[Session alloc]init];
    [m_lp loginWithSession:m_sess UserId:@"gzw" pwd:@"8" timeout:30];
}

- (IBAction)acceptAddRosterItem:(id)sender {
    [m_rosterMgr acceptRosterItemId:@"wjw" grouId:@"122" accept:YES session:m_sess];
}

- (IBAction)rejectAddRosteritem:(id)sender {
    [m_rosterMgr acceptRosterItemId:@"wjw" grouId:@"122" accept:NO session:m_sess];
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
    m_rosterMgr = [[RosterMgr alloc] initWithSelfId:@"gzw" dbq:nil];
}

- (void)loginProceduresConnectFail:(LoginProcedures *)proc timeout:(BOOL)timeout error:(NSError *)error {
    
}


- (void)rosterMgr:(RosterMgr *)rm item:(RosterItem *)ri addItem:(BOOL)suc err:(NSError *)err {
    
}

- (void)rosterMgr:(RosterMgr *)rm item:(RosterItem *)ri delItem:(BOOL)suc err:(NSError *)err {
    
}

- (void)rosterMgr:(RosterMgr *)rm roster:(Roster *)roster get:(BOOL)suc err:(NSError *)err {
    
}

@end
