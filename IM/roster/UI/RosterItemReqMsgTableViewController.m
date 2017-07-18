//
//  RosterItemReqMsgTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItemReqMsgTableViewController.h"
#import "RosterItemSendReqMsgTableViewController.h"
#import "AppDelegate.h"


@interface RosterItemReqMsgTableViewController ()
@property (weak, nonatomic) IBOutlet UITextView *reqMsgTextView;

@end

@implementation RosterItemReqMsgTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reqMsgTextView.text = [NSString stringWithFormat:@"我是%@。", APP_DELEGATE.user.name];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.textLabel.textColor = [UIColor lightTextColor];
}


//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"reqMsg2SendReq"]) {
//        RosterItemSendReqMsgTableViewController *vc = segue.destinationViewController;
//        vc.reqMsg = self.reqMsgTextView.text;
//        vc.itemInfo = self.itemInfo;
//    }
//}
- (IBAction)next:(id)sender {
    RosterItemSendReqMsgTableViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"RosterItemSendReqMsgTableViewController"];
    vc.reqMsg = self.reqMsgTextView.text;
    vc.itemInfo = self.itemInfo;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
