//
//  RTQMessagesInputToolbar.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesInputToolbar.h"

#import "RTMessagesComposerTextView.h"

#import "RTMessagesToolbarButtonFactory.h"

#import "UIColor+RTMessages.h"
#import "UIImage+RTMessages.h"
#import "UIView+RTMessages.h"
#import "UIButton+RTMessages.h"

static void * kRTMessagesInputToolbarKeyValueObservingContext = &kRTMessagesInputToolbarKeyValueObservingContext;

@interface RTMessagesInputToolbar()

@property (assign, nonatomic) BOOL rt_isObserving;

- (void)rt_leftBarButtonPressed:(UIButton *)sender;
- (void)rt_rightBarButtonPressed:(UIButton *)sender;
- (void)rt_midBarButtonPressed:(UIButton *)sender;

- (void)rt_addObservers;
- (void)rt_removeObservers;

@end

@implementation RTMessagesInputToolbar

@dynamic delegate;

#pragma mark - Initialization

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.rt_isObserving = NO;
    self.sendButtonOnRight = YES;
    
    self.preferredDefaultHeight = 44.0f;
    self.maximumHeight = NSNotFound;
    
    RTMessagesToolbarContentView *toolbarContentView = [self loadToolbarContentView];
    toolbarContentView.frame = self.frame;
    [self addSubview:toolbarContentView];
    [self rt_pinAllEdgesOfSubview:toolbarContentView];
    [self setNeedsUpdateConstraints];
    _contentView = toolbarContentView;
    toolbarContentView.textView.returnKeyType = UIReturnKeySend;
    
    [self rt_addObservers];
    
    self.contentView.leftBarButtonItem = [RTMessagesToolbarButtonFactory micButtonItem];
    self.contentView.rightBarButtonItem = [RTMessagesToolbarButtonFactory moreButtonItem];
    self.contentView.midBarButtonItem = [RTMessagesToolbarButtonFactory emoteButtonItem];
    
    [self toggleSendButtonEnabled];
}

- (void)dealloc
{
    [self rt_removeObservers];
    _contentView = nil;
}


- (RTMessagesToolbarContentView *)loadToolbarContentView {
    NSArray *nibViews = [[NSBundle bundleForClass:[RTMessagesInputToolbar class]] loadNibNamed:NSStringFromClass([RTMessagesToolbarContentView class])
                                                                                          owner:nil
                                                                                        options:nil];
    return nibViews.firstObject;
}

- (void)setLeftButtonImage:(UIImage *)image{
    [self.contentView.leftBarButtonItem setImage:image];
}

- (void)setMidButtonImage:(UIImage *)image {
    [self.contentView.midBarButtonItem setImage:image];
}

- (void)setRightButtonImage:(UIImage *)image {
    [self.contentView.rightBarButtonItem setImage:image];
}

#pragma mark - Setters

- (void)setPreferredDefaultHeight:(CGFloat)preferredDefaultHeight {
    NSParameterAssert(preferredDefaultHeight > 0.0f);
    _preferredDefaultHeight = preferredDefaultHeight;
}

#pragma mark - Actions

- (void)rt_leftBarButtonPressed:(UIButton *)sender {
    [self.delegate messagesInputToolbar:self didPressLeftBarButton:sender];
}

- (void)rt_rightBarButtonPressed:(UIButton *)sender {
    [self.delegate messagesInputToolbar:self didPressRightBarButton:sender];
}

- (void)rt_midBarButtonPressed:(UIButton *)sender {
    [self.delegate messagesInputToolbar:self didPressMidBarButton:sender];
}

#pragma mark - Input toolbar

- (void)toggleSendButtonEnabled {
//    BOOL hasText = [self.contentView.textView hasText];
    
//    if (self.sendButtonOnRight) {
//        self.contentView.rightBarButtonItem.enabled = hasText;
//    }
//    else {
//        self.contentView.leftBarButtonItem.enabled = hasText;
//    }
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kRTMessagesInputToolbarKeyValueObservingContext) {
        if (object == self.contentView) {
            
            if ([keyPath isEqualToString:NSStringFromSelector(@selector(leftBarButtonItem))]) {
                
                [self.contentView.leftBarButtonItem removeTarget:self
                                                          action:NULL
                                                forControlEvents:UIControlEventTouchUpInside];
                
                [self.contentView.leftBarButtonItem addTarget:self
                                                       action:@selector(rt_leftBarButtonPressed:)
                                             forControlEvents:UIControlEventTouchUpInside];
            }
            else if ([keyPath isEqualToString:NSStringFromSelector(@selector(rightBarButtonItem))]) {
                
                [self.contentView.rightBarButtonItem removeTarget:self
                                                           action:NULL
                                                 forControlEvents:UIControlEventTouchUpInside];
                
                [self.contentView.rightBarButtonItem addTarget:self
                                                        action:@selector(rt_rightBarButtonPressed:)
                                              forControlEvents:UIControlEventTouchUpInside];
            } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(midBarButtonItem))]) {
                
                [self.contentView.midBarButtonItem removeTarget:self
                                                           action:NULL
                                                 forControlEvents:UIControlEventTouchUpInside];
                
                [self.contentView.midBarButtonItem addTarget:self
                                                        action:@selector(rt_midBarButtonPressed:)
                                              forControlEvents:UIControlEventTouchUpInside];
            }
            
            [self toggleSendButtonEnabled];
        }
    }
}

- (void)rt_addObservers {
    if (self.rt_isObserving) {
        return;
    }
    
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                          options:0
                          context:kRTMessagesInputToolbarKeyValueObservingContext];
    
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                          options:0
                          context:kRTMessagesInputToolbarKeyValueObservingContext];
    
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(midBarButtonItem))
                          options:0
                          context:kRTMessagesInputToolbarKeyValueObservingContext];
    
    self.rt_isObserving = YES;
}

- (void)rt_removeObservers
{
    if (!_rt_isObserving) {
        return;
    }
    
    @try {
        
        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                             context:kRTMessagesInputToolbarKeyValueObservingContext];
        
        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                             context:kRTMessagesInputToolbarKeyValueObservingContext];
        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(midBarButtonItem))
                             context:kRTMessagesInputToolbarKeyValueObservingContext];
    }
    @catch (NSException *__unused exception) { }
    
    _rt_isObserving = NO;
}

@end
