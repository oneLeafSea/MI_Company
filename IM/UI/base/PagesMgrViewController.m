//
//  PagesMgrViewController.m
//  testPagesMgr
//
//  Created by 郭志伟 on 14-11-2.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "PagesMgrViewController.h"
#import "SwipeBtnBarView.h"
#import "SwipeButtonBarViewCell.h"

static const CGFloat kBtnBarViewHeigth = 43.0f;
static const NSUInteger kBtnBarViewLeftRightMargin = 8;
#define kBtnBarViewFont ([UIFont fontWithName:@"Helvetica-Bold" size:18.0f])

@interface PagesMgrViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIPageViewControllerDelegate, UIPageViewControllerDataSource>{
    SwipeBtnBarView      *m_btnBarView;
    UIPageViewController *m_pageVC;
    NSUInteger            m_selectedIndex;
    CGFloat               m_btnBarViewContentWidth;
}

@end

@implementation PagesMgrViewController

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

-(instancetype)initWithViewControllers:(NSArray *)viewControllers {
    return [self initWithViewControllers:viewControllers currentIndex:0];
}

-(instancetype)initWithViewControllers:(NSArray *)viewControllers currentIndex:(NSUInteger)currentIndex {
    if (self = [self init]) {
        m_selectedIndex = currentIndex;
        _pageContentViewControllers = viewControllers;
        [self setup];
    }
    return self;
}

-(instancetype)initWithViewCurrentIndex:(NSUInteger)index viewControllers:(UIViewController *)firstViewController, ... NS_REQUIRES_NIL_TERMINATION {
    id eachObject;
    va_list argumentList;
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    if (firstViewController) {
        [mutableArray addObject:firstViewController];
        va_start(argumentList, firstViewController);
        while ((eachObject = va_arg(argumentList, id)))
            [mutableArray addObject:eachObject];
        va_end(argumentList);
    }
    return [self initWithViewControllers:mutableArray currentIndex:index];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = self.navTitle;
    m_btnBarViewContentWidth = [self btnBarViewContentWidth];
    [self initBtnBarView];
    [self initPageVC];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)currentIndex {
    return m_selectedIndex;
}

#pragma mark - private method.
- (void) setup {
    _animationDuration = 0.3f;
    m_selectedIndex = 0;
    _swipeEnabled = YES;
    _infiniteSwipe = YES;
}



- (void)initBtnBarView {
    CGRect viewRect = self.view.frame;
    
    CGRect btnBarViewRt = CGRectMake(viewRect.origin.x, 0, CGRectGetWidth(viewRect), kBtnBarViewHeigth);
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    m_btnBarView = [[SwipeBtnBarView alloc] initWithFrame:btnBarViewRt collectionViewLayout:layout];
    [self.view addSubview:m_btnBarView];
    [self createBtnBarViewConstraints];
    m_btnBarView.labelFont = kBtnBarViewFont;
    m_btnBarView.leftRightMargin = kBtnBarViewLeftRightMargin;
    m_btnBarView.delegate = self;
    m_btnBarView.dataSource = self;
    [m_btnBarView setShowsHorizontalScrollIndicator:NO];
    [m_btnBarView registerClass:[SwipeButtonBarViewCell class] forCellWithReuseIdentifier:@"swipeButtonBarViewCell"];
    m_btnBarView.backgroundColor = [UIColor colorWithRed:7.0f/255.0f green:185.0f/255.0f blue:155.0f/255.0f alpha:1];
    
    [self.view addSubview:m_btnBarView];
}

- (void)createBtnBarViewConstraints {
    NSDictionary *viewsDictionary =
    NSDictionaryOfVariableBindings(m_btnBarView);
    m_btnBarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[m_btnBarView]|" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[m_btnBarView(==43)]" options:0 metrics:nil views:viewsDictionary]];
    
}

- (void)initPageVC {    
    m_pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    if (self.pageContentViewControllers.count > 1) {
        m_pageVC.dataSource = self;
        m_pageVC.delegate = self;
    }
    
    UIViewController<SwipeContainerChildItem> *initialViewController = [self.pageContentViewControllers objectAtIndex:self.currentIndex];
    //
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [m_pageVC setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [m_btnBarView moveToIndex:self.currentIndex animated:NO];
    
    [self addChildViewController:m_pageVC];
    [self.view addSubview:m_pageVC.view];
    [self createPageViewConstraints];
    [m_pageVC.view setBackgroundColor:[UIColor grayColor]];
    [m_pageVC didMoveToParentViewController:self];
    
}

- (void)createPageViewConstraints {
    m_pageVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *view = m_pageVC.view;
    NSDictionary *viewsDictionary =
    NSDictionaryOfVariableBindings(view);
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:viewsDictionary];
    [self.view addConstraints:constraints];
    viewsDictionary = NSDictionaryOfVariableBindings(m_btnBarView, view);
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[m_btnBarView][view]|" options:0 metrics:nil views:viewsDictionary];
    [self.view addConstraints:constraints];
}

#pragma mark - UICollectionViewDelegateFlowLayout


#pragma mark -UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [m_btnBarView moveToIndex:indexPath.row animated:YES];
    UIViewController *controller = [self.pageContentViewControllers objectAtIndex:indexPath.row];
    if (m_selectedIndex == indexPath.row) {
        return;
    }
    [m_pageVC setViewControllers:@[controller] direction:m_selectedIndex < indexPath.row ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    m_selectedIndex = indexPath.row;
}



#pragma merk - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pageContentViewControllers.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.pageContentViewControllers.count == 1) {
        return CGSizeMake(m_btnBarView.frame.size.width, m_btnBarView.frame.size.height);
    }
    
    if (m_btnBarViewContentWidth < m_btnBarView.frame.size.width) {
        return CGSizeMake((m_btnBarView.frame.size.width - (m_btnBarView.leftRightMargin * 2)) / self.pageContentViewControllers.count, m_btnBarView.frame.size.height);
    }
    
    UIViewController<SwipeContainerChildItem> *pageController = [self.pageContentViewControllers objectAtIndex:indexPath.row];
    NSString *text = [pageController nameForPageContainer:self];
    CGSize labelSize = [self textSize:text];
    return CGSizeMake(labelSize.width + (m_btnBarView.leftRightMargin * 2), m_btnBarView.frame.size.height);
}

- (CGSize)textSize:(NSString *)text {
    NSDictionary *attributes = @{NSFontAttributeName: kBtnBarViewFont};
    CGSize size = [text sizeWithAttributes:attributes];
    return size;
}

- (CGFloat)btnBarViewContentWidth {
    CGFloat sum = m_btnBarView.leftRightMargin;
    for (UIViewController<SwipeContainerChildItem> *pageController in self.pageContentViewControllers) {
        NSString *text = [pageController nameForPageContainer:self];
        CGSize labelSize = [self textSize:text];
        sum += labelSize.width;
        sum += m_btnBarView.leftRightMargin;
    }
    return sum;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SwipeButtonBarViewCell *cell = (SwipeButtonBarViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"swipeButtonBarViewCell" forIndexPath:indexPath];
    
    UIViewController<SwipeContainerChildItem> *pageContentVc = [self.pageContentViewControllers objectAtIndex:indexPath.row];
    
    if ([pageContentVc respondsToSelector:@selector(nameForPageContainer:)]) {
        cell.title.text = [pageContentVc nameForPageContainer:self];
    }
    if ([pageContentVc respondsToSelector:@selector(colorForPageContainer:)]) {
        cell.title.textColor = [pageContentVc colorForPageContainer:self];
    }
    return cell;
}


#pragma mark -UIPageViewController delegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self.pageContentViewControllers indexOfObject:viewController];
    UIViewController *controller = nil;
    if (index == 0) {
        if (self.infiniteSwipe) {
            index = self.pageContentViewControllers.count - 1;
            controller = [self.pageContentViewControllers objectAtIndex:index];
        } else {
            controller = nil;
        }
    } else {
        index--;
        controller = [self.pageContentViewControllers objectAtIndex:index];
    }
    return controller;
    
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self.pageContentViewControllers indexOfObject:viewController];
    index++;
    UIViewController *controller = nil;
    if (index == self.pageContentViewControllers.count) {
        if (self.infiniteSwipe) {
            index = 0;
            controller = [self.pageContentViewControllers objectAtIndex:index];
            
        } else {
            controller = nil;
        }
    } else {
        controller = [self.pageContentViewControllers objectAtIndex:index];
    }
    return controller;

}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    UIViewController *controller = [m_pageVC.viewControllers objectAtIndex:0];
    NSUInteger index = [self.pageContentViewControllers indexOfObject:controller];
    [m_btnBarView moveToIndex:index animated:YES];
    m_selectedIndex = index;
}

@end
