//
//  ChatHistoryMessageViewController.m
//  IM
//
//  Created by 郭志伟 on 15/4/28.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatHistoryMessageViewController.h"
#import "AppDelegate.h"
#import "ChatMessageNotification.h"
#import "ChatMessage.h"
#import "JSQMessage.h"
#import "ChatMessageControllerInfo.h"
#import "ChatSettingTableViewController.h"
#import "ChatMessageMorePanelViewController.h"
#import "ChatMessageMorePanelItemMode.h"
#import "LogLevel.h"
#import "CTAssetsPickerController.h"
#import "Utils.h"
#import "NSUUID+StringUUID.h"
#import "UIImage+Common.h"
#import "MBProgressHUD.h"
#import "MWPhotoBrowser.h"
#import "ChatMessageVoicePanelViewController.h"
#import "AudioPlayer.h"
#import "JSQFileMediaItem.h"
#import "fileBrowerNavigationViewController.h"
#import "NSDate+Common.h"

#import "JSQVoiceMediaItem.h"
#import "JSQVideoChatMediaItem.h"


@interface ChatHistoryMessageViewController ()<MWPhotoBrowserDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate> {
    UIRefreshControl                    *m_refreshControl;
    BOOL                                m_first;
    BOOL                                m_needLoadMore;
}
@property (nonatomic, strong) NSMutableArray *photos;
@end

@implementation ChatHistoryMessageViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.senderId = APP_DELEGATE.user.uid;
    self.senderDisplayName = APP_DELEGATE.user.name;
    self.navigationItem.title = self.talkingname;
    self.navigationItem.rightBarButtonItem = nil;
    
    m_refreshControl = [[UIRefreshControl alloc] init];;
    [self.collectionView addSubview:m_refreshControl];
    [m_refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    self.automaticallyScrollsToMostRecentMessage  = NO;
    m_first = YES;
    self.inputToolbar.hidden = YES;
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMediaMsg:) name:kChatMessageMediaMsgDownload object:nil];
}

- (void)dealloc {
    [USER.msgHistory reset];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageMediaMsgDownload object:nil];
}

- (void)handleRefresh {
    [USER.msgHistory loadMoreWithTalkingId:_talkingId chatMsgType:self.chatMsgType Completion:^(BOOL finished, NSArray *chatMsgs) {
        if (finished) {
            __block CGFloat oldTableViewHeight = self.collectionView.contentSize.height;
            
            [self.collectionView performBatchUpdates:^{
                NSInteger preCount = self.data.messages.count;
                NSMutableArray *delIndexs = [[NSMutableArray alloc] init];
                for (int n = 0; n < preCount; n++) {
                    [delIndexs addObject:[NSIndexPath indexPathForRow:n inSection:0]];
                }
                [self.collectionView deleteItemsAtIndexPaths:delIndexs];
                self.data = [[ChatModel alloc] initWithMsgs:chatMsgs];
                NSInteger count = [chatMsgs count];
                NSMutableArray *idxArr = [[NSMutableArray alloc] init];
                for (int n = 0; n < count; n++) {
                    [idxArr addObject:[NSIndexPath indexPathForRow:n inSection:0]];
                }
                [self.collectionView insertItemsAtIndexPaths:idxArr];
            } completion:^(BOOL finished) {
                CGFloat newTableViewHeight = self.collectionView.contentSize.height;
                self.collectionView.contentOffset = CGPointMake(0, newTableViewHeight - oldTableViewHeight);
            }];
        }
        [m_refreshControl endRefreshing];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (m_first) {
        [m_refreshControl beginRefreshing];
        [USER.msgHistory getHistoryMessageWithTalkingId:self.talkingId chatMsgType:_chatMsgType completion:^(BOOL finished, NSArray *chatMsgs) {
            if (finished) {
                self.data = [[ChatModel alloc] initWithMsgs:chatMsgs];
                [self.collectionView reloadData];
                [self scrollToBottomAnimated:NO];
            }
            [m_refreshControl endRefreshing];
        }];
        m_first = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    
}

- (void)handleMediaMsg:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        ChatMessage *msg = (ChatMessage *)notification.object;
        for (JSQMessage *m in self.data.messages) {
            if ([m.media isKindOfClass:[JSQPhotoMediaItem class]]) {
                JSQPhotoMediaItem *item = (JSQPhotoMediaItem *)m.media;
                if ([msg.qid isEqualToString:item.msgId]) {
                    item.imgPath = [USER.filePath stringByAppendingPathComponent:[msg.body objectForKey:@"uuid"]];
                    NSString *thumbPath = [item.imgPath stringByAppendingString:@"_thumb"];
                    item.image = [UIImage imageWithContentsOfFile:thumbPath];
                    [self.collectionView reloadData];
                }
            }
            
            if ([m.media isKindOfClass:[JSQVoiceMediaItem class]]) {
                JSQVoiceMediaItem *item = (JSQVoiceMediaItem *)m.media;
                if ([msg.qid isEqualToString:item.msgId]) {
                    item.isReady = YES;
                    [self.collectionView reloadData];
                }
            }
        }
        
    });
}


- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.data.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.data.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.data.outgoingBubbleImageData;
    }
    
    return self.data.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.data.messages objectAtIndex:indexPath.item];
    UIImage *img = [USER.avatarMgr getAvatarImageByUid:message.senderId];
    JSQMessagesAvatarImage *mineImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:img
                                                                                   diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    return mineImage;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.data.messages objectAtIndex:indexPath.item];
    if (indexPath.item == 0) {
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    JSQMessage *previousMessage = [self.data.messages objectAtIndex:indexPath.item - 1];
    
    if ([message.date timeIntervalSinceDate:previousMessage.date] > 60) {
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.data.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.data.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.data.messages.count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    JSQMessage *msg = [self.data.messages objectAtIndex:indexPath.item];
    
    if (msg.isMediaMessage) {
        if ([msg.media isKindOfClass:[JSQPhotoMediaItem class]]) {
//            DDLogInfo(@"Photo Msg.");
        }
        if ([msg.media isKindOfClass:[JSQVoiceMediaItem class]]) {
//            DDLogInfo(@"Voice msg");
        }
        
        if ([msg.media isKindOfClass:[JSQFileMediaItem class]]) {
//            DDLogInfo(@"File msg");
        }
    } else {
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        return kJSQMessagesCollectionViewAvatarSizeDefault;
    }
    
    JSQMessage *previousMessage = [self.data.messages objectAtIndex:indexPath.item - 1];
    JSQMessage *message = [self.data.messages objectAtIndex:indexPath.item];
    if ([message.date timeIntervalSinceDate:previousMessage.date] > 60) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    return 0.0f;
}


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *currentMessage = [self.data.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.data.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}


#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *msg = [self.data.messages objectAtIndex:indexPath.row];
    if ([msg.media isKindOfClass:[JSQPhotoMediaItem class]]) {
        JSQPhotoMediaItem *item = (JSQPhotoMediaItem *)msg.media;
        if (item.imgPath) {
            [self showImageWithPath:item.imgPath];
        }
    }
    
    if ([msg.media isKindOfClass:[JSQVoiceMediaItem class]]) {
        JSQVoiceMediaItem *item = (JSQVoiceMediaItem *)msg.media;
        if (item.isReady) {
            if (item.playing) {
                item.playing = NO;
                [[AudioPlayer sharePlayer] stop];
            } else {
                item.playing = YES;
                [[AudioPlayer sharePlayer] stop];
                [[AudioPlayer sharePlayer] playWithPath:item.filePath completion:^(BOOL finished) {
                    item.playing = NO;
                }];
            }
        }
    }
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    [self jsq_setToolbarBottomLayoutGuideConstant:0];
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

- (JSQPhotoMediaItem *)addPhotoMsgWithPath:(NSString *)thumbImgPath
                                  outgoing:(BOOL)outgoing
                                       uid:(NSString *)uid
                               displayName:(NSString *)name
                                     msgId:(NSString *)msgId{
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithMaskAsOutgoing:outgoing];
    photoItem.msgId = [msgId copy];
    photoItem.image = thumbImgPath ? [UIImage imageWithContentsOfFile:thumbImgPath] : nil;
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:uid
                                                   displayName:name
                                                         media:photoItem];
    [self.data.messages addObject:photoMessage];
    return photoItem;
}

- (JSQVoiceMediaItem *)addVoiceMsgWithPath:(NSString *)voicePath
                                  outgoing:(BOOL)outgoing
                                  duration:(double)duration
                                       uid:(NSString *)uid
                               displayName:(NSString *)name
                                     msgId:(NSString *)msgId {
    JSQVoiceMediaItem *voiceItem = [[JSQVoiceMediaItem alloc] initWithFilePath:voicePath isReady:YES duration:duration outgoing:outgoing msgId:msgId];
    JSQMessage *voiceMsg = [JSQMessage messageWithSenderId:uid displayName:name media:voiceItem];
    [self.data.messages addObject:voiceMsg];
    return voiceItem;
}

- (void)addFileMsg:(ChatMessage *)msg {
    NSString *uuid = [msg.body objectForKey:@"uuid"];
    NSString *filePath = [USER.filePath stringByAppendingPathComponent:uuid];
    BOOL isDownloaded = ((msg.status == ChatMessageStatusRecved) || (msg.status == ChatMessageStatusSent));
    NSString* sz = [msg.body objectForKey:@"filesize"];
    NSString *fileName = [msg.body objectForKey:@"filename"];
    unsigned long long filesz = [sz integerValue];
    JSQFileMediaItem *fileItem = [[JSQFileMediaItem alloc] initWithFilePath:filePath fileSz:filesz uuid:uuid fileName:fileName isReady:isDownloaded outgoing:[msg.from isEqualToString:USER.uid] ? YES : NO];
    JSQMessage *fileMsg = [JSQMessage messageWithSenderId:msg.from displayName:[msg.body objectForKey:@"fromname"] media:fileItem];
    [self.data.messages addObject:fileMsg];
}


#pragma mark show image
- (void) showImageWithPath:(NSString *)imagePath {
    self.photos = [[NSMutableArray alloc] init];
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    enableGrid = NO;
    
    __block NSUInteger index = 0;
    __block BOOL found = NO;
    [self.data.messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        JSQMessage *m = obj;
        if ([m.media isKindOfClass:[JSQPhotoMediaItem class]]) {
            JSQPhotoMediaItem *item = (JSQPhotoMediaItem*)m.media;
            if (item.imgPath) {
                MWPhoto *photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:item.imgPath]];
                [self.photos addObject:photo];
            }
            if ([item.imgPath isEqualToString:imagePath]) {
                found = YES;
            }
            if (!found) {
                index++;
            }
            
        }
    }];
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:index];
    [self.navigationController pushViewController:browser animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

@end
