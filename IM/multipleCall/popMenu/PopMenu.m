//
//  PopMenu.m
//  IM
//
//  Created by 郭志伟 on 15/5/4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "PopMenu.h"

#import "PopMenuItemView.h"

@interface PopMenu () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImageView *menuContainerView;

@property (nonatomic, strong) UITableView *menuTableView;
@property (nonatomic, strong) NSMutableArray *menus;

@property (nonatomic, weak) UIView *currentSuperView;
@property (nonatomic, assign) CGPoint targetPoint;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation PopMenu


- (void)showMenuAtPoint:(CGPoint)point {
    [self showMenuOnView:[[UIApplication sharedApplication] keyWindow] atPoint:point];
}

- (void)showMenuOnView:(UIView *)view atPoint:(CGPoint)point {
    self.currentSuperView = view;
    self.targetPoint = point;
    [self showMenu];
}

#pragma mark - animation

- (void)showMenu {
    if (![self.currentSuperView.subviews containsObject:self]) {
        self.alpha = 0.0;
        [self.currentSuperView addSubview:self];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [self dissMissPopMenuAnimatedOnMenuSelected:NO];
    }
}

- (void)dissMissPopMenuAnimatedOnMenuSelected:(BOOL)selected {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (selected) {
            if (self.popMenuDidDismissCompled) {
                self.popMenuDidDismissCompled(self.indexPath.row, self.menus[self.indexPath.row]);
            }
        }
        [super removeFromSuperview];
    }];
}

#pragma mark - Propertys

- (UIImageView *)menuContainerView {
    if (!_menuContainerView) {
        _menuContainerView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"roster_popmenu"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 10, 30, 50) resizingMode:UIImageResizingModeTile]];
        _menuContainerView.userInteractionEnabled = YES;
        _menuContainerView.frame = CGRectMake(CGRectGetWidth(self.bounds) - kMenuTableViewWidth - 6, 65, kMenuTableViewWidth, self.menus.count * (kMenuItemViewHeight + kSeparatorLineImageViewHeight) + kMenuTableViewSapcing);
        
        [_menuContainerView addSubview:self.menuTableView];
    }
    return _menuContainerView;
}

- (UITableView *)menuTableView {
    if (!_menuTableView) {
        _menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kMenuTableViewSapcing, CGRectGetWidth(_menuContainerView.bounds), CGRectGetHeight(_menuContainerView.bounds) - kMenuTableViewSapcing) style:UITableViewStylePlain];
        _menuTableView.backgroundColor = [UIColor clearColor];
        _menuTableView.separatorColor = [UIColor clearColor];
        _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _menuTableView.delegate = self;
        _menuTableView.dataSource = self;
        _menuTableView.rowHeight = kMenuItemViewHeight;
        _menuTableView.scrollEnabled = NO;
    }
    return _menuTableView;
}

#pragma mark - Life Cycle

- (void)setup {
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.menuContainerView];
}

- (id)initWithMenus:(NSArray *)menus {
    self = [super init];
    if (self) {
        self.menus = [[NSMutableArray alloc] initWithArray:menus];
        [self setup];
    }
    return self;
}

- (instancetype)initWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION {
    self = [super init];
    if (self) {
        NSMutableArray *menuItems = [[NSMutableArray alloc] init];
        PopMenuItem *eachItem;
        va_list argumentList;
        if (firstObj) {
            [menuItems addObject:firstObj];
            va_start(argumentList, firstObj);
            while((eachItem = va_arg(argumentList, PopMenuItem *))) {
                [menuItems addObject:eachItem];
            }
            va_end(argumentList);
        }
        self.menus = menuItems;
        [self setup];
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint localPoint = [touch locationInView:self];
    if (CGRectContainsPoint(self.menuTableView.frame, localPoint)) {
        [self hitTest:localPoint withEvent:event];
    } else {
        [self dissMissPopMenuAnimatedOnMenuSelected:NO];
    }
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifer = @"cellIdentifer";
    PopMenuItemView *popMenuItemView = (PopMenuItemView *)[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (!popMenuItemView) {
        popMenuItemView = [[PopMenuItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    
    if (indexPath.row < self.menus.count) {
        [popMenuItemView setupPopMenuItem:self.menus[indexPath.row] atIndexPath:indexPath isBottom:(indexPath.row == self.menus.count - 1)];
    }
    
    return popMenuItemView;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.indexPath = indexPath;
    [self dissMissPopMenuAnimatedOnMenuSelected:YES];
    if (self.popMenuDidSlectedCompled) {
        self.popMenuDidSlectedCompled(indexPath.row, self.menus[indexPath.row]);
    }
}

@end
