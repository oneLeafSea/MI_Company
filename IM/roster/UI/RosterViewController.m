//
//  RosterViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterViewController.h"
#import "RosterItermTableViewCell.h"
#import "RosterSectionHeaderView.h"
#import "LogLevel.h"
#import "AppDelegate.h"
#import "RosterGroup.h"
#import "RosterSection.h"
#import "RosterItemSearchTableViewController.h"
#import "RosterNotification.h"
#import "ChatViewController.h"

@interface RosterViewController () <RosterSectionHeaderViewDelegate> {
    NSMutableArray *m_Sections;
    NSArray *m_groups;
    __weak IBOutlet UITableView *m_table;
}

@end

@implementation RosterViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self initData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRosterGrpChanged) name:kRosterChanged object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)initData {
    m_groups = [APP_DELEGATE.user.rosterMgr grouplist];
    m_Sections = [[NSMutableArray alloc] init];
    for (int n = 0; n < m_groups.count; n++) {
        RosterSection *section = [[RosterSection alloc] init];
        [m_Sections addObject:section];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return m_groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RosterSection *sect = [m_Sections objectAtIndex:section];
    if (!sect.expand) {
        return 0;
    }
    RosterGroup *g = [m_groups objectAtIndex:(NSUInteger)section];
    return g.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    RosterSectionHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"RosterSectionHeaderView" owner:self options:nil] objectAtIndex:0];
    RosterGroup *g = [m_groups objectAtIndex:(NSUInteger)section];
    headerView.groupNameLabel.text = g.name;
    headerView.tag = section;
    RosterSection *sect =[m_Sections objectAtIndex:section];
    headerView.arrowImagView.image = [UIImage imageNamed:sect.expand ? @"arrow_down":@"arrow_right"];
    headerView.delegate = self;
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"rosterItermCell";
    RosterItermTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    RosterGroup *g = [m_groups objectAtIndex:indexPath.section];
    RosterItem* item = [g.items objectAtIndex:indexPath.row];
    cell.nameLabel.text = item.name;
    cell.signatureLabel.text = item.sign;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    RosterGroup *g = [m_groups objectAtIndex:indexPath.section];
    RosterItem* item = [g.items objectAtIndex:indexPath.row];
    vc.talkingId = item.uid;
    vc.talkingname = item.name;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)add:(id)sender {
    RosterItemSearchTableViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"RosterItemSearchResultTableViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}

#pragma mark - RosterSectionHeaderViewDelegate
- (void)RosterSectionHeaderViewTapped:(RosterSectionHeaderView *)headerView tag:(NSInteger) tag {
    RosterSection *sect = [m_Sections objectAtIndex:tag];
    sect.expand = !sect.expand;
    [m_table reloadSections:[NSIndexSet indexSetWithIndex:tag] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)RosterSectionHeaderViewGrpMgrTapped:(RosterSectionHeaderView *)headerView tag:(NSInteger)tag {
    [self performSegueWithIdentifier:@"roster2grpmgr" sender:self];
}

#pragma mark - Roster Notification handler
- (void) handleRosterGrpChanged {
    m_groups = [APP_DELEGATE.user.rosterMgr grouplist];
    [self initData];
    [m_table reloadData];
}


@end
