//
//  RTVoicePanelView.m
//  IM
//
//  Created by 郭志伟 on 15/7/15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTVoicePanelView.h"

#import "RTRecorderView.h"
#import "RTMicPanelView.h"

#define kStyleColor [UIColor colorWithRed:75/255.0f green:192/255.0f blue:209/255.0f alpha:1.0f]

@interface RTVoicePanelView() <RTMicPanelViewDelegate, RTRecorderViewDelegate, UIScrollViewDelegate>

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) RTMicPanelView *micPanelView;
@property(nonatomic, strong) RTRecorderView *recorderView;
@property(nonatomic, strong) UIPageControl *pageControl;

@end

@implementation RTVoicePanelView

- (void)rt_configureView {
    self.backgroundColor = [UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1];
    [self.scrollView addSubview:self.micPanelView];
    [self.scrollView addSubview:self.recorderView];
    [self addSubview:self.scrollView];
    [self addSubview:self.pageControl];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self rt_configureView];
    }
    return self;
}

- (void)awakeFromNib {
    [self rt_configureView];
}

#pragma mark - setter
- (void)setAudioDirectory:(NSString *)audioDirectory {
    _audioDirectory = [audioDirectory copy];
    self.micPanelView.audioDirectory = audioDirectory;
    self.recorderView.audioDirectory = audioDirectory;
}

#pragma mark - getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * 2, CGRectGetHeight(self.bounds));
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.currentPage = 0;
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.numberOfPages = 2;
        CGSize pageControlSize = [_pageControl sizeForNumberOfPages:2];
        
        CGRect pageControlFrame = CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                             CGRectGetHeight(self.bounds) - pageControlSize.height,
                                             pageControlSize.width,
                                             pageControlSize.height);
        _pageControl.currentPageIndicatorTintColor = kStyleColor;
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        self.pageControl.frame = CGRectIntegral(pageControlFrame);
    }
    return _pageControl;
}

- (RTMicPanelView *)micPanelView {
    if (!_micPanelView) {
        _micPanelView = [[RTMicPanelView alloc] initWithFrame:self.bounds];
        _micPanelView.delegate = self;
    }
    return _micPanelView;
}

- (RTRecorderView *)recorderView {
    if (!_recorderView) {
        _recorderView = [[RTRecorderView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds), 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        _recorderView.delegate = self;
    }
    return _recorderView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    NSInteger newPageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (self.pageControl.currentPage == newPageNumber) {
        return;
    }
    self.pageControl.currentPage = newPageNumber;
}

- (void)RTMicPanelViewSpeakOver:(RTMicPanelView *) speakerPanel audioPath:(NSString *)path duration:(CGFloat)duration {
    if (duration < 0.5f) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(RTVoicePanelView:audioPath:duration:)]) {
        [self.delegate RTVoicePanelView:self audioPath:path duration:duration];
    }
}

- (void)RTRecorderView:(RTRecorderView *)recorderView audioPath:(NSString *)path duration:(CGFloat)duration {
    if (duration < 0.5f) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(RTVoicePanelView:audioPath:duration:)]) {
        [self.delegate RTVoicePanelView:self audioPath:path duration:duration];
    }
}

@end
