//
//  RTMessagesViewController.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesViewController.h"

#import "RTMessagesCollectionViewFlowLayoutInvalidationContext.h"

#import "RTMessageData.h"
#import "RTMessageBubbleImageDataSource.h"
#import "RTMessageAvatarImageDataSource.h"

#import "RTMessagesCollectionViewCellIncoming.h"
#import "RTMessagesCollectionViewCellOutgoing.h"

#import "RTMessagesTypingIndicatorFooterView.h"
#import "RTMessagesLoadEarlierHeaderView.h"

#import "RTMessagesToolbarContentView.h"
#import "RTMessagesInputToolbar.h"
#import "RTMessagesComposerTextView.h"

#import "RTMessagesTimestampFormatter.h"


#import "NSString+RTMessages.h"
#import "UIColor+RTMessages.h"
#import "UIDevice+RTMessages.h"
#import "NSBundle+RTMessages.h"
#import "UIButton+RTMessages.h"
#import "UIImage+RTMessages.h"
#import "RTMorePanelView.h"
#import "UIColor+Hexadecimal.h"

static void * kRTMessagesKeyValueObservingContext = &kRTMessagesKeyValueObservingContext;

@interface RTMessagesViewController() <RTMessagesInputToolbarDelegate,RTMessagesKeyboardControllerDelegate, AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource, RTVoicePanelViewDelegate>

@property (weak, nonatomic) IBOutlet RTMessagesCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet RTMessagesInputToolbar *inputToolbar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomLayoutGuide;

@property (weak, nonatomic) UIView *snapshotView;
@property (assign, nonatomic) BOOL rt_isObserving;

@property (strong, nonatomic) NSIndexPath *selectedIndexPathForMenu;

@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;
@property (strong, nonatomic) RTVoicePanelView *micPanelView;
@property (strong, nonatomic) RTMorePanelView *morePanelView;

@property (assign, nonatomic) BOOL isEmotejKeyboard;
@property (assign, nonatomic) BOOL isRecordkeyboard;


@property (assign, atomic) BOOL loadingMoreMessage;


- (void)rt_configureMessagesViewController;

- (NSString *)rt_currentlyComposedMessageText;

- (void)rt_handleDidChangeStatusBarFrameNotification:(NSNotification *)notification;
- (void)rt_didReceiveMenuWillShowNotification:(NSNotification *)notification;
- (void)rt_didReceiveMenuWillHideNotification:(NSNotification *)notification;

- (void)rt_updateKeyboardTriggerPoint;
- (void)rt_setToolbarBottomLayoutGuideConstant:(CGFloat)constant;

- (void)rt_handleInteractivePopGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

- (BOOL)rt_inputToolbarHasReachedMaximumHeight;
- (void)rt_adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy;
- (void)rt_adjustInputToolbarHeightConstraintByDelta:(CGFloat)dy;
- (void)rt_scrollComposerTextViewToBottomAnimated:(BOOL)animated;

- (void)rt_updateCollectionViewInsets;
- (void)rt_setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom;

- (BOOL)rt_isMenuVisible;

- (void)rt_addObservers;
- (void)rt_removeObservers;

- (void)rt_registerForNotifications:(BOOL)registerForNotifications;

- (void)rt_addActionToInteractivePopGestureRecognizer:(BOOL)addAction;

@end

@implementation RTMessagesViewController

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([RTMessagesViewController class])
                          bundle:[NSBundle bundleForClass:[RTMessagesViewController class]]];
}

+ (instancetype)messagesViewController
{
    return [[[self class] alloc] initWithNibName:NSStringFromClass([RTMessagesViewController class])
                                          bundle:[NSBundle bundleForClass:[RTMessagesViewController class]]];
}


- (void)rt_configureMessagesViewController {
    self.view.backgroundColor = [UIColor whiteColor];
    
    _isEmotejKeyboard = NO;
    self.rt_isObserving = NO;
    
    self.toolbarHeightConstraint.constant = self.inputToolbar.preferredDefaultHeight;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.inputToolbar.delegate = self;
    self.inputToolbar.contentView.textView.placeHolder = [NSBundle rt_localizedStringForKey:@"new_message"];
    self.inputToolbar.contentView.textView.delegate = self;
    
    self.automaticallyScrollsToMostRecentMessage = YES;
    
    self.outgoingCellIdentifier = [RTMessagesCollectionViewCellOutgoing cellReuseIdentifier];
    self.outgoingMediaCellIdentifier = [RTMessagesCollectionViewCellOutgoing mediaCellReuseIdentifier];
    
    self.incomingCellIdentifier = [RTMessagesCollectionViewCellIncoming cellReuseIdentifier];
    self.incomingMediaCellIdentifier = [RTMessagesCollectionViewCellIncoming mediaCellReuseIdentifier];
    
    self.showTypingIndicator = NO;
    
    self.showLoadEarlierMessagesHeader = NO;
    
    self.topContentAdditionalInset = 0.0f;
    
    [self rt_updateCollectionViewInsets];
    
    self.emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 252) dataSource:self];
    self.emojiKeyboardView.segmentsBar.tintColor = [UIColor colorWithHex:@"#02C1D2"];
    self.emojiKeyboardView.delegate = self;
    self.emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    self.micPanelView = [[RTVoicePanelView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 252)];
    self.micPanelView.delegate = self;
    
    self.morePanelView = [[RTMorePanelView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 252)];
    [self registerMoreItems];
    
    self.keyboardController = [[RTMessagesKeyboardController alloc] initWithTextView:self.inputToolbar.contentView.textView
                                                                          contextView:self.view
                                                                             delegate:self];
}

- (void)setAudioDirectory:(NSString *)audioDirectory {
    self.micPanelView.audioDirectory = audioDirectory;
}


- (void)registerMoreItems {
//    self.isMoreKeyboard = NO;
    
}



- (void)dealloc {
    [self rt_registerForNotifications:NO];
    [self rt_removeObservers];
    
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
    _collectionView = nil;
    
    _inputToolbar.contentView.textView.delegate = nil;
    _inputToolbar.delegate = nil;
    _inputToolbar = nil;
    
    _toolbarHeightConstraint = nil;
    _toolbarBottomLayoutGuide = nil;
    
    _senderId = nil;
    _senderDisplayName = nil;
    _outgoingCellIdentifier = nil;
    _incomingCellIdentifier = nil;
    
    [_keyboardController endListeningForKeyboard];
    _keyboardController = nil;
}

#pragma mark - Setters

- (void)setShowTypingIndicator:(BOOL)showTypingIndicator {
    if (_showTypingIndicator == showTypingIndicator) {
        return;
    }
    
    _showTypingIndicator = showTypingIndicator;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[RTMessagesCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)setShowLoadEarlierMessagesHeader:(BOOL)showLoadEarlierMessagesHeader {
    if (_showLoadEarlierMessagesHeader == showLoadEarlierMessagesHeader) {
        return;
    }
    
    _showLoadEarlierMessagesHeader = showLoadEarlierMessagesHeader;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[RTMessagesCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
}


- (void)setTopContentAdditionalInset:(CGFloat)topContentAdditionalInset {
    _topContentAdditionalInset = topContentAdditionalInset;
    [self rt_updateCollectionViewInsets];
}

- (void)setIsEmotejKeyboard:(BOOL)isEmotejKeyboard {
    _isEmotejKeyboard = isEmotejKeyboard;
    _isRecordkeyboard = NO;
    _isMoreKeyboard = NO;
    [self.inputToolbar.contentView.leftBarButtonItem setImage:[UIImage rt_micImage]];
    [self.inputToolbar.contentView.rightBarButtonItem setImage:[UIImage rt_moreImage]];
    if (isEmotejKeyboard) {
        [self.inputToolbar.contentView.midBarButtonItem setImage:[UIImage rt_keyboardImage]];
        self.inputToolbar.contentView.textView.inputView = self.emojiKeyboardView;
        [self.inputToolbar.contentView.textView reloadInputViews];
    } else {
        [self.inputToolbar.contentView.midBarButtonItem setImage:[UIImage rt_emoteImage]];
        self.inputToolbar.contentView.textView.inputView = nil;
        [self.inputToolbar.contentView.textView reloadInputViews];
    }
}

- (void)setIsRecordkeyboard:(BOOL)isRecordkeyboard {
    _isRecordkeyboard = isRecordkeyboard;
    _isEmotejKeyboard = NO;
    _isMoreKeyboard = NO;
    [self.inputToolbar.contentView.midBarButtonItem setImage:[UIImage rt_emoteImage]];
    [self.inputToolbar.contentView.rightBarButtonItem setImage:[UIImage rt_moreImage]];
    if (isRecordkeyboard) {
        [self.inputToolbar.contentView.leftBarButtonItem setImage:[UIImage rt_keyboardImage]];
        self.inputToolbar.contentView.textView.inputView = self.micPanelView;
        [self.inputToolbar.contentView.textView reloadInputViews];
    } else {
        [self.inputToolbar.contentView.leftBarButtonItem setImage:[UIImage rt_micImage]];
        self.inputToolbar.contentView.textView.inputView = nil;
        [self.inputToolbar.contentView.textView reloadInputViews];

    }
}

- (void)setIsMoreKeyboard:(BOOL)isMoreKeyboard {
    _isMoreKeyboard = isMoreKeyboard;
    _isRecordkeyboard = NO;
    _isEmotejKeyboard = NO;
    [self.inputToolbar.contentView.midBarButtonItem setImage:[UIImage rt_emoteImage]];
    [self.inputToolbar.contentView.leftBarButtonItem setImage:[UIImage rt_micImage]];
    if (_isMoreKeyboard) {
        [self.inputToolbar.contentView.rightBarButtonItem setImage:[UIImage rt_keyboardImage]];
        self.inputToolbar.contentView.textView.inputView = self.morePanelView;
        [self.inputToolbar.contentView.textView reloadInputViews];
    } else {
        [self.inputToolbar.contentView.rightBarButtonItem setImage:[UIImage rt_moreImage]];
        self.inputToolbar.contentView.textView.inputView = nil;
        [self.inputToolbar.contentView.textView reloadInputViews];
    }
}

//- (void)setLoadingMoreMessage:(BOOL)loadingMoreMessage {
//    _loadingMoreMessage = loadingMoreMessage;
//    if (_loadingMoreMessage) {
//        self.showLoadEarlierMessagesHeader = YES;
//    } else {
//        self.showLoadEarlierMessagesHeader = NO;
//    }
//}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[self class] nib] instantiateWithOwner:self options:nil];
    
    [self rt_configureMessagesViewController];
    [self rt_registerForNotifications:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    NSParameterAssert(self.senderId != nil);
    NSParameterAssert(self.senderDisplayName != nil);
    
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    if (self.automaticallyScrollsToMostRecentMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToBottomAnimated:NO];
            [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[RTMessagesCollectionViewFlowLayoutInvalidationContext context]];
        });
    }
    
    [self rt_updateKeyboardTriggerPoint];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self rt_addObservers];
    [self rt_addActionToInteractivePopGestureRecognizer:YES];
    [self.keyboardController beginListeningForKeyboard];
    
    if ([UIDevice rt_isCurrentDeviceBeforeiOS8]) {
        [self.snapshotView removeFromSuperview];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self rt_addActionToInteractivePopGestureRecognizer:NO];
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self rt_removeObservers];
    [self.keyboardController endListeningForKeyboard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"MEMORY WARNING: %s", __PRETTY_FUNCTION__);
}

#pragma mark - View rotation

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskAll;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[RTMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if (self.showTypingIndicator) {
        self.showTypingIndicator = NO;
        self.showTypingIndicator = YES;
        [self.collectionView reloadData];
    }
}

#pragma mark - Messages view controller

- (void)didPressLeftButton:(UIButton *)sender {
    self.isRecordkeyboard = !self.isRecordkeyboard;
    [self.inputToolbar.contentView.textView becomeFirstResponder];
}

- (void)didPressRightButton:(UIButton *)sender {
    self.isMoreKeyboard = !self.isMoreKeyboard;
    [self.inputToolbar.contentView.textView becomeFirstResponder];
}


- (void)didPressMidButton:(UIButton *)sender {
    self.isEmotejKeyboard = !self.isEmotejKeyboard;

    [self.inputToolbar.contentView.textView becomeFirstResponder];
}


- (void)didPressReturnKeyWithMessageText:(NSString *)text
                                senderId:(NSString *)senderId
                       senderDisplayName:(NSString *)senderDisplayName
                                    date:(NSDate *)date {
    NSAssert(NO, @"Error! required method not implemented in subclass. Need to implement %s", __PRETTY_FUNCTION__);
}

- (void)finishSendingMessage
{
    [self finishSendingMessageAnimated:YES];
}

- (void)finishSendingMessageAnimated:(BOOL)animated {
    
    UITextView *textView = self.inputToolbar.contentView.textView;
    textView.text = nil;
    [textView.undoManager removeAllActions];
    
//    [self.inputToolbar toggleSendButtonEnabled];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:textView];
    
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[RTMessagesCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView reloadData];
    
    [self scrollToBottomAnimated:animated];
}

- (void)finishReceivingMessage
{
    [self finishReceivingMessageAnimated:YES];
}

- (void)finishReceivingMessageAnimated:(BOOL)animated {
    
    self.showTypingIndicator = NO;
    
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[RTMessagesCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView reloadData];
    
    if (self.automaticallyScrollsToMostRecentMessage && ![self rt_isMenuVisible]) {
        [self scrollToBottomAnimated:animated];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    if ([self.collectionView numberOfSections] == 0) {
        return;
    }
    
    NSInteger items = [self.collectionView numberOfItemsInSection:0];
    
    if (items == 0) {
        return;
    }
    
    CGFloat collectionViewContentHeight = [self.collectionView.collectionViewLayout collectionViewContentSize].height;
    BOOL isContentTooSmall = (collectionViewContentHeight < CGRectGetHeight(self.collectionView.bounds));
    
    if (isContentTooSmall) {
        [self.collectionView scrollRectToVisible:CGRectMake(0.0, collectionViewContentHeight - 1.0f, 1.0f, 1.0f)
                                        animated:animated];
        return;
    }

    NSUInteger finalRow = MAX(0, [self.collectionView numberOfItemsInSection:0] - 1);
    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
    CGSize finalCellSize = [self.collectionView.collectionViewLayout sizeForItemAtIndexPath:finalIndexPath];
    
    CGFloat maxHeightForVisibleMessage = CGRectGetHeight(self.collectionView.bounds) - self.collectionView.contentInset.top - CGRectGetHeight(self.inputToolbar.bounds);
    
    UICollectionViewScrollPosition scrollPosition = (finalCellSize.height > maxHeightForVisibleMessage) ? UICollectionViewScrollPositionBottom : UICollectionViewScrollPositionTop;
    
    [self.collectionView scrollToItemAtIndexPath:finalIndexPath
                                atScrollPosition:scrollPosition
                                        animated:animated];
}

#pragma mark - RTMessages collection view data source

- (id<RTMessageData>)collectionView:(RTMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

- (id<RTMessageBubbleImageDataSource>)collectionView:(RTMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

- (id<RTMessageAvatarImageDataSource>)collectionView:(RTMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

- (NSAttributedString *)collectionView:(RTMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(RTMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(RTMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(RTMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<RTMessageData> messageItem = [collectionView.dataSource collectionView:collectionView messageDataForItemAtIndexPath:indexPath];
    NSParameterAssert(messageItem != nil);
    
    NSString *messageSenderId = [messageItem senderId];
    NSParameterAssert(messageSenderId != nil);
    
    BOOL isOutgoingMessage = [messageSenderId isEqualToString:self.senderId];
    BOOL isMediaMessage = [messageItem isMediaMessage];
    
    NSString *cellIdentifier = nil;
    if (isMediaMessage) {
        cellIdentifier = isOutgoingMessage ? self.outgoingMediaCellIdentifier : self.incomingMediaCellIdentifier;
    }
    else {
        cellIdentifier = isOutgoingMessage ? self.outgoingCellIdentifier : self.incomingCellIdentifier;
    }
    
    RTMessagesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = collectionView;
    
    if (!isMediaMessage) {
        cell.textView.text = [messageItem text];
        
        if ([UIDevice rt_isCurrentDeviceBeforeiOS8]) {
            //  workaround for iOS 7 textView data detectors bug
            cell.textView.text = nil;
            cell.textView.attributedText = [[NSAttributedString alloc] initWithString:[messageItem text]
                                                                           attributes:@{ NSFontAttributeName : collectionView.collectionViewLayout.messageBubbleFont }];
        }
        
        NSParameterAssert(cell.textView.text != nil);
        
        id<RTMessageBubbleImageDataSource> bubbleImageDataSource = [collectionView.dataSource collectionView:collectionView messageBubbleImageDataForItemAtIndexPath:indexPath];
        if (bubbleImageDataSource != nil) {
            cell.messageBubbleImageView.image = [bubbleImageDataSource messageBubbleImage];
            cell.messageBubbleImageView.highlightedImage = [bubbleImageDataSource messageBubbleHighlightedImage];
        }
    }
    else {
        id<RTMessageMediaData> messageMedia = [messageItem media];
        cell.mediaView = [messageMedia mediaView] ?: [messageMedia mediaPlaceholderView];
        NSParameterAssert(cell.mediaView != nil);
    }
    
    BOOL needsAvatar = YES;
    if (isOutgoingMessage && CGSizeEqualToSize(collectionView.collectionViewLayout.outgoingAvatarViewSize, CGSizeZero)) {
        needsAvatar = NO;
    }
    else if (!isOutgoingMessage && CGSizeEqualToSize(collectionView.collectionViewLayout.incomingAvatarViewSize, CGSizeZero)) {
        needsAvatar = NO;
    }
    
    id<RTMessageAvatarImageDataSource> avatarImageDataSource = nil;
    if (needsAvatar) {
        avatarImageDataSource = [collectionView.dataSource collectionView:collectionView avatarImageDataForItemAtIndexPath:indexPath];
        if (avatarImageDataSource != nil) {
            
            UIImage *avatarImage = [avatarImageDataSource avatarImage];
            if (avatarImage == nil) {
                cell.avatarImageView.image = [avatarImageDataSource avatarPlaceholderImage];
                cell.avatarImageView.highlightedImage = nil;
            }
            else {
                cell.avatarImageView.image = avatarImage;
                cell.avatarImageView.highlightedImage = [avatarImageDataSource avatarHighlightedImage];
            }
        }
    }
    
    cell.cellTopLabel.attributedText = [collectionView.dataSource collectionView:collectionView attributedTextForCellTopLabelAtIndexPath:indexPath];
    cell.messageBubbleTopLabel.attributedText = [collectionView.dataSource collectionView:collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:indexPath];
    cell.cellBottomLabel.attributedText = [collectionView.dataSource collectionView:collectionView attributedTextForCellBottomLabelAtIndexPath:indexPath];
    
    CGFloat bubbleTopLabelInset = (avatarImageDataSource != nil) ? 60.0f : 15.0f;
    
    if (isOutgoingMessage) {
        cell.messageBubbleTopLabel.textInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, bubbleTopLabelInset);
    }
    else {
        cell.messageBubbleTopLabel.textInsets = UIEdgeInsetsMake(0.0f, bubbleTopLabelInset, 0.0f, 0.0f);
    }
    
    cell.textView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.layer.shouldRasterize = YES;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(RTMessagesCollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if (self.showTypingIndicator && [kind isEqualToString:UICollectionElementKindSectionFooter]) {
        return [collectionView dequeueTypingIndicatorFooterViewForIndexPath:indexPath];
    }
    else if (self.showLoadEarlierMessagesHeader && [kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [collectionView dequeueLoadEarlierMessagesViewHeaderForIndexPath:indexPath];
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(RTMessagesCollectionViewFlowLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (!self.showTypingIndicator) {
        return CGSizeZero;
    }
    
    return CGSizeMake([collectionViewLayout itemWidth], kRTMessagesTypingIndicatorFooterViewHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(RTMessagesCollectionViewFlowLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (!self.showLoadEarlierMessagesHeader) {
        return CGSizeZero;
    }
    
    return CGSizeMake([collectionViewLayout itemWidth], kRTMessagesLoadEarlierHeaderViewHeight);
}

#pragma mark - Collection view delegate

- (BOOL)collectionView:(RTMessagesCollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //  disable menu for media messages
    id<RTMessageData> messageItem = [collectionView.dataSource collectionView:collectionView messageDataForItemAtIndexPath:indexPath];
    if ([messageItem isMediaMessage]) {
        return NO;
    }
    
    self.selectedIndexPathForMenu = indexPath;
    
    RTMessagesCollectionViewCell *selectedCell = (RTMessagesCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    selectedCell.textView.selectable = NO;
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        return YES;
    }
    
    return NO;
}

- (void)collectionView:(RTMessagesCollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        id<RTMessageData> messageData = [collectionView.dataSource collectionView:collectionView messageDataForItemAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:[messageData text]];
    }
}

#pragma mark - Collection view delegate flow layout

- (CGSize)collectionView:(RTMessagesCollectionView *)collectionView
                  layout:(RTMessagesCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

- (CGFloat)collectionView:(RTMessagesCollectionView *)collectionView
                   layout:(RTMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (CGFloat)collectionView:(RTMessagesCollectionView *)collectionView
                   layout:(RTMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (CGFloat)collectionView:(RTMessagesCollectionView *)collectionView
                   layout:(RTMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (void)collectionView:(RTMessagesCollectionView *)collectionView
 didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath {
    [self.inputToolbar.contentView.textView resignFirstResponder];
    self.isEmotejKeyboard = NO;
}

- (void)collectionView:(RTMessagesCollectionView *)collectionView didLongPressedAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(RTMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    [self.inputToolbar.contentView.textView resignFirstResponder];
    self.isEmotejKeyboard = NO;
}

- (void)collectionView:(RTMessagesCollectionView *)collectionView
 didTapCellAtIndexPath:(NSIndexPath *)indexPath
         touchLocation:(CGPoint)touchLocation {
    [self.inputToolbar.contentView.textView resignFirstResponder];
    self.isEmotejKeyboard = NO;
}

- (void)collectionViewDidTapped:(RTMessagesCollectionView *)collectionView {
    [self.inputToolbar.contentView.textView resignFirstResponder];
    self.isEmotejKeyboard = NO;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (self.shouldLoadMoreMessages) {
        if (scrollView.contentOffset.y >= -109 && scrollView.contentOffset.y <= -65) {
            if (!self.loadingMoreMessage) {
                [self loadMoreMessagesScrollTotop];
            }
        }
    }
}

- (void)loadMoreMessagesScrollTotop {
    self.loadingMoreMessage = YES;
    self.showLoadEarlierMessagesHeader = self.loadingMoreMessage;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadMoreMessage];
        sleep(1); // 加载速度过快会反复调用。
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.loadingMoreMessage = NO;
            self.showLoadEarlierMessagesHeader = self.loadingMoreMessage;
        });
    });
}

- (void)loadMoreMessage {
    
}


#pragma mark - Input toolbar delegate

- (void)messagesInputToolbar:(RTMessagesInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender
{
    [self didPressLeftButton:sender];
}

- (void)messagesInputToolbar:(RTMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender
{
    [self didPressRightButton:sender];
}

- (void)messagesInputToolbar:(RTMessagesInputToolbar *)toolbar didPressMidBarButton:(UIButton *)sender {
    [self didPressMidButton:sender];
}

- (NSString *)rt_currentlyComposedMessageText
{
    //  auto-accept any auto-correct suggestions
    [self.inputToolbar.contentView.textView.inputDelegate selectionWillChange:self.inputToolbar.contentView.textView];
    [self.inputToolbar.contentView.textView.inputDelegate selectionDidChange:self.inputToolbar.contentView.textView];
    
    return [self.inputToolbar.contentView.textView.text rt_stringByTrimingWhitespace];
}

#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    
    [textView becomeFirstResponder];
    
    [self scrollToBottomAnimated:YES];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    
//    [self.inputToolbar toggleSendButtonEnabled];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if ([textView hasText]) {
            [self didPressReturnKeyWithMessageText:[self rt_currentlyComposedMessageText] senderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date]];
        }
        return NO;
    }
    return YES;
}

#pragma mark - Notifications

- (void)rt_handleDidChangeStatusBarFrameNotification:(NSNotification *)notification
{
    if (self.keyboardController.keyboardIsVisible) {
        [self rt_setToolbarBottomLayoutGuideConstant:CGRectGetHeight(self.keyboardController.currentKeyboardFrame)];
    }
}

- (void)rt_didReceiveMenuWillShowNotification:(NSNotification *)notification
{
    if (!self.selectedIndexPathForMenu) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    UIMenuController *menu = [notification object];
    [menu setMenuVisible:NO animated:NO];
    
    RTMessagesCollectionViewCell *selectedCell = (RTMessagesCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPathForMenu];
    CGRect selectedCellMessageBubbleFrame = [selectedCell convertRect:selectedCell.messageBubbleContainerView.frame toView:self.view];
    
    [menu setTargetRect:selectedCellMessageBubbleFrame inView:self.view];
    [menu setMenuVisible:YES animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rt_didReceiveMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
}

- (void)rt_didReceiveMenuWillHideNotification:(NSNotification *)notification
{
    if (!self.selectedIndexPathForMenu) {
        return;
    }
    
    RTMessagesCollectionViewCell *selectedCell = (RTMessagesCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPathForMenu];
    selectedCell.textView.selectable = YES;
    self.selectedIndexPathForMenu = nil;
}

#pragma mark - Key-value observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kRTMessagesKeyValueObservingContext) {
        
        if (object == self.inputToolbar.contentView.textView
            && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            
            CGSize oldContentSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
            
            CGFloat dy = newContentSize.height - oldContentSize.height;
            
            [self rt_adjustInputToolbarForComposerTextViewContentSizeChange:dy];
            [self rt_updateCollectionViewInsets];
            if (self.automaticallyScrollsToMostRecentMessage) {
                [self scrollToBottomAnimated:NO];
            }
        }
    }
}

#pragma mark - Keyboard controller delegate
- (void)keyboardController:(RTMessagesKeyboardController *)keyboardController keyboardDidChangeFrame:(CGRect)keyboardFrame
{
    if (![self.inputToolbar.contentView.textView isFirstResponder] && self.toolbarBottomLayoutGuide.constant == 0.0f) {
        return;
    }
    
    CGFloat heightFromBottom = CGRectGetMaxY(self.collectionView.frame) - CGRectGetMinY(keyboardFrame);
    
    heightFromBottom = MAX(0.0f, heightFromBottom);
    
    [self rt_setToolbarBottomLayoutGuideConstant:heightFromBottom];
}

- (void)rt_setToolbarBottomLayoutGuideConstant:(CGFloat)constant
{
    self.toolbarBottomLayoutGuide.constant = constant;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
    
    [self rt_updateCollectionViewInsets];
}

- (void)rt_updateKeyboardTriggerPoint
{
    self.keyboardController.keyboardTriggerPoint = CGPointMake(0.0f, CGRectGetHeight(self.inputToolbar.bounds));
}

#pragma mark - Gesture recognizers

- (void)rt_handleInteractivePopGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            if ([UIDevice rt_isCurrentDeviceBeforeiOS8]) {
                [self.snapshotView removeFromSuperview];
            }
            
            [self.keyboardController endListeningForKeyboard];
            
            if ([UIDevice rt_isCurrentDeviceBeforeiOS8]) {
                [self.inputToolbar.contentView.textView resignFirstResponder];
                [UIView animateWithDuration:0.0
                                 animations:^{
                                     [self rt_setToolbarBottomLayoutGuideConstant:0.0f];
                                 }];
                
                UIView *snapshot = [self.view snapshotViewAfterScreenUpdates:YES];
                [self.view addSubview:snapshot];
                self.snapshotView = snapshot;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            [self.keyboardController beginListeningForKeyboard];
            
            if ([UIDevice rt_isCurrentDeviceBeforeiOS8]) {
                [self.snapshotView removeFromSuperview];
            }
            break;
        default:
            break;
    }
}

#pragma mark - Input toolbar utilities
- (BOOL)rt_inputToolbarHasReachedMaximumHeight
{
    return CGRectGetMinY(self.inputToolbar.frame) == (self.topLayoutGuide.length + self.topContentAdditionalInset);
}

- (void)rt_adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy
{
    BOOL contentSizeIsIncreasing = (dy > 0);
    
    if ([self rt_inputToolbarHasReachedMaximumHeight]) {
        BOOL contentOffsetIsPositive = (self.inputToolbar.contentView.textView.contentOffset.y > 0);
        
        if (contentSizeIsIncreasing || contentOffsetIsPositive) {
            [self rt_scrollComposerTextViewToBottomAnimated:YES];
            return;
        }
    }
    
    CGFloat toolbarOriginY = CGRectGetMinY(self.inputToolbar.frame);
    CGFloat newToolbarOriginY = toolbarOriginY - dy;
    
    //  attempted to increase origin.Y above topLayoutGuide
    if (newToolbarOriginY <= self.topLayoutGuide.length + self.topContentAdditionalInset) {
        dy = toolbarOriginY - (self.topLayoutGuide.length + self.topContentAdditionalInset);
        [self rt_scrollComposerTextViewToBottomAnimated:YES];
    }
    
    [self rt_adjustInputToolbarHeightConstraintByDelta:dy];
    
    [self rt_updateKeyboardTriggerPoint];
    
    if (dy < 0) {
        [self rt_scrollComposerTextViewToBottomAnimated:NO];
    }
}

- (void)rt_adjustInputToolbarHeightConstraintByDelta:(CGFloat)dy
{
    CGFloat proposedHeight = self.toolbarHeightConstraint.constant + dy;
    
    CGFloat finalHeight = MAX(proposedHeight, self.inputToolbar.preferredDefaultHeight);
    
    if (self.inputToolbar.maximumHeight != NSNotFound) {
        finalHeight = MIN(finalHeight, self.inputToolbar.maximumHeight);
    }
    
    if (self.toolbarHeightConstraint.constant != finalHeight) {
        self.toolbarHeightConstraint.constant = finalHeight;
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    }
}

- (void)rt_scrollComposerTextViewToBottomAnimated:(BOOL)animated
{
    UITextView *textView = self.inputToolbar.contentView.textView;
    CGPoint contentOffsetToShowLastLine = CGPointMake(0.0f, textView.contentSize.height - CGRectGetHeight(textView.bounds));
    
    if (!animated) {
        textView.contentOffset = contentOffsetToShowLastLine;
        return;
    }
    
    [UIView animateWithDuration:0.01
                          delay:0.01
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         textView.contentOffset = contentOffsetToShowLastLine;
                     }
                     completion:nil];
}

#pragma mark - Collection view utilities
- (void)rt_updateCollectionViewInsets
{
    [self rt_setCollectionViewInsetsTopValue:self.topLayoutGuide.length + self.topContentAdditionalInset
                                  bottomValue:CGRectGetMaxY(self.collectionView.frame) - CGRectGetMinY(self.inputToolbar.frame)];
}

- (void)rt_setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsMake(top, 0.0f, bottom, 0.0f);
    self.collectionView.contentInset = insets;
    self.collectionView.scrollIndicatorInsets = insets;
}

- (BOOL)rt_isMenuVisible
{
    //  check if cell copy menu is showing
    //  it is only our menu if `selectedIndexPathForMenu` is not `nil`
    return self.selectedIndexPathForMenu != nil && [[UIMenuController sharedMenuController] isMenuVisible];
}

#pragma mark - Utilities

- (void)rt_addObservers
{
    if (self.rt_isObserving) {
        return;
    }
    
    [self.inputToolbar.contentView.textView addObserver:self
                                             forKeyPath:NSStringFromSelector(@selector(contentSize))
                                                options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                                context:kRTMessagesKeyValueObservingContext];
    
    self.rt_isObserving = YES;
}

- (void)rt_removeObservers
{
    if (!_rt_isObserving) {
        return;
    }
    
    @try {
        [_inputToolbar.contentView.textView removeObserver:self
                                                forKeyPath:NSStringFromSelector(@selector(contentSize))
                                                   context:kRTMessagesKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }
    
    _rt_isObserving = NO;
}

- (void)rt_registerForNotifications:(BOOL)registerForNotifications
{
    if (registerForNotifications) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(rt_handleDidChangeStatusBarFrameNotification:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(rt_didReceiveMenuWillShowNotification:)
                                                     name:UIMenuControllerWillShowMenuNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(rt_didReceiveMenuWillHideNotification:)
                                                     name:UIMenuControllerWillHideMenuNotification
                                                   object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidChangeStatusBarFrameNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIMenuControllerWillShowMenuNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIMenuControllerWillHideMenuNotification
                                                      object:nil];
    }
}

- (void)rt_addActionToInteractivePopGestureRecognizer:(BOOL)addAction
{
    if (self.navigationController.interactivePopGestureRecognizer) {
        [self.navigationController.interactivePopGestureRecognizer removeTarget:nil
                                                                         action:@selector(rt_handleInteractivePopGestureRecognizer:)];
        
        if (addAction) {
            [self.navigationController.interactivePopGestureRecognizer addTarget:self
                                                                          action:@selector(rt_handleInteractivePopGestureRecognizer:)];
        }
    }
}

#pragma mark AGEmotjiKeyboard delegate

- (UIColor *)randomColor {
    return [UIColor colorWithRed:drand48()
                           green:drand48()
                            blue:drand48()
                           alpha:drand48()];
}

- (UIImage *)randomImage {
    CGSize size = CGSizeMake(30, 10);
    UIGraphicsBeginImageContextWithOptions(size , NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextFillRect(context, rect);
    
    fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGFloat xxx = 3;
    rect = CGRectMake(xxx, xxx, size.width - 2 * xxx, size.height - 2 * xxx);
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage];
    switch (category) {
        case AGEmojiKeyboardViewCategoryImageRecent:
            img = [UIImage imageNamed:@"emote_recent"];
            break;
        case AGEmojiKeyboardViewCategoryImageBell:
            img = [UIImage imageNamed:@"emote_objects"];
            break;
            
        case AGEmojiKeyboardViewCategoryImageCar:
            img = [UIImage imageNamed:@"emote_place"];
            break;
        case AGEmojiKeyboardViewCategoryImageCharacters:
            img = [UIImage imageNamed:@"emote_characters"];
            break;
        case AGEmojiKeyboardViewCategoryImageFace:
            img = [UIImage imageNamed:@"emote_face"];
            break;
        case AGEmojiKeyboardViewCategoryImageFlower:
            img = [UIImage imageNamed:@"emote_nature"];
            break;
        default:
            break;
    }
    
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage];
    switch (category) {
        case AGEmojiKeyboardViewCategoryImageRecent:
            img = [UIImage imageNamed:@"emote_recent"];
            break;
        case AGEmojiKeyboardViewCategoryImageBell:
            img = [UIImage imageNamed:@"emote_objects"];
            break;
            
        case AGEmojiKeyboardViewCategoryImageCar:
            img = [UIImage imageNamed:@"emote_place"];
            break;
        case AGEmojiKeyboardViewCategoryImageCharacters:
            img = [UIImage imageNamed:@"emote_characters"];
            break;
        case AGEmojiKeyboardViewCategoryImageFace:
            img = [UIImage imageNamed:@"emote_face"];
            break;
        case AGEmojiKeyboardViewCategoryImageFlower:
            img = [UIImage imageNamed:@"emote_nature"];
            break;
        default:
            break;
    }
    
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *img = [UIImage imageNamed:@"emote_back"];
//    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self.inputToolbar.contentView.textView deleteBackward];
}

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    self.inputToolbar.contentView.textView.text = [self.inputToolbar.contentView.textView.text stringByAppendingString:emoji];
}

- (void)emojiKeyBoardViewDidPressSendBtn:(AGEmojiKeyboardView *)emojiKeyBoardView {
    if ([self.inputToolbar.contentView.textView hasText]) {
        [self didPressReturnKeyWithMessageText:[self rt_currentlyComposedMessageText] senderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date]];
    }
    
}

#pragma mark - RTVoicePanelViewDelegate
- (void)RTVoicePanelView:(RTVoicePanelView *) speakerPanel audioPath:(NSString *)path duration:(CGFloat)duration {
    
}

@end
