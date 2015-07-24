//
//  MineSettingCommonTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-3-20.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "MineSettingCommonTableViewController.h"
#import "RTSystemSoundPlayer.h"

@interface MineSettingCommonTableViewController() {
    
    __weak IBOutlet UISwitch *soundSwitch;
    __weak IBOutlet UISwitch *vibrateSwitch;
}
@end

@implementation MineSettingCommonTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    soundSwitch.on = [RTSystemSoundPlayer sharedPlayer].on;
    vibrateSwitch.on = [RTSystemSoundPlayer sharedPlayer].vibrateOn;
    
}


- (IBAction)SoundSwitchTapped:(UISwitch *)sender {
    [[RTSystemSoundPlayer sharedPlayer] toggleSoundPlayerOn:sender.on];
}

- (IBAction)VibrateSwitchTapped:(UISwitch *)sender {
    [[RTSystemSoundPlayer sharedPlayer] toggleSoundPlayerVibrateOn:sender.on];
}

@end
