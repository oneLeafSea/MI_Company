//
//  RTMessagesViewController.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RTMessagesCollectionView.h"
#import "RTMessagesCollectionViewFlowLayout.h"

#import "RTMessagesInputToolbar.h"
#import "RTMessagesKeyboardController.h"
#import "AGEmojiKeyBoardView.h"
#import "RTMorePanelView.h"
#import "RTVoicePanelView.h"

@interface RTMessagesViewController : UIViewController <RTMessagesCollectionViewDataSource, RTMessagesCollectionViewDelegateFlowLayout, UITextViewDelegate>

@property(weak, nonatomic, readonly) RTMessagesCollectionView *collectionView;

@property (weak, nonatomic, readonly) RTMessagesInputToolbar *inputToolbar;

@property (strong, nonatomic) RTMessagesKeyboardController *keyboardController;

@property (nonatomic, readonly) RTMorePanelView *morePanelView;

@property (copy, nonatomic) NSString *senderDisplayName;

@property (copy, nonatomic) NSString *senderId;

@property (assign, nonatomic) BOOL automaticallyScrollsToMostRecentMessage;

@property (copy, nonatomic) NSString *outgoingCellIdentifier;

@property (copy, nonatomic) NSString *outgoingMediaCellIdentifier;

@property (copy, nonatomic) NSString *incomingCellIdentifier;

@property (copy, nonatomic) NSString *incomingMediaCellIdentifier;

@property (assign, nonatomic) BOOL showTypingIndicator;

@property (assign, nonatomic) BOOL showLoadEarlierMessagesHeader;

@property (assign, nonatomic) BOOL shouldLoadMoreMessages;

@property (assign, nonatomic) CGFloat topContentAdditionalInset;

@property (assign, nonatomic) BOOL isMoreKeyboard;

- (void)setAudioDirectory:(NSString *)audioDirectory;

+ (UINib *)nib;

+ (instancetype)messagesViewController;

- (void)didPressReturnKeyWithMessageText:(NSString *)text
                                senderId:(NSString *)senderId
                       senderDisplayName:(NSString *)senderDisplayName
                                    date:(NSDate *)date;

- (void)didPressLeftButton:(UIButton *)sender;
- (void)didPressRightButton:(UIButton *)sender;

- (void)didPressMidButton:(UIButton *)sender;

- (void)finishSendingMessage;

- (void)finishSendingMessageAnimated:(BOOL)animated emptyTxtView:(BOOL)empty;

- (void)finishReceivingMessage;

- (void)finishReceivingMessageAnimated:(BOOL)animated;

- (void)scrollToBottomAnimated:(BOOL)animated;

- (void)loadMoreMessage;

- (void)registerMoreItems;

- (void)RTVoicePanelView:(RTVoicePanelView *) speakerPanel audioPath:(NSString *)path duration:(CGFloat)duration;


@end
