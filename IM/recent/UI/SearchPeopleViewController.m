//
//  SearchPeopleViewController.m
//  IM
//
//  Created by 郭志伟 on 15/9/1.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "SearchPeopleViewController.h"
#import "SearchPeopleTableViewCell.h"
#import "AppDelegate.h"

@interface SearchPeopleViewController ()

@property(nonatomic, strong) NSArray *osItems;

@property(nonatomic, strong) NSMutableArray *filterItems;

@end

@implementation SearchPeopleViewController

- (instancetype)initWithOsItemArray:(NSArray *)osItems {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.osItems = osItems;
        self.filterItems = [[NSMutableArray alloc] initWithCapacity:128];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[SearchPeopleTableViewCell class] forCellReuseIdentifier:@"SearchPeopleTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setKey:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@", key];
    self.filterItems = [NSMutableArray arrayWithArray:[self.osItems filteredArrayUsingPredicate:predicate]];
    [self.tableView reloadData];
}

- (void)setOsitemArray:(NSArray *)items {
    self.osItems = items;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self setKey:searchString];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.osItems = USER.osMgr.items;
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filterItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchPeopleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchPeopleTableViewCell" forIndexPath:indexPath];
    OsItem *item = [self.filterItems objectAtIndex:indexPath.row];
    cell.avatarImgView.image = [USER.avatarMgr getAvatarImageByUid:item.uid];
    cell.nameLabel.text = item.name;
    cell.detailLabel.text = [USER.osMgr getOrgNameByOrgId:item.org];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(SearchPeopleViewController:didSelectPeople:)]) {
        [self.delegate SearchPeopleViewController:self didSelectPeople:[self.filterItems objectAtIndex:indexPath.row]];
    }
}

@end
