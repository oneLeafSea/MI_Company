//
//  MultiCallViewController.m
//  IM
//
//  Created by 郭志伟 on 15/5/6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "MultiCallViewController.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "AvatarContainerView.h"
#import "Appdelegate.h"
#import "AvatarContainerViewItem.h"
#import "MultiCallClient.h"
#import "NSUUID+StringUUID.h"
#import "Loglevel.h"
#import "MultiSelectViewController.h"
#import "WebRtcNotifyMsg.h"
#import "Utils.h"

@interface MultiCallViewController () <MultiCallClientDelegate, MultiSelectViewControllerDelegate> {
    NSTimer  *_timer;
    NSUInteger _timeSticks;
}
@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *hangup;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) AvatarContainerView *avatarContainerView;
@property (weak, nonatomic) IBOutlet UIButton *addFriend;

@property(strong, nonatomic) MultiCallClient *cli;

@end

@implementation MultiCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}


- (void)setup {
    _avatarContainerView = [AvatarContainerView instanceFromNib];
    _avatarContainerView.frame = CGRectMake(0, 132, self.view.frame.size.width, 60);
    [self.view addSubview:_avatarContainerView];
    self.cli = [[MultiCallClient alloc] initWithDelegate:self roomServer:[NSURL URLWithString:USER.rssUrl] iceUrl:USER.iceUrl token:USER.token key:USER.key iv:USER.iv uid:USER.uid invited:self.invited];
    if (self.invited) {
        [self.cli joinRoomId:self.roomId];
    } else {
        self.roomId = [NSUUID uuid];
        [self.cli createRoomId:self.roomId session:USER.session talkingUids:self.talkingUids];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self genAvatarContainerViewData];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
}

- (void)handleTimer {
    _timeSticks++;
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", _timeSticks / 60, _timeSticks % 60];
}

- (void)genAvatarContainerViewData {
    [self.talkingUids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AvatarContainerViewItem *aci = [self genAvatarContainerViewItemByUid:obj];
        [_avatarContainerView addAvatarItem:aci];
    }];
}

- (AvatarContainerViewItem *)genAvatarContainerViewItemByUid:(NSString *)uid {
    RosterItem *ri = [USER.rosterMgr getItemByUid:uid];
    NSString *imgName = [NSString stringWithFormat:@"%@.jpg", ri.uid];
    NSString *imgStr = [USER.avatarPath stringByAppendingPathComponent:imgName];
    AvatarContainerViewItem *aci = [[AvatarContainerViewItem alloc] initWithUid:ri.uid name:ri.name imgStrUrl:imgStr];
    return aci;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)speakerTapped:(id)sender {
    static BOOL speaker = NO;
    if (!speaker) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        speaker = YES;
    } else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                               error:nil];
        speaker = NO;
    }
    [self.speakerBtn setImage:[UIImage imageNamed:speaker ? @"webrtc_speaker_sel" : @"webrtc_speaker"] forState:UIControlStateNormal];
}


- (IBAction)hangupBtnTapped:(id)sender {
    [self close];
}

- (IBAction)muteBtnTapped:(id)sender {
    [self.cli mute];
}

- (IBAction)addFriendBtnTapped:(id)sender {
    MultiSelectViewController *vc = [[MultiSelectViewController alloc]init];
    NSMutableArray *multiSelItems = [[NSMutableArray alloc] init];
    [[USER.rosterMgr allRosterItems] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RosterItem *ri = obj;
        NSString *uid = ri.uid;
        if ([_avatarContainerView isExistUid:uid]) {
            return;
        }
        if ([USER.presenceMgr isOnline:uid]) {
            MultiSelectItem *mi = [[MultiSelectItem alloc] init];
            mi.uid = uid;
            mi.name = ri.name;
            mi.imageURL = [NSURL fileURLWithPath:[USER.avatarMgr.avatarPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", ri.uid]]];
            [multiSelItems addObject:mi];
        }
    }];
    vc.items = multiSelItems;
    vc.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    navController.navigationBar.barTintColor = [UIColor colorWithRed:75 / 255.0f green:193 / 255.0f blue:210 / 255.0f alpha:1.0f];
    navController.navigationBar.tintColor = [UIColor whiteColor];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],NSForegroundColorAttributeName,
                                               nil];
    navController.navigationBar.titleTextAttributes = navbarTitleTextAttributes;
    [self presentViewController:navController animated:YES completion:nil];;
    
}


#pragma mark -
- (void)MultiCallClient:(MultiCallClient *)cli didLeaveWithUid:(NSString *)uid deivce:(NSString *)device {
    [_avatarContainerView removeAvatarItemByUid:uid];
}

- (void)MultiCallClient:(MultiCallClient *)cli didJoinedWithUid:(NSString *)uid deivce:(NSString *)device {
    [_avatarContainerView addAvatarItem:[self genAvatarContainerViewItemByUid:uid]];
}

- (void)MultiCallClient:(MultiCallClient *)cli didChangeState:(MultiCallClientState)state {
    switch (state) {
        case kMultiCallClientStateDisconnected:
        case kMultiCallClientStateTimeout:
            [self close];
            break;
        default:
            break;
    }
}

- (void)close {
    [_timer invalidate];
    [self.cli disconnect];
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [USER.webRtcMgr setbusy:NO];
                             }];
}

- (void)MultiCallClient:(MultiCallClient *)cli recviveRemoteAudioFromUid:(NSString *)uid {
    [_avatarContainerView setAvatarItemUid:uid Ready:YES];
    [_avatarContainerView refresh];
}

- (void)MultiSelectViewController:(MultiSelectViewController *)controller didConfirmWithSelectedItems:(NSArray *)selectedItems {
    [selectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MultiSelectItem *item = obj;
        WebRtcNotifyMsg *notifyMsg = [[WebRtcNotifyMsg alloc] initWithFrom:USER.uid to:item.uid rid:_roomId];
        notifyMsg.contentType = @"mulitivoice";
        [USER.session post:notifyMsg];
    }];
}

@end
