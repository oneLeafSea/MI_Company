//
//  RTChatViewController.m
//  IM
//
//  Created by 郭志伟 on 15/7/14.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTChatViewController.h"
#import "RTMessages.h"
#import "RTFileMediaItem.h"
#import "RTPhotoMediaItem.h"
#import "RTAudioMediaItem.h"
#import "RTMessagesAvatarImage.h"
#import "RTMessagesAvatarImageFactory.h"
#import "UIImageView+common.h"
#import "AppDelegate.h"
#import "RTChatModel.h"
#import "MWPhotoBrowser.h"
#import "NSUUID+StringUUID.h"
#import "UIImage+Common.h"
#import "CTAssetsPickerController.h"
#import <MBProgressHUD.h>
#import "Utils.h"
#import "RTAudioMediaItem.h"
#import "ChatMessageNotification.h"
#import "ChatMessageControllerInfo.h"
#import "UIView+Toast.h"

@interface RTChatViewController() <MWPhotoBrowserDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CTAssetsPickerControllerDelegate>

@property (nonatomic, strong) RTChatModel    *data;

@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, strong) NSString    *curLastMsgId;

@end

@implementation RTChatViewController

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.senderId = USER.uid;
    self.senderDisplayName = USER.name;
    [self setupRightBarItem];
    self.inputToolbar.maximumHeight = 150;
    [RTMessagesCollectionViewCell registerMenuAction:@selector(forward:)];
    self.shouldLoadMoreMessages = YES;
    self.navigationItem.title = self.talkingname;
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"转发"
                                                      action:@selector(forward:)];
    [UIMenuController sharedMenuController].menuItems = @[menuItem];
    [USER.msgHistory getHistoryMessageWithTalkingId:self.talkingId chatMsgType:self.chatMsgType completion:^(BOOL finished, NSArray *chatMsgs) {
        NSArray *msgs = [APP_DELEGATE.user.msgMgr loadDbMsgsWithId:self.talkingId type:self.chatMsgType limit:20 offset:0];
        if (msgs.count > 0) {
            ChatMessage *lastMsg = [msgs objectAtIndex:0];
            self.curLastMsgId = [lastMsg.qid copy];
        }
        self.data = [[RTChatModel alloc] initWithMsgs:msgs];
        [self.collectionView reloadData];
        [self scrollToBottomAnimated:NO];
    }];
    
    self.automaticallyScrollsToMostRecentMessage = NO;
    [self setAudioDirectory:USER.audioPath];
    [self registerNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    ChatMessageControllerInfo *info = [[ChatMessageControllerInfo alloc] init];
    info.talkingId = [self.talkingId copy];
    info.talkingName = [self.talkingname copy];
    info.msgType = self.chatMsgType;
    [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageControllerWillDismiss object:info];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)dealloc {
    [self unregisterNotification];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewMessageNotification:) name:kChatMessageRecvNewMsg object:nil];
}

- (void)unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageRecvNewMsg object:nil];
}

- (void)setupRightBarItem {
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(rightBarButtonItemTapped:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

#pragma mark - private method


#pragma mark - actions
- (void)rightBarButtonItemTapped:(id) sender {
    [self finishSendingMessageAnimated:YES];
}

- (void)customAction:(id)sender {
    
}

- (void)favorite:(id)sender {
    
}

- (void)forward:(id)sender {
    
}


#pragma mark - override
- (void)loadMoreMessage {
    if (self.data.messages.count == 0) {
        return;
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        __block NSInteger l = 0;
        [UIView setAnimationsEnabled:NO];
        [self.collectionView performBatchUpdates:^{
            NSInteger preCount = self.data.messages.count;
            if (self.data.messages.count > 0) {
                [USER.msgHistory getHistoryMessageWithMsgId:self.curLastMsgId chatMsgType:self.chatMsgType talkingId:self.talkingId completion:^(BOOL finished, NSArray *chatMsgs) {
                    NSArray *msgs = [APP_DELEGATE.user.msgMgr loadDbMsgsWithId:self.talkingId type:self.chatMsgType limit:(UInt32)(self.data.messages.count + 20) offset:0];
                    if (msgs.count > 0) {
                        ChatMessage *lastMsg = [msgs objectAtIndex:0];
                        self.curLastMsgId = [lastMsg.qid copy];
                    }
                    self.data = [[RTChatModel alloc] initWithMsgs:msgs];
                    NSInteger count = [self.data.messages count];
                    NSInteger left = count - preCount;
                    l = left;
                    NSMutableArray *idxArr = [[NSMutableArray alloc] init];
                    for (int n = 0; n < left; n++) {
                        [idxArr addObject:[NSIndexPath indexPathForRow:n inSection:0]];
                    }
                    [self.collectionView insertItemsAtIndexPaths:idxArr];
                    if (l > 0) {
                        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:l inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
                    }
                    [UIView setAnimationsEnabled:YES];
                }];
            }
        } completion:^(BOOL finished) {
//            if (l > 0) {
//                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:l inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
//            }
//            [UIView setAnimationsEnabled:YES];
        }];
    });
}

- (void)didPressReturnKeyWithMessageText:(NSString *)text
                                senderId:(NSString *)senderId
                       senderDisplayName:(NSString *)senderDisplayName
                                    date:(NSDate *)date {
    if (!USER.session.isConnected) {
        [Utils alertWithTip:@"程序处于离线状态，暂时无法发送消息。"];
        return;
    }
    if (text.length == 0) {
        return;
    }
    RTMessage *message = [[RTMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    message.status = RTMessageStatusSending;
    [self.data.messages addObject:message];
    [APP_DELEGATE.user.msgMgr sendTextMesage:text msgType:self.chatMsgType to:self.talkingId completion:^(BOOL finished, id arguments) {
        message.status = finished ? RTMessageStatusSent : RTMessageStatusSendError;
        [self finishSendingMessageAnimated:YES];
    }];
    [self finishSendingMessageAnimated:YES];
}


- (id<RTMessageData>)collectionView:(RTMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RTMessage *message = [self.data.messages objectAtIndex:indexPath.row];
    return message;
}

- (id<RTMessageBubbleImageDataSource>)collectionView:(RTMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RTMessage *message = [self.data.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.data.outgoingBubbleImageData;
    }
    
    return self.data.incomingBubbleImageData;
}

- (id<RTMessageAvatarImageDataSource>)collectionView:(RTMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RTMessage *message = [self.data.messages objectAtIndex:indexPath.item];
    UIImage *img = [USER.avatarMgr getAvatarImageByUid:message.senderId];
    RTMessagesAvatarImage *mineImage = [RTMessagesAvatarImageFactory avatarImageWithImage:img
                                                                                   diameter:kRTMessagesCollectionViewAvatarSizeDefault];
    return mineImage;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(forward:) || action == @selector(favorite:)) {
        return YES;
    }
    
    RTMessage *msg = [self.data.messages objectAtIndex:indexPath.row];
    if (msg.isMediaMessage) {
        if (action == @selector(copy:)) {
            return NO;
        }
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(RTMessagesCollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (NSAttributedString *)collectionView:(RTMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    RTMessage *message = [self.data.messages objectAtIndex:indexPath.item];
    if (indexPath.item == 0) {
        return [[RTMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    RTMessage *previousMessage = [self.data.messages objectAtIndex:indexPath.item - 1];
    
    if ([message.date timeIntervalSinceDate:previousMessage.date] > 60) {
        return [[RTMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(RTMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    RTMessage *msg = [self.data.messages objectAtIndex:indexPath.row];
    if (msg.status == RTMessageStatusSending) {
        UIColor *color = [UIColor lightGrayColor];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:@"发送中" attributes:@{NSForegroundColorAttributeName:color}];
        return attr;
    }
    
    if (msg.status == RTMessageStatusSendError) {
        UIColor *color = [UIColor redColor];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:@"发送失败" attributes:@{NSForegroundColorAttributeName:color}];
        return attr;
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(RTMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    RTMessage *message = [self.data.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        RTMessage *previousMessage = [self.data.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (CGFloat)collectionView:(RTMessagesCollectionView *)collectionView
                   layout:(RTMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        return kRTMessagesCollectionViewCellLabelHeightDefault;
    }
    
    RTMessage *previousMessage = [self.data.messages objectAtIndex:indexPath.item - 1];
    RTMessage *message = [self.data.messages objectAtIndex:indexPath.item];
    if ([message.date timeIntervalSinceDate:previousMessage.date] > 60) {
        return kRTMessagesCollectionViewCellLabelHeightDefault;
    }
    return 0.0f;
}

- (CGFloat)collectionView:(RTMessagesCollectionView *)collectionView
                   layout:(RTMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    RTMessage *currentMessage = [self.data.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        RTMessage *previousMessage = [self.data.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kRTMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(RTMessagesCollectionView *)collectionView
                   layout:(RTMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    RTMessage *msg = [self.data.messages objectAtIndex:indexPath.row];
    if (msg.status == RTMessageStatusSendError || msg.status == RTMessageStatusSending) {
        return 20.0f;
    }
    return 0.0f;
}

- (void)collectionView:(RTMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    [super collectionView:collectionView didTapMessageBubbleAtIndexPath:indexPath];
    RTMessage *msg = [self.data.messages objectAtIndex:indexPath.row];
    if ([msg.media isKindOfClass:[RTPhotoMediaItem class]]) {
        RTPhotoMediaItem *photoItem = (RTPhotoMediaItem *)msg.media;
        [self showImgsWithFirstImgUrl:photoItem.orgUrl];
        return;
    }
    
    if ([msg.media isKindOfClass:[RTAudioMediaItem class]]) {
        RTAudioMediaItem *audioItem = (RTAudioMediaItem *)msg.media;
        audioItem.playing = !audioItem.playing;
        return;
    }
    
    
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.data.messages.count;
}

- (UICollectionViewCell *)collectionView:(RTMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RTMessagesCollectionViewCell *cell = (RTMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    
    
    RTMessage *msg = [self.data.messages objectAtIndex:indexPath.row];
    
    if (!msg.isMediaMessage) {
        
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

#pragma mark - config more panel view
- (void)registerMoreItems {
    [super registerMoreItems];
    [self.morePanelView registerItemWithTitle:@"拍照" image:[UIImage imageNamed:@"chatmsg_camera"] target:self action:@selector(takeAPicture)];
    [self.morePanelView registerItemWithTitle:@"照片" image:[UIImage imageNamed:@"chatmsg_pic"] target:self action:@selector(getPhotoFromImgLib)];
//    [self.morePanelView registerItemWithTitle:@"通话" image:[UIImage imageNamed:@"chatmsg_phone"] target:self action:@selector(getPhotoFromImgLib)];
    [self.morePanelView registerItemWithTitle:@"视频" image:[UIImage imageNamed:@"chatmsg_video"] target:self action:@selector(videoChat)];
//    [self.morePanelView registerItemWithTitle:@"文件" image:[UIImage imageNamed:@"chatmsg_folder"] target:self action:@selector(getPhotoFromImgLib)];
    
}

- (void) getPhotoFromImgLib {
    if (!USER.session.isConnected) {
        [Utils alertWithTip:@"程序处于离线状态，暂时无法发送消息。"];
        return;
    }
    self.isMoreKeyboard = NO;
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


- (void) takeAPicture {
    if (!USER.session.isConnected) {
        [Utils alertWithTip:@"程序处于离线状态，暂时无法发送消息。"];
        return;
    }
    self.isMoreKeyboard = NO;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //        imagePicker.allowsEditing = YES;
        
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

- (void)videoChat {
    if (!USER.session.isConnected) {
        [self.collectionView makeToast:@"程序处于离线状态，暂时无法发送消息。"];
        return;
    }
    [USER.webRtcMgr inviteUid:self.talkingId session:USER.session];
}

#pragma mark - CTAssetsPickerControllerDelegate

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
                if (![img saveToPath:thumbPath sz:CGSizeMake(100.0f, 100.0f)]) {
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
                __block RTPhotoMediaItem * item = [[RTPhotoMediaItem alloc] initWithMaskAsOutgoing:YES];
                item.orgUrl = [NSURL fileURLWithPath:[imgInfo[@"imgPath"] copy]];
                item.thumbUrl = [NSURL fileURLWithPath:thumbPath];
                item.status = RTPhotoMediaItemStatusSending;
                RTMessage *msg = [RTMessage messageWithSenderId:USER.uid
                                                    displayName:USER.name
                                                          media:item];
                msg.status = RTMessageStatusSending;
                [self.data.messages addObject:msg];
                [self finishSendingMessageAnimated:YES];
                [USER.msgMgr sendImageMesageWithImgPath:imgInfo[@"imgPath"] uuidName:imgInfo[@"uuid"] imgName:imgInfo[@"imgName"]  msgType:self.chatMsgType to:self.talkingId completion:^(BOOL finished, id argument) {
                    if (finished) {
                        item.status = RTPhotoMediaItemStatusSent;
                        msg.status = RTMessageStatusSent;
                    } else {
                        item.status = RTPhotoMediaItemStatusSendError;
                        msg.status = RTMessageStatusSendError;
                    }
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


#pragma UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //This creates a filepath with the current date/time as the name to save the image
    NSString *imgName = [NSString stringWithFormat:@"%@.jpg", [NSUUID uuid]];
    NSString *fileSavePath = [USER.filePath stringByAppendingPathComponent:imgName];
    NSString *thumbFilePath = [fileSavePath stringByAppendingString:@"_thumb"];
    NSURL *orgUrl = [NSURL fileURLWithPath:fileSavePath];
    NSURL *thumbUrl = [NSURL fileURLWithPath:thumbFilePath];
    UIImage *Img = nil;
    
    //This checks to see if the image was edited, if it was it saves the edited version as a .jpg
    if ([info objectForKey:UIImagePickerControllerEditedImage]) {
        Img = [info objectForKey:UIImagePickerControllerEditedImage];
        
    }else{
        Img = [info objectForKey:UIImagePickerControllerOriginalImage];
        
    }
    
    [Img saveToPath:fileSavePath scale:1.0];
    [Img saveToPath:thumbFilePath sz:CGSizeMake(100.0f, 100.0f)];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        __block RTPhotoMediaItem * item = [[RTPhotoMediaItem alloc] initWithMaskAsOutgoing:YES];
        item.orgUrl = orgUrl;
        item.thumbUrl = thumbUrl;
        item.status = RTPhotoMediaItemStatusSending;
        RTMessage *photoMessage = [RTMessage messageWithSenderId:USER.uid
                                                      displayName:USER.name
                                                           media:item];
        photoMessage.status = RTMessageStatusSending;
        [self.data.messages addObject:photoMessage];
        [self finishSendingMessageAnimated:YES];
        [USER.msgMgr sendImageMesageWithImgPath:fileSavePath uuidName:imgName imgName:imgName  msgType:self.chatMsgType to:self.talkingId completion:^(BOOL finished, id argument) {
            if (finished) {
                item.status = RTPhotoMediaItemStatusSent;
                photoMessage.status = RTMessageStatusSent;
            } else {
                item.status = RTPhotoMediaItemStatusSendError;
                photoMessage.status = RTMessageStatusSendError;
            }
            [self finishSendingMessageAnimated:NO];
        }];
        
    }];
}


#pragma mark -show photobrowser

- (void)showImgsWithFirstImgUrl:(NSURL *)url {
    _photos = [[NSMutableArray alloc] init];
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = NO;
    BOOL startOnGrid = NO;
    __block NSUInteger index = 0;
    __block BOOL found = NO;
    [self.data.messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RTMessage *m = obj;
        if ([m.media isKindOfClass:[RTPhotoMediaItem class]]) {
            RTPhotoMediaItem *item = (RTPhotoMediaItem*)m.media;
            if (item.orgUrl) {
                MWPhoto *photo = [MWPhoto photoWithURL:item.orgUrl];
                [self.photos addObject:photo];
            }
            if ([item.orgUrl isEqual:url]) {
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

#pragma mark - RTVoicePanelViewDelegate
- (void)RTVoicePanelView:(RTVoicePanelView *) speakerPanel audioPath:(NSString *)path duration:(CGFloat)duration {
    __block RTAudioMediaItem *audioMediaItem = [[RTAudioMediaItem alloc] initWithMaskAsOutgoing:YES];
    RTMessage *audioMessage = [RTMessage messageWithSenderId:USER.uid
                                                   displayName:USER.name
                                                         media:audioMediaItem];
    audioMediaItem.status = RTAudioMediaItemStatusSending;
    audioMessage.status = RTMessageStatusSending;
    audioMediaItem.duration = duration;
    audioMediaItem.audioUrl = path;
    [self.data.messages addObject:audioMessage];
    [self finishSendingMessageAnimated:YES];
    
    [USER.msgMgr sendVoiceMesageWithMsgType:self.chatMsgType to:self.talkingId duration:duration audioPath:path completion:^(BOOL finished, id arguments) {
        if (finished) {
            audioMediaItem.status = RTAudioMediaItemtatusSent;
            audioMessage.status = RTMessageStatusSent;
            
        } else {
            audioMediaItem.status = RTAudioMediaItemStatusSendError;
            audioMessage.status = RTMessageStatusSendError;
        }
        [self finishSendingMessageAnimated:NO];
    }];
}

#pragma mark - handle notification
- (void)handleNewMessageNotification:(NSNotification *) notification {
    __block ChatMessage *msg = notification.object;
    if (([msg.from isEqual:self.talkingId] && (msg.chatMsgType == ChatMessageTypeNormal)) || (msg.chatMsgType == ChatMessageTypeGroupChat && [msg.to isEqualToString:self.talkingId])) {
        if ([[msg.body objectForKey:@"type"] isEqualToString:@"text"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
                NSDate *date = [dateFormat dateFromString:msg.time];
                NSString *text = [msg.body objectForKey:@"content"];
                NSNumber *b64 = [msg.body objectForKey:@"b64"];
                if ([b64 boolValue]) {
                    text = [Utils decodeBase64String:text];
                }
                RTMessage *message = [[RTMessage alloc] initWithSenderId:msg.from
                                                         senderDisplayName:[msg.body objectForKey:@"fromname"]
                                                                      date:date
                                                                      text:text];
                [self.data.messages addObject:message];
                [self finishReceivingMessageAnimated:YES];
                [self scrollToBottomAnimated:YES];
            });
        }
    }
    
    if ([[msg.body objectForKey:@"type"] isEqualToString:@"image"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            RTPhotoMediaItem *item = [[RTPhotoMediaItem alloc] initWithMaskAsOutgoing:NO];
            NSString *uuid = [msg.body objectForKey:@"uuid"];
            NSString *orgUrlStr = [USER.fileDownloadSvcUrl stringByAppendingPathComponent:uuid];
            NSString *thumbUrlStr = [USER.imgThumbServerUrl stringByAppendingString:uuid];
            
            item.orgUrl = [NSURL URLWithString:orgUrlStr];
            item.thumbUrl = [NSURL URLWithString:thumbUrlStr];
            item.status = RTPhotoMediaItemStatusRecved;
            RTMessage *photoMessage = [RTMessage messageWithSenderId:msg.from
                                                         displayName:[msg.body objectForKey:@"fromname"]
                                                               media:item];
            photoMessage.status = RTMessageStatusRecved;
            [self.data.messages addObject:photoMessage];
            [self finishReceivingMessageAnimated:YES];
            [self scrollToBottomAnimated:YES];
        });
    }
    
    if ([[msg.body objectForKey:@"type"] isEqualToString:@"voice"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *d = [msg.body objectForKey:@"duration"];
            
            RTAudioMediaItem *item = [[RTAudioMediaItem alloc] initWithMaskAsOutgoing:NO];
            NSString *audioPath = [USER.audioPath stringByAppendingPathComponent:[msg.body objectForKey:@"uuid"]];
            item.audioUrl = audioPath;
            item.duration = [d doubleValue];
            item.status = RTAudioMediaItemStatusRecved;
            RTMessage *audioMsg = [RTMessage messageWithSenderId:msg.from displayName:[msg.body objectForKey:@"fromname"] media:item];
            [self.data.messages addObject:audioMsg];
            [self finishReceivingMessage];
        });
    }

}

@end
