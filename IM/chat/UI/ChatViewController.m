//
//  ChatViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatViewController.h"
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
#import "GroupChatSettingTableViewController.h"
#import "NSDate+Common.h"


#import "JSQVoiceMediaItem.h"
#import "JSQVideoChatMediaItem.h"

@interface ChatViewController () <CTAssetsPickerControllerDelegate, MWPhotoBrowserDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChatMessageVoicePanelViewControllerDelegate, fileBrowerNavigationViewControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate> {
    ChatMessageMorePanelViewController  *m_morePanel;
    ChatMessageVoicePanelViewController *m_voicePanel;
    __weak IBOutlet UIBarButtonItem     *rightBtn;
    UIRefreshControl                    *m_refreshControl;
    BOOL                                m_first;
    BOOL                                m_needLoadMore;
}

@property (nonatomic, strong) NSMutableArray *photos;
@end

@implementation ChatViewController


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
    NSArray *msgs = [APP_DELEGATE.user.msgMgr loadDbMsgsWithId:self.talkingId type:self.chatMsgType limit:50 offset:0];
    self.data = [[ChatModel alloc] initWithMsgs:msgs];
    self.navigationItem.title = self.talkingname;
    [self setMorePanel];
    [self setVoicePanel];
    if (self.chatMsgType == ChatMessageTypeNormal) {
        if (![USER.rosterMgr exsitsItemByUid:self.talkingId]) {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CollectionViewDidTapped)];
    [self.collectionView addGestureRecognizer:tapGesture];
    m_refreshControl = [[UIRefreshControl alloc] init];;
    [self.collectionView addSubview:m_refreshControl];
    [m_refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    self.automaticallyScrollsToMostRecentMessage  = NO;
    m_first = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewMessageNotification:) name:kChatMessageRecvNewMsg object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleImageFileReceived:) name:kChatMessageImageFileReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVideoMsgNotification:) name:kChatMessageVideoChatMsg object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageImageFileReceived object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageRecvNewMsg object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageVideoChatMsg object:nil];
}

- (void)handleRefresh {
    if (![self needRefresh]) {
        [m_refreshControl endRefreshing];
        [m_refreshControl removeFromSuperview];
        [m_refreshControl removeTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
        return;
    }
    __block CGFloat oldTableViewHeight = self.collectionView.contentSize.height;
    [UIView setAnimationsEnabled:NO];
    [self.collectionView performBatchUpdates:^{
        NSUInteger count = self.data.messages.count;
        NSMutableArray *arrayWithIndexPathsInsert = [NSMutableArray array];
        [self loadMore];
        NSUInteger newItemCount = self.data.messages.count;
        for (int n = 0; n < newItemCount - count; n++) {
            [arrayWithIndexPathsInsert addObject:[NSIndexPath indexPathForRow:n inSection:0]];
        }
        [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPathsInsert];
    } completion:^(BOOL finished) {
        CGFloat newTableViewHeight = self.collectionView.contentSize.height;
        self.collectionView.contentOffset = CGPointMake(0, newTableViewHeight - oldTableViewHeight);
        [m_refreshControl endRefreshing];
    }];
    [UIView setAnimationsEnabled:YES];
    
}

- (BOOL)needRefresh {
    NSArray *msgs = [APP_DELEGATE.user.msgMgr loadDbMsgsWithId:self.talkingId type:self.chatMsgType limit:(UInt32)(self.data.messages.count + 50) offset:0];
    if (self.data.messages.count == msgs.count) {
        return NO;
    }
    return YES;
}

- (void)loadMore {
    NSArray *msgs = [APP_DELEGATE.user.msgMgr loadDbMsgsWithId:self.talkingId type:self.chatMsgType limit:(UInt32)(self.data.messages.count + 50) offset:0];
    self.data = [[ChatModel alloc] initWithMsgs:msgs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (m_first) {
        [self.collectionView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        m_first = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    ChatMessageControllerInfo *info = [[ChatMessageControllerInfo alloc] init];
    info.talkingId = [self.talkingId copy];
    info.talkingName = [self.talkingname copy];
    info.msgType = self.chatMsgType;
    [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageControllerWillDismiss object:info];
}

- (void)didPressReturnKeyWithMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    if (text.length == 0) {
        return;
    }
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    [self.data.messages addObject:message];
    [APP_DELEGATE.user.msgMgr sendTextMesage:text msgType:self.chatMsgType to:self.talkingId completion:^(BOOL finished, id arguments) {
        NSLog(@"send to %@, %@", self.talkingId, text);
        
    }];
    [self finishSendingMessageAnimated:YES];
}

- (void)CollectionViewDidTapped {
    [self.inputToolbar.contentView.textView resignFirstResponder];
    [self jsq_setToolbarBottomLayoutGuideConstant:0];
}


- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    
    [self endListeningForKeyboard];
    [self.inputToolbar.contentView.textView resignFirstResponder];
    [self jsq_setToolbarBottomLayoutGuideConstant:230];
    m_voicePanel.view.hidden = NO;
    m_morePanel.view.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self beginListeningForKeyboard];
    });
    [self scrollToBottomAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self endListeningForKeyboard];
    [self.inputToolbar.contentView.textView resignFirstResponder];
    [self jsq_setToolbarBottomLayoutGuideConstant:230];
    m_voicePanel.view.hidden = YES;
    m_morePanel.view.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self beginListeningForKeyboard];
    });
    [self scrollToBottomAnimated:YES];
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
            DDLogInfo(@"Photo Msg.");
        }
        if ([msg.media isKindOfClass:[JSQVoiceMediaItem class]]) {
            DDLogInfo(@"Voice msg");
        }
        
        if ([msg.media isKindOfClass:[JSQFileMediaItem class]]) {
            DDLogInfo(@"File msg");
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
    if ([msg.media isKindOfClass:[JSQVideoChatMediaItem class]]) {
        UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"进行通话" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"通话" otherButtonTitles:nil];
        [as showInView:self.view];
    }
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    [self jsq_setToolbarBottomLayoutGuideConstant:0];
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - handle message notification

- (void)handleVideoMsgNotification:(NSNotification *)notification {
    __block ChatMessage *msg = notification.object;
    if ([msg.to isEqualToString:self.talkingId] && self.chatMsgType == ChatMessageTypeNormal) {
        NSString *tip = @"通话未接通";
        NSNumber *n = [msg.body objectForKey:@"connected"];
        BOOL connected = [n boolValue];
        NSUInteger interval = [[msg.body objectForKey:@"interval"] integerValue];
        if (connected) {
            tip = [NSString stringWithFormat:@"通话时长%02d:%02d", interval/60, interval%60];
        }
        NSDate *date = [NSDate dateWithFormater:@"yyyy-MM-dd HH:mm:ss.SSSSSS" stringTime:msg.time];
        JSQVideoChatMediaItem *item = [[JSQVideoChatMediaItem alloc] initWithTip:tip];
        item.appliesMediaViewMaskAsOutgoing = [USER.uid isEqualToString:msg.from];
        JSQMessage *videoChatMsg = [[JSQMessage alloc] initWithSenderId:msg.from senderDisplayName:[msg.body objectForKey:@"fromname"] date:date media:item];
        [self.data.messages addObject:videoChatMsg];
        [self.collectionView performBatchUpdates:^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.data.messages.count - 1 inSection:0];
            [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        } completion:^(BOOL finished) {
            [self scrollToBottomAnimated:YES];
        }];
    }
}

- (void)handleNewMessageNotification:(NSNotification *) notification {
    __block ChatMessage *msg = notification.object;
    if (([msg.from isEqual:self.talkingId] && (msg.chatMsgType == ChatMessageTypeNormal)) || (msg.chatMsgType == ChatMessageTypeGroupChat && [msg.to isEqualToString:self.talkingId])) {
        if ([[msg.body objectForKey:@"type"] isEqualToString:@"text"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
                NSDate *date = [dateFormat dateFromString:msg.time];
                NSString *text = [msg.body objectForKey:@"content"];
                JSQMessage *message = [[JSQMessage alloc] initWithSenderId:msg.from
                                                         senderDisplayName:[msg.body objectForKey:@"fromname"]
                                                                      date:date
                                                                      text:text];
                [self.data.messages addObject:message];
                [self finishReceivingMessageAnimated:YES];
            });
        }
        
        if ([[msg.body objectForKey:@"type"] isEqualToString:@"image"]) {
            __block JSQPhotoMediaItem * item = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                item = [self addPhotoMsgWithPath:nil outgoing:NO uid:msg.from displayName:[msg.body objectForKey:@"fromname"] msgId:nil];
                item.msgId = msg.qid;
                [self finishReceivingMessageAnimated:YES];
            });
        }
        
        if ([[msg.body objectForKey:@"type"] isEqualToString:@"voice"]) {
            __block JSQVoiceMediaItem *item = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *d = [msg.body objectForKey:@"duration"];
                item = [self addVoiceMsgWithPath:[USER.audioPath stringByAppendingPathComponent:[msg.body objectForKey:@"uuid"]] outgoing:NO duration:[d integerValue] uid:msg.from displayName:[msg.body objectForKey:@"fromname"] msgId:msg.qid];
                [self finishReceivingMessage];
            });
        }
        
        if ([[msg.body objectForKey:@"type"] isEqualToString:@"file"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addFileMsg:msg];
                [self finishReceivingMessage];
            });
        }
    }
}

- (void)handleImageFileReceived:(NSNotification *)notifycation {
    dispatch_async(dispatch_get_main_queue(), ^{
        ChatMessage *msg = notifycation.object;
        for (JSQMessage *m in self.data.messages) {
            if ([m.media isKindOfClass:[JSQPhotoMediaItem class]]) {
                JSQPhotoMediaItem *item = (JSQPhotoMediaItem *)m.media;
                if ([msg.qid isEqualToString:item.msgId]) {
                    item.imgPath = [USER.filePath stringByAppendingPathComponent:[msg.body objectForKey:@"uuid"]];
                    NSString *thumbPath = [item.imgPath stringByAppendingString:@"_thumb"];
                    item.image = [UIImage imageWithContentsOfFile:thumbPath];
                    [self finishReceivingMessage];
                    break;
                }
            }
        }
    });
}

- (IBAction)toChatSetting:(id)sender {
    if (self.chatMsgType == ChatMessageTypeNormal) {
        ChatSettingTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatSettingTableViewController"];
        vc.rosterItem = [APP_DELEGATE.user.rosterMgr getItemByUid:self.talkingId];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        GroupChat *grpChat = [USER.groupChatMgr getGrpChatByGid:self.talkingId];
        GroupChatSettingTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupChatSettingTableViewController"];
        vc.grp = grpChat;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}




- (void) setMorePanel {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    ChatMessageMorePanelItemMode *item = [[ChatMessageMorePanelItemMode alloc] initWithTitle:@"拍照" imageName:@"chatmsg_camera" target:self selector:@selector(takeAPicture)];
    [arr addObject:item];
    item = [[ChatMessageMorePanelItemMode alloc] initWithTitle:@"照片" imageName:@"chatmsg_pic" target:self selector:@selector(getPhotoFromImgLib)];
    [arr addObject:item];
    if (self.chatMsgType == ChatMessageTypeNormal ) {
        item = [[ChatMessageMorePanelItemMode alloc] initWithTitle:@"通话" imageName:@"chatmsg_phone" target:self selector:@selector(audioChat)];
        [arr addObject:item];
        item = [[ChatMessageMorePanelItemMode alloc] initWithTitle:@"视频" imageName:@"chatmsg_video" target:self selector:@selector(videoChat)];
        [arr addObject:item];
    }
    item = [[ChatMessageMorePanelItemMode alloc] initWithTitle:@"文件" imageName:@"chatmsg_folder" target:self selector:@selector(transferFile)];
    [arr addObject:item];
    m_morePanel = [[ChatMessageMorePanelViewController alloc] initWithPanelItems:arr];
    [self addChildViewController:m_morePanel];
    [self.view addSubview:m_morePanel.view];
    [self setMorePanelConstraint];
}


- (void) setMorePanelConstraint {
    UIView *view = m_morePanel.view;
    JSQMessagesInputToolbar *toolBar = self.inputToolbar;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(view, toolBar);
    view.translatesAutoresizingMaskIntoConstraints = NO;
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolBar][view(==230)]" options:0 metrics:nil views:viewsDictionary]];
}

- (void)setVoicePanel {
    m_voicePanel = [[ChatMessageVoicePanelViewController alloc] initWithNibName:@"ChatMessageVoicePanelViewController" bundle:nil];
    m_voicePanel.delegate = self;
    m_voicePanel.voiceDir = USER.audioPath;
    [self addChildViewController:m_voicePanel];
    [self.view addSubview:m_voicePanel.view];
    [self setVoicePanelConstraints];
}

- (void)setVoicePanelConstraints {
    UIView *view = m_voicePanel.view;
    JSQMessagesInputToolbar *toolBar = self.inputToolbar;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(view, toolBar);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolBar][view(==230)]" options:0 metrics:nil views:viewsDictionary]];
}

- (void)takeAPicture {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Camera Unavailable"
                                                       message:@"Unable to find a camera on your device."
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
    }
}

- (void)getPhotoFromImgLib {
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showsCancelButton    = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad);
    picker.delegate             = self;
    picker.selectedAssets       = [[NSMutableArray alloc] init];
    
    // iPad
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        [self presentViewController:picker animated:YES completion:nil];
    }
    
}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y <= 44) {
//        if (![self needRefresh]) {
//            return;
//        }
//        __block CGFloat oldTableViewHeight = self.collectionView.contentSize.height;
//        [UIView setAnimationsEnabled:NO];
//        [self.collectionView performBatchUpdates:^{
//            NSUInteger count = self.data.messages.count;
//            NSMutableArray *arrayWithIndexPathsInsert = [NSMutableArray array];
//            [self loadMore];
//            NSUInteger newItemCount = self.data.messages.count;
//            for (int n = 0; n < newItemCount - count; n++) {
//                [arrayWithIndexPathsInsert addObject:[NSIndexPath indexPathForRow:n inSection:0]];
//            }
//            [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPathsInsert];
//        } completion:^(BOOL finished) {
//            CGFloat newTableViewHeight = self.collectionView.contentSize.height;
//            self.collectionView.contentOffset = CGPointMake(0, newTableViewHeight - oldTableViewHeight);
//        }];
//        [UIView setAnimationsEnabled:YES];
//    }
//}

//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//   
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//}


- (void)videoChat {
    [USER.webRtcMgr inviteUid:self.talkingId session:USER.session];
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
}

- (void)audioChat {
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
}

- (void)transferFile {
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    fileBrowerNavigationViewController *fileBrowser = [self.storyboard instantiateViewControllerWithIdentifier:@"fileBrowserViewController"];
    fileBrowser.filePath = USER.filePath;
    fileBrowser.fileBrowserDelegate = self;
    [self presentViewController:fileBrowser animated:YES completion:nil];
}

#pragma mark <CTAssetsPickerControllerDelegate>

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:picker.view animated:YES];
    hud.labelText = @"请稍后";
    __block NSMutableArray *imgInfoArr = [[NSMutableArray alloc] init];
    __block BOOL ret = YES;
    [hud showAnimated:YES whileExecutingBlock:^{
        for (ALAsset *asset in assets) {
            if (asset.defaultRepresentation) {
                UIImage * img = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage scale:0.1 orientation:UIImageOrientationUp];
                NSString *imgName = asset.defaultRepresentation.filename;
                NSString *uuidName = [NSString stringWithFormat:@"%@.jpg", [NSUUID uuid]];
                NSString *imagePath = [APP_DELEGATE.user.filePath stringByAppendingPathComponent:uuidName];
                NSString *thumbPath = [imagePath stringByAppendingString:@"_thumb"];
                
                if (![img saveToPath:imagePath scale:0.1]) {
                    ret = NO;
                    break;
                }
                if (![img saveToPath:thumbPath sz:CGSizeMake(100.0f, 135.0f)]) {
                    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
                    ret = NO;
                    break;
                }
                NSDictionary *imgInfo = @{@"uuid":uuidName, @"imgName":imgName, @"imgPath":imagePath, @"thumbPath":thumbPath};
                [imgInfoArr addObject:imgInfo];
            }
        }
    } completionBlock:^{
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        if (!ret) {
            [Utils alertWithTip:@"保存图像失败。"];
        } else {
            for (NSDictionary *imgInfo in imgInfoArr) {
                __block NSString *thumbPath = [imgInfo[@"thumbPath"] copy];
                __block JSQPhotoMediaItem * item = [self addPhotoMsgWithPath:nil outgoing:YES uid:USER.uid displayName:USER.name msgId:nil];
                [self finishSendingMessageAnimated:YES];
                [USER.msgMgr sendImageMesageWithImgPath:imgInfo[@"imgPath"] uuidName:imgInfo[@"uuid"] imgName:imgInfo[@"imgName"]  msgType:self.chatMsgType to:self.talkingId completion:^(BOOL finished, id argument) {
                    item.image = [UIImage imageWithContentsOfFile:thumbPath];
                    item.imgPath = [imgInfo[@"imgPath"] copy];
                    [self finishSendingMessageAnimated:NO];
                }];
            }
        }
    }];
    
    
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group
{
    return ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos);
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(ALAsset *)asset
{
    // Enable video clips if they are at least 5s
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= 5;
    }
    else {
        return YES;
    }
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    if (picker.selectedAssets.count >= 10)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"提示"
                                   message:@"最多只能选择10张。"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"我知道了", nil];
        
        [alertView show];
    }
    
    if (!asset.defaultRepresentation)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Your asset has not yet been downloaded to your device"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    return (picker.selectedAssets.count < 10 && asset.defaultRepresentation != nil);
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
    JSQVoiceMediaItem *voiceItem = [[JSQVoiceMediaItem alloc] initWithFilePath:voicePath isReady:YES duration:duration outgoing:outgoing];
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


#pragma UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //This creates a filepath with the current date/time as the name to save the image
    NSString *imgName = [NSString stringWithFormat:@"%@.jpg", [NSUUID uuid]];
    NSString *fileSavePath = [USER.filePath stringByAppendingPathComponent:imgName];
    NSString *thumbFilePath = [fileSavePath stringByAppendingString:@"_thumb"];
    UIImage *Img = nil;
    
    //This checks to see if the image was edited, if it was it saves the edited version as a .jpg
    if ([info objectForKey:UIImagePickerControllerEditedImage]) {
        Img = [info objectForKey:UIImagePickerControllerEditedImage];
        
    }else{
        Img = [info objectForKey:UIImagePickerControllerOriginalImage];
        
    }
    
    [Img saveToPath:fileSavePath scale:1.0];
    [Img saveToPath:thumbFilePath sz:CGSizeMake(100.0f, 135.0f)];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        __block JSQPhotoMediaItem * item = [self addPhotoMsgWithPath:nil outgoing:YES uid:USER.uid displayName:USER.name msgId:nil];
        [self finishSendingMessageAnimated:YES];
        [USER.msgMgr sendImageMesageWithImgPath:fileSavePath uuidName:imgName imgName:imgName  msgType:self.chatMsgType to:self.talkingId completion:^(BOOL finished, id argument) {
            item.image = [UIImage imageWithContentsOfFile:thumbFilePath];
            item.imgPath = [fileSavePath copy];
            [self finishSendingMessageAnimated:NO];
        }];
        
    }];
}

#pragma mark -ChatMessageVoicePanelViewControllerDelegate
- (void)ChatMessageVoicePanelViewController:(ChatMessageVoicePanelViewController *)voicePanelVc recordCompleteAtPath:(NSString *)audioPath duration:(double)duration {
    __block JSQVoiceMediaItem *voiceMediaItem = [[JSQVoiceMediaItem alloc] initWithFilePath:audioPath isReady:YES duration:duration outgoing:YES];
    voiceMediaItem.isReady = NO;
    JSQMessage *voiceMessage = [JSQMessage messageWithSenderId:USER.uid
                                                   displayName:USER.name
                                                         media:voiceMediaItem];
    [self.data.messages addObject:voiceMessage];
    [self finishSendingMessageAnimated:YES];
    
    [USER.msgMgr sendVoiceMesageWithMsgType:self.chatMsgType to:self.talkingId duration:duration audioPath:audioPath completion:^(BOOL finished, id arguments) {
        if (finished) {
            voiceMediaItem.isReady = YES;
            [self.collectionView reloadData];
        }
    }];
    
}


- (void)ChatMessageVoicePanelViewController:(ChatMessageVoicePanelViewController *)voicePanelVc recordFail:(NSError *)error {

}

#pragma mark -<fileBrowerNavigationViewControllerDelegate>
- (void)fileBrowerNavigationViewController:(fileBrowerNavigationViewController *)fileBrowser selectedPaths:(NSArray *)paths {
    [fileBrowser dismissViewControllerAnimated:YES completion:^{
    
        for (NSString *filePath in paths) {
            __block JSQFileMediaItem *item = [self addFileMsgWithFilePath:filePath outgoing:YES uid:USER.uid];
            [self finishSendingMessageAnimated:YES];
            [USER.msgMgr sendFileMessageWithFilePath:filePath msgType:self.chatMsgType to:self.talkingId completion:^(BOOL finished, id argument) {
                item.isReady = YES;
                [self.collectionView reloadData];
            }];
        }
        
    }];
}

- (JSQFileMediaItem *)addFileMsgWithFilePath:(NSString *)filePath outgoing:(BOOL)outgoing uid:(NSString *)uid {
    unsigned long long fileSz = [Utils fileSizeAtPath:filePath error:nil];
    JSQFileMediaItem *fileItem = [[JSQFileMediaItem alloc] initWithFilePath:filePath fileSz:fileSz uuid:[filePath lastPathComponent] fileName:[filePath lastPathComponent] isReady:NO outgoing:outgoing];
    JSQMessage *fileMsg = [JSQMessage messageWithSenderId:uid displayName:USER.name media:fileItem];
    [self.data.messages addObject:fileMsg];
    return fileItem;
}

#pragma makr -UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [USER.webRtcMgr inviteUid:self.talkingId session:USER.session];
    }
}

@end
