//
//  SearchPeopleViewController.h
//  IM
//
//  Created by 郭志伟 on 15/9/1.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ositem.h"

@protocol SearchPeopleViewControllerDelegate;

@interface SearchPeopleViewController : UITableViewController <UISearchBarDelegate, UISearchResultsUpdating>

- (instancetype)initWithOsItemArray:(NSArray *)osItems;

- (void)setKey:(NSString *)key;

- (void)setOsitemArray:(NSArray *)items;

@property(weak) id<SearchPeopleViewControllerDelegate> delegate;

@end


@protocol SearchPeopleViewControllerDelegate <NSObject>

- (void)SearchPeopleViewController:(SearchPeopleViewController *)vc didSelectPeople:(OsItem *)item;

@end