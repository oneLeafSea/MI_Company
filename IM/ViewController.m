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
#import "RTFileView.h"
#import "UIColor+RTMessages.h"

static NSString *ip = @"http://10.22.1.112:8040/" ;

@interface ViewController () {
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
//case 1:
//    cell.imageView.image = [UIImage imageNamed:@"chatmsg_pic"];
//    cell.textLabel.text = @"照片";
//    break;
//case 2:
//    cell.imageView.image = [UIImage imageNamed:@"chatmsg_video"];
//    cell.textLabel.text = @"视频";
//    break;
//case 3:
//    cell.imageView.image = [UIImage imageNamed:@"chatmsg_folder"];
//    cell.textLabel.text = @"文件";
//    break;
//case 4:
//    cell.imageView.image = [UIImage imageNamed:@"chatmsg_phone"];
//    cell.textLabel.text = @"通话";
//    break;
//default:
//    break;
//    NSMutableArray *arr = [[NSMutableArray alloc] init];
//    ChatMessageMorePanelItemMode *item = [[ChatMessageMorePanelItemMode alloc] initWithTitle:@"照片" imageName:@"chatmsg_pic" target:self selector:@selector(handlePanel)];
//    [arr addObject:item];
//    item = [[ChatMessageMorePanelItemMode alloc] initWithTitle:@"视频" imageName:@"chatmsg_video" target:self selector:@selector(handlePanel)];
//    [arr addObject:item];
//    item = [[ChatMessageMorePanelItemMode alloc] initWithTitle:@"文件" imageName:@"chatmsg_folder" target:self selector:@selector(handlePanel)];
//    [arr addObject:item];
//    
//    panelController = [[ChatMessageMorePanelViewController alloc] initWithPanelItems:arr];
//    [self.view addSubview:panelController.view];
//    panelController.view.frame = CGRectMake(0, self.view.frame.size.height - 270, self.view.frame.size.width, 270);
    
    RTFileView *fileView = [[RTFileView alloc] initWithFrame:CGRectMake(0, 300, 210, 80) isOutgoing:NO];
    fileView.fileNameLabel.text = @"许洋洋.avi";
    fileView.fileSzLabel.text = @"1.5M";
    fileView.statusLabel.text = @"未下载";
    
    [self.view addSubview:fileView];

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
//    m_lp.delegate = self;
#if (TARGET_IPHONE_SIMULATOR)
    [m_lp loginWithUserId:@"gzw" pwd:@"8" timeout:30];
//    [m_lp loginWithUserId:@"wjw" pwd:@"12345" timeout:30];
#else
    [m_lp loginWithUserId:@"gzw" pwd:@"8" timeout:30];
#endif
}

- (void)handlePanel {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


- (IBAction)delRosterItem:(id)sender {
    User *user = APP_DELEGATE.user;
    [user.rosterMgr delItemWithUid:uid];
}

- (IBAction)getRoster:(id)sender {
    User *u = APP_DELEGATE.user;
    [u.rosterMgr getRosterWithKey:u.key iv:u.iv url:ip token:u.token completion:nil];

}
- (IBAction)sendMsg:(id)sender {
//    [APP_DELEGATE.user.msgMgr sendTextMesage:@"hello" msgType:ChatMessageTypeNormal to:@"gzw" completion:nil];
//    [APP_DELEGATE.user.msgMgr sendTextMesage:@"hello" msgType:ChatMessageTypeNormal to:@"xyy" completion:^(BOOL finished) {
//        NSLog(@"finished");
//    }];
}
- (IBAction)parseGroup:(id)sender {
//    User *u = APP_DELEGATE.user;
//    [u.rosterMgr grouplist];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *mainController = [storyboard instantiateViewControllerWithIdentifier:@"mainController"];
    [UIView beginAnimations:nil context:NULL];
    [self presentViewController:mainController animated:YES completion:nil];
    
    [UIView setAnimationDuration:0.8];
    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationTransition:UIViewAnimationCurveEaseInOut forView:self.view cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
    
//    [UIView beginAnimations:@"View Flip" context:nil];
//    [UIView setAnimationDuration:0.80];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    
//    [UIView setAnimationTransition:
//     UIViewAnimationTransitionFlipFromRight
//                           forView:self.navigationController.view cache:NO];
//    
//    
//    [self presentViewController:mainController animated:YES completion:nil];
//    [UIView commitAnimations];
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
    [u.rosterMgr setRosterGrpWithKey:u.key iv:u.iv url:ip token:u.token grp:nil completion:nil];
}
- (IBAction)setSign:(id)sender {
    User *u = APP_DELEGATE.user;
    [u.rosterMgr setRosterItemSignatureWithKey:u.key iv:u.iv url:ip token:u.token];
}

- (IBAction)setAvatar:(id)sender {
    User *u = APP_DELEGATE.user;
    [u.rosterMgr setRosterItemAvatarWithKey:u.key iv:u.iv url:ip token:u.token];
}
- (IBAction)setRosterItemName:(id)sender {
    User *u = APP_DELEGATE.user;
    [u.rosterMgr setRosterItemNameWithKey:u.key iv:u.iv url:ip token:u.token];
}
- (IBAction)setRosterItemGid:(id)sender {
    User *u = APP_DELEGATE.user;
    [u.rosterMgr setRosterItemGidWithKey:u.key iv:u.iv url:ip token:u.token];
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
