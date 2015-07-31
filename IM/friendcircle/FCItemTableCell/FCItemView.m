//
//  FCItemView.m
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCItemView.h"
#import <SETextView.h>
#import <Masonry.h>
#import <MMPlaceHolder/MMPlaceHolder.h>

#import "FCItemCommentsView.h"
#import "FCItemImagesView.h"
#import "FCConstants.h"
#import "AppDelegate.h"
#import "NSDate+Common.h"
#import "NSDate+DateTools.h"

#define FC_POSITION_LBL_FONT 14
#define FC_CONTENT_TEXT_FONT 14
#define FC_CONTENT_TEXT_LINESPACE  5
#define FC_POS_IMG_HEIGHT 13
#define FC_POS_IMG_WIDTH 13


@interface FCItemView() <FCItemCommentsViewDelegate>

@property(nonatomic, strong) UIImageView *avatarImgView;
@property(nonatomic, strong) UILabel *nameLbl;
@property(nonatomic, strong) UILabel *timeLbl;
@property(nonatomic, strong) SETextView *contentTextView;
@property(nonatomic, strong) UILabel *positionLbl;
@property(nonatomic, strong) UIButton *remarkBtn;
@property(nonatomic, strong) FCItemImagesView *imgsView;
@property(nonatomic, strong) FCItemCommentsView *commentsView;

@property(nonatomic, strong) UIImageView *positionImg;

@end

@implementation FCItemView

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setModel:(FCItemViewModel *)model {
    _model = model;
    self.avatarImgView.image = [USER.avatarMgr getAvatarImageByUid:model.uid];
    self.nameLbl.text = model.name;
    NSDate *date = [NSDate dateWithFormater:@"yyyy-MM-dd HH:mm:ss.SSSSSS" stringTime:model.time];
    self.timeLbl.text = [date timeAgoSinceNow];
    self.timeLbl.textColor = [UIColor lightGrayColor];
    if (model.content.length == 0) {
        self.contentTextView.hidden = YES;
    } else {
        self.contentTextView.hidden = NO;
    }
    self.contentTextView.text = model.content;
    self.contentTextView.lineSpacing = FC_CONTENT_TEXT_LINESPACE;
    self.imgsView.model = model.imgViewModel;
    self.commentsView.model = model.commentsViewModel;
    self.positionLbl.text = self.model.position;
    self.positionLbl.textColor = [UIColor lightGrayColor];
    [self setupConstraints];
}



- (void)setup {
    self.avatarImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar_default"]];
    self.nameLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLbl.textColor = [UIColor colorWithRed:41/255.0f green:89/255.0f blue:152/255.0f alpha:1.0];
    self.timeLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLbl.font = [UIFont systemFontOfSize:14];
    self.contentTextView = [[SETextView alloc] initWithFrame:CGRectZero];
    self.contentTextView.textColor = [UIColor blackColor];
    self.contentTextView.backgroundColor = [UIColor whiteColor];
    self.contentTextView.font = [UIFont systemFontOfSize:FC_CONTENT_TEXT_FONT];
    self.contentTextView.editable = NO;
    
//    self.positionImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fc_pos"]];
//    [self.contentTextView addSubview:self.positionImg];
    
    self.positionLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    self.positionLbl.font = [UIFont systemFontOfSize:FC_POSITION_LBL_FONT];
    self.remarkBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.imgsView = [[FCItemImagesView alloc] initWithFrame:CGRectZero];
    self.imgsView.curVC = self.curVC;
    self.commentsView = [[FCItemCommentsView alloc] initWithFrame:CGRectZero];
    self.commentsView.delegate = self;
    
    [self addSubview:self.avatarImgView];
    [self addSubview:self.nameLbl];
    [self addSubview:self.timeLbl];
    [self addSubview:self.contentTextView];
    [self addSubview:self.positionLbl];
    [self addSubview:self.remarkBtn];
    [self addSubview:self.imgsView];
    [self addSubview:self.commentsView];
}

- (void)setupConstraints {
    
    self.avatarImgView.frame = CGRectMake(FC_AVATAR_LEFT_OFFSET, FC_AVATAR_TOP_OFFSET, FC_AVATAR_WIDTH, FC_AVATAR_HEIGHT);
    [self.nameLbl sizeToFit];
    self.nameLbl.frame = CGRectMake(FC_AVATAR_LEFT_OFFSET+FC_AVATAR_WIDTH + FC_VIEW_INTERVAL, FC_AVATAR_TOP_OFFSET, self.nameLbl.frame.size.width, self.nameLbl.frame.size.height);
    
    [self.timeLbl sizeToFit];
    self.timeLbl.frame = CGRectMake(FC_AVATAR_LEFT_OFFSET+FC_AVATAR_WIDTH + FC_VIEW_INTERVAL, FC_AVATAR_TOP_OFFSET + FC_AVATAR_HEIGHT - self.timeLbl.frame.size.height, self.timeLbl.frame.size.width, self.timeLbl.frame.size.height);
    

    CGSize sz = [FCItemView getContentSz:self.model.content];
    self.contentTextView.frame = CGRectMake(self.avatarImgView.frame.origin.x, self.timeLbl.frame.origin.y + self.timeLbl.frame.size.height + FC_VIEW_INTERVAL, sz.width, sz.height);

    
    sz = [FCItemView getImgsViewSz:self.model.imgViewModel];
    self.imgsView.frame = CGRectMake(FC_AVATAR_LEFT_OFFSET,  self.contentTextView.frame.origin.y + self.contentTextView.frame.size.height + FC_VIEW_INTERVAL, sz.width, sz.height);
    
    
//    CGRect rt = CGRectMake(FC_AVATAR_LEFT_OFFSET, self.imgsView.frame.origin.y + self.imgsView.frame.size.height + FC_VIEW_INTERVAL, FC_POS_IMG_WIDTH, FC_POS_IMG_HEIGHT);
//    self.positionImg.frame = rt;

//
//    self.positionLbl.center = CGPointMake(self.positionImg.center.x + self.positionImg.frame.size.width / 2, self.positionImg.center.y);
    [self.positionLbl sizeToFit];
    if (self.model.imgViewModel.hasImages) {
        self.positionLbl.frame = CGRectMake(self.positionImg.frame.origin.x+FC_POS_IMG_WIDTH, self.imgsView.frame.origin.y + self.imgsView.frame.size.height + FC_VIEW_INTERVAL, self.positionLbl.frame.size.width, self.positionLbl.frame.size.height);
    } else {
        self.positionLbl.frame = CGRectMake(self.positionImg.frame.origin.x+FC_POS_IMG_WIDTH, self.imgsView.frame.origin.y + self.imgsView.frame.size.height, self.positionLbl.frame.size.width, self.positionLbl.frame.size.height);
    }
    
    sz = [FCItemView getCommentsViewSz:self.model.commentsViewModel];
    if (self.model.commentsViewModel.fcicItemCellModels.count > 0) {
        self.commentsView.frame = CGRectMake(FC_AVATAR_LEFT_OFFSET, self.positionLbl.frame.origin.y + self.positionLbl.frame.size.height, sz.width, sz.height);
    } else {
        self.commentsView.frame = CGRectMake(FC_AVATAR_LEFT_OFFSET, self.positionLbl.frame.origin.y + self.positionLbl.frame.size.height + FC_VIEW_INTERVAL, sz.width, sz.height);
    }
    
    
}

+ (CGSize)getCommentsViewSz:(FCItemCommentsViewModel *) commentsViewModel{
    CGFloat commentsHeight = [FCItemCommentsView heightForCommentsView:commentsViewModel];
    CGFloat commentsWidth = [UIScreen mainScreen].bounds.size.width - FC_COMMENT_LEFT_OFFSET - FC_COMMENTS_RIGHT_OFFSET;
    CGSize sz = CGSizeMake(commentsWidth, commentsHeight);
    return sz;
}

+ (CGSize)getImgsViewSz: (FCItemImagesViewModel *)imgViewModel {
    
    if (!imgViewModel.hasImages) {
        return CGSizeZero;
    }
    
    CGFloat imgsViewWidth = [UIScreen mainScreen].bounds.size.width - FC_IMAGES_LEFT_OFFSET - FC_IMAGES_RIGHT_OFFSET;
    CGFloat imgsViewHeight = [FCItemImagesView heightForImagesHeight:imgViewModel];
    return CGSizeMake(imgsViewWidth, imgsViewHeight);
    
}

- (void)setCurVC:(UIViewController *)curVC {
    _curVC = curVC;
    self.imgsView.curVC = _curVC;
}

+ (CGSize)getContentSz: (NSString *)content {
    CGFloat width = [UIScreen mainScreen].bounds.size.width - FC_COMMENT_LEFT_OFFSET - FC_COMMENT_RIGHT_OFFSET;
    CGSize sz = CGSizeMake(width, CGFLOAT_MAX);
    
    if (content.length == 0) {
        return CGSizeZero;
    }
    
    CGRect rt = [SETextView frameRectWithAttributtedString:[[NSAttributedString alloc] initWithString:content] constraintSize:sz lineSpacing:FC_CONTENT_TEXT_LINESPACE font:[UIFont systemFontOfSize:FC_CONTENT_TEXT_FONT]];
    return rt.size;
}

+ (CGFloat)heightForViewModel:(FCItemViewModel *)itemViewModel {
    CGFloat height = FC_AVATAR_TOP_OFFSET + FC_AVATAR_HEIGHT + [FCItemView getContentSz:itemViewModel.content].height; //+ [FCItemView getImgsViewSz:itemViewModel.imgViewModel].height + FC_POS_IMG_HEIGHT + [FCItemView getCommentsViewSz:itemViewModel.commentsViewModel].height + 3 *  + FC_VIEW_INTERVAL + FC_VIEW_INTERVAL;
    if (itemViewModel.imgViewModel.hasImages) {
        height += [FCItemView getImgsViewSz:itemViewModel.imgViewModel].height + FC_POS_IMG_HEIGHT;
    }
    
    if (itemViewModel.commentsViewModel.fcicItemCellModels.count > 0) {
        height += [FCItemView getCommentsViewSz:itemViewModel.commentsViewModel].height + 3 * FC_VIEW_INTERVAL + FC_VIEW_INTERVAL;
    } else {
        height += [FCItemView getCommentsViewSz:itemViewModel.commentsViewModel].height + 4 *FC_VIEW_INTERVAL + FC_VIEW_INTERVAL;
    }
    return height;
}

+ (CGFloat)getPositionHeight {
    NSString *str = @"位置";
    CGSize sz = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil].size;
    return sz.height;
}

#pragma mark - FCItemCommentsViewDelegate
- (void)fcItemCommentsView:(FCItemCommentsView *)commentsView didSelectAt:(NSInteger)index {
    FCItemCommentsViewModel *m = commentsView.model;
    FCICItemCellModel *itemModel = [m.fcicItemCellModels objectAtIndex:index];
    if ([self.delegate respondsToSelector:@selector(fcItemView:commentsDidTapped:)]) {
        [self.delegate fcItemView:self commentsDidTapped:itemModel];
    }
}

- (void)fcItemCommentsViewRemarkCellTapped:(FCItemCommentsView *)commentsView cellModel:(FCItemCommentsViewModel *)commentsViewModel {
    if ([self.delegate respondsToSelector:@selector(fcItemViewCommentsRemark:)]) {
        [self.delegate fcItemViewCommentsRemark:self];
    }
}

@end
