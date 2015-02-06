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

@interface ChatViewController () <CTAssetsPickerControllerDelegate, MWPhotoBrowserDelegate> {
    ChatMessageMorePanelViewController *m_morePanel;
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
    NSArray *msgs = [APP_DELEGATE.user.msgMgr loadDbMsgsWithId:self.talkingId type:ChatMessageTypeNormal limit:20 offset:0];
    self.data = [[ChatModel alloc] initWithMsgs:msgs];
    self.navigationItem.title = self.talkingname;
    [self setMorePanel];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewMessageNotification:) name:kChatMessageRecvNewMsg object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleImageFileReceived:) name:kChatMessageImageFileReceived object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageRecvNewMsg object:nil];
    ChatMessageControllerInfo *info = [[ChatMessageControllerInfo alloc] init];
    info.talkingId = [self.talkingId copy];
    info.talkingName = [self.talkingname copy];
    info.msgType = self.chatMsgType;
    [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageControllerWillDismiss object:info];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageImageFileReceived object:nil];
}


- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    [self.data.messages addObject:message];
    [APP_DELEGATE.user.msgMgr sendTextMesage:text msgType:ChatMessageTypeNormal to:self.talkingId completion:^(BOOL finished, id arguments) {
        NSLog(@"send to %@, %@", self.talkingId, text);
        
    }];
    [self finishSendingMessageAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self endListeningForKeyboard];
    [self.inputToolbar.contentView.textView resignFirstResponder];
    [self jsq_setToolbarBottomLayoutGuideConstant:230];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self beginListeningForKeyboard];
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
//    JSQMessage *message = [self.data.messages objectAtIndex:indexPath.item];
    JSQMessagesAvatarImage *mineImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"avatar_default"]
                                                                                  diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    return mineImage;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.data.messages objectAtIndex:indexPath.item];
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
        DDLogCInfo(@"media Message");
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
    if (indexPath.item % 3 == 0) {
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
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    [self jsq_setToolbarBottomLayoutGuideConstant:0];
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - handle message notification

- (void)handleNewMessageNotification:(NSNotification *) notification {
    ChatMessage *msg = notification.object;
     if ([[msg.body objectForKey:@"type"] isEqualToString:@"text"]) {
         dispatch_sync(dispatch_get_main_queue(), ^{
             NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
             [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
             NSDate *date = [dateFormat dateFromString:msg.time];
             NSString *text = [msg.body objectForKey:@"content"];
             if ([msg.from isEqualToString:self.talkingId]) {
                 JSQMessage *message = [[JSQMessage alloc] initWithSenderId:msg.from
                                                          senderDisplayName:[msg.body objectForKey:@"fromname"]
                                                                       date:date
                                                                       text:text];
                 [self.data.messages addObject:message];
                 [self finishReceivingMessageAnimated:YES];
             }
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
    ChatSettingTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatSettingTableViewController"];
    vc.rosterItem = [APP_DELEGATE.user.rosterMgr getItemByUid:self.talkingId];
    [self.navigationController pushViewController:vc animated:YES];
}




- (void) setMorePanel {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    ChatMessageMorePanelItemMode *item = [[ChatMessageMorePanelItemMode alloc] initWithTitle:@"拍照" imageName:@"chatmsg_camera" target:self selector:@selector(takeAPicture)];
    [arr addObject:item];
    item = [[ChatMessageMorePanelItemMode alloc] initWithTitle:@"照片" imageName:@"chatmsg_pic" target:self selector:@selector(getPhotoFromImgLib)];
    [arr addObject:item];
    item = [[ChatMessageMorePanelItemMode alloc] initWithTitle:@"通话" imageName:@"chatmsg_phone" target:self selector:@selector(audioChat)];
    [arr addObject:item];
    item = [[ChatMessageMorePanelItemMode alloc] initWithTitle:@"视频" imageName:@"chatmsg_video" target:self selector:@selector(videoChat)];
    [arr addObject:item];
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
    NSDictionary *viewsDictionary =
    NSDictionaryOfVariableBindings(view, toolBar);
    view.translatesAutoresizingMaskIntoConstraints = NO;
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolBar][view(==230)]" options:0 metrics:nil views:viewsDictionary]];
}

- (void)takeAPicture {
   DDLogInfo(@"%s", __PRETTY_FUNCTION__);
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

- (void)videoChat {
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
}

- (void)audioChat {
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
}

- (void)transferFile {
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
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
                if (![img saveToPath:thumbPath sz:CGSizeMake(210.f, 150.0f)]) {
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
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= 5;
    }
    else
    {
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
