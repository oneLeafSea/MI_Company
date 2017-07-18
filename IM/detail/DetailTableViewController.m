//
//  DetailTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15/9/7.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "DetailTableViewController.h"
#import "AppDelegate.h"

@interface DetailTableViewController () <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *signatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *telLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UILabel *areaLabel;

@end

@implementation DetailTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameLabel.text = self.name;
    self.avatarImageView.image = [USER.avatarMgr getAvatarImageByUid:self.uid];
    RosterItem* item = [USER.rosterMgr getItemByUid:self.uid];
    self.signatureLabel.text = item.sign;
    self.sexLabel.text = nil;
    self.telLabel.text = nil;
    self.mobileLabel.text = nil;
    self.emailLabel.text = nil;
    self.jobLabel.text = nil;
    self.areaLabel.text = nil;
    [USER.detailMgr getDetailWithUid:self.uid Token:USER.token signature:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(BOOL finished, Detail *d) {
        if (finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *tmp = [d.data objectForKey:@"sex"];
                self.sexLabel.text = [tmp isEqual:@"1"] ? @"男" : @"女";
                tmp = [d.data objectForKey:@"telephone"];
                self.telLabel.text = tmp;
                tmp = [d.data objectForKey:@"cellphone"];
                self.mobileLabel.text = tmp;
                tmp = [d.data objectForKey:@"email"];
                self.emailLabel.text = tmp;
                tmp = [d.data objectForKey:@"position"];
                self.jobLabel.text = tmp;
                tmp = [d.data objectForKey:@"address"];
                self.areaLabel.text = tmp;
            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        if (self.telLabel.text.length > 0) {
            NSString *telFmt = [NSString stringWithFormat:@"tel://%@", self.telLabel.text];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telFmt]];
        }
    }
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        if (self.mobileLabel.text.length > 0) {
            NSString *telFmt = [NSString stringWithFormat:@"tel://%@", self.mobileLabel.text];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telFmt]];
        }
    }
    
    if (indexPath.section == 1 && indexPath.row == 2) {
        if (self.emailLabel.text.length > 0) {
            NSString *mailFmt = [NSString stringWithFormat:@"mailto://%@", self.emailLabel.text];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailFmt]];
        }
    }
    
    if (indexPath.section == 2 && indexPath.row == 1) {
        if (self.areaLabel.text.length > 0) {
            UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"复制" otherButtonTitles:nil];
            [as showInView:self.tableView];
        }
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.areaLabel.text;
    }
}

@end
