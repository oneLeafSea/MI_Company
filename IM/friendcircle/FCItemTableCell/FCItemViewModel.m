//
//  FCItemViewModel.m
//  IM
//
//  Created by 郭志伟 on 15/6/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCItemViewModel.h"
#import "AppDelegate.h"
#import "FCICItemCellModel.h"
#import "NSString+URL.h"

@implementation FCItemViewModel

- (void)setUid:(NSString *)uid {
    _uid = [uid copy];
    if ([_uid isEqualToString:USER.uid]) {
        self.name = USER.name;
    } else {
//        self.name = [USER.rosterMgr getItemByUid:_uid].name;
    }
    
}

- (FCItemImagesViewModel *)imgViewModel {
    if (!_imgViewModel) {
        _imgViewModel = [[FCItemImagesViewModel alloc] initWithPostId:self.modelId serverUrl:USER.fcImgServerUrl thumbServerUrl:USER.fcImgThumbServerUrl imgNum:(self.imgNum ? [self.imgNum integerValue]: 0)];
    }
    return _imgViewModel;
}

- (FCItemCommentsViewModel *)commentsViewModel {
    if (!_commentsViewModel) {
        _commentsViewModel = [[FCItemCommentsViewModel alloc] init];
    }
    return _commentsViewModel;
}


- (void)addCommentViewModel:(NSDictionary *)dict {
    FCICItemCellModel *icm = [[FCICItemCellModel alloc] init];
    icm.uid = [dict objectForKey:@"hfr"];
    icm.content = [dict objectForKey:@"content"];
    NSString *sshfxxid = [dict objectForKey:@"sshfxxid"];
    NSString *hfxxid = [dict objectForKey:@"hfxxid"];
    icm.replyId = hfxxid;
    if (sshfxxid.length > 0) {
        icm.repliedUid = [dict objectForKey:@"bhfr"];
        icm.belongToId = sshfxxid;
    }
    self.time = [dict objectForKey:@"hfsj"];
    [self.commentsViewModel.fcicItemCellModels addObject:icm];
}

@end
