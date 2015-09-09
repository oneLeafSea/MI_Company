//
//  AboutTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15/9/7.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "AboutTableViewController.h"
#import "AppDelegate.h"

@interface AboutTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation AboutTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text = [NSString stringWithFormat:@"版本号：%@", [APP_DELEGATE appVersion]];
    self.tableView.estimatedRowHeight = 60.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 1 && indexPath.row == 0) {
//        [self.instructionLabel sizeToFit];
//        CGFloat h = self.instructionLabel.frame.size.height + 16;
//        return h;
//    }
//    return 60.0;
//}

@end
