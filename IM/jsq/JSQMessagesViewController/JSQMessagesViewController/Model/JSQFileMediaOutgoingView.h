//
//  JSQFileMediaOutgoingView.h
//  IM
//
//  Created by 郭志伟 on 15-2-16.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSQFileMediaOutgoingView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *fileTypeImgView;
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *fileSize;
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;

@property(nonatomic) NSString *uuid;
@end
