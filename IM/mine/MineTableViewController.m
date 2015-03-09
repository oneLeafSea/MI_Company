//
//  MineTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-28.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "MineTableViewController.h"
#import "AppDelegate.h"

@interface MineTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *signLbl;
@property (weak, nonatomic) IBOutlet UILabel *sexLbl;
@property (weak, nonatomic) IBOutlet UILabel *positionLbl;
@property (weak, nonatomic) IBOutlet UILabel *addressLbl;
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;
@property (weak, nonatomic) IBOutlet UILabel *telLbl;
@property (weak, nonatomic) IBOutlet UILabel *emailLbl;

@end

@implementation MineTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.avatarImgView.image = [USER.avatarMgr getAvatarImageByUid:USER.uid];
    self.signLbl.text = USER.signature;
    NSString *sex = [USER.mineDetail.data objectForKey:@"sex"];
    self.sexLbl.text = [sex isEqual:@"1"] ? @"男" : @"女";
    self.positionLbl.text = [USER.mineDetail.data objectForKey:@"position"];
    self.addressLbl.text = [USER.mineDetail.data objectForKey:@"address"];
    self.statusLbl.text = USER.session.isConnected ? @"在线" : @"离线";
    self.telLbl.text = [USER.mineDetail.data objectForKey:@"cellphone"];
    self.emailLbl.text = [USER.mineDetail.data objectForKey:@"email"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
