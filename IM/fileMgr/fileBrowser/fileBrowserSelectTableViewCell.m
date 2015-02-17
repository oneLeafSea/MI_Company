//
//  fileBrowserSelectTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15-2-16.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "fileBrowserSelectTableViewCell.h"

@interface fileBrowserSelectTableViewCell() {
    
    __weak IBOutlet UIImageView *m_selectImgView;
}
@end

@implementation fileBrowserSelectTableViewCell

- (void)awakeFromNib {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFileImgTaped)];
    [self.fileTypeImgView addGestureRecognizer:tapGesture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}


- (void)setFileSelected:(BOOL)fileSelected {
    _fileSelected = fileSelected;
    m_selectImgView.image = [UIImage imageNamed:fileSelected ? @"fileBrowser_selected" : @"fileBrowser_unselected"];
}

- (void)handleFileImgTaped {
    NSLog(@"fileTypeImgView taped");
}

@end
