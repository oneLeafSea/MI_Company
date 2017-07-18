//
//  fileBrowserSelectTableViewCell.h
//  IM
//
//  Created by 郭志伟 on 15-2-16.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface fileBrowserSelectTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *fileTypeImgView;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;

@property (weak, nonatomic) IBOutlet UILabel *fileNameLbl;

@property (nonatomic) BOOL fileSelected;
@end
