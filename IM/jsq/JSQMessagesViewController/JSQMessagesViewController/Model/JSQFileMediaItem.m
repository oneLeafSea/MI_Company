//
//  JSQFileMediaItem.m
//  IM
//
//  Created by 郭志伟 on 15-2-17.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "JSQFileMediaItem.h"
#import "JSQFileMediaIncomingView.h"
#import "JSQFileMediaOutgoingView.h"

@interface JSQFileMediaItem() {
    JSQFileMediaOutgoingView *m_outgoingView;
    JSQFileMediaIncomingView *m_incomingView;
}
@end

@implementation JSQFileMediaItem

- (instancetype)initWithFilePath:(NSString *)filePath
                          fileSz:(unsigned long long)fileSz
                            uuid:(NSString *)uuid
                        fileName:(NSString *)fileName
                    isReady:(BOOL)isReady
                        outgoing:(BOOL)maskAsOutgoing {
    if (self = [super initWithMaskAsOutgoing:maskAsOutgoing]) {
        _filePath = [filePath copy];
        _fileSz = fileSz;
        _isReady = isReady;
        _uuid = [uuid copy];
        _fileName = [fileName copy];
    }
    return self;
}



- (UIView *)mediaView {
    if (self.appliesMediaViewMaskAsOutgoing) {
        m_outgoingView = [[[NSBundle mainBundle] loadNibNamed:@"JSQFileMediaOutgoingView" owner:self options:nil] objectAtIndex:0];
        m_outgoingView.fileName.text = self.fileName;
        m_outgoingView.fileSize.text = [NSString stringWithFormat:@"%llu", self.fileSz];
        if (!self.isReady) {
            m_outgoingView.statusLbl.text = @"上传中";
        } else {
            m_outgoingView.statusLbl.text = @"已上传";
        }
        m_outgoingView.uuid = self.uuid;
        return m_outgoingView;
    }
    m_incomingView = [[[NSBundle mainBundle] loadNibNamed:@"JSQFileMediaIncomingView" owner:self options:nil] objectAtIndex:0];
    m_incomingView.fileName.text = self.fileName;
    m_incomingView.fileSize.text = [NSString stringWithFormat:@"%llu", self.fileSz];
    if (!self.isReady) {
        m_incomingView.statusLbl.text = @"未下载";
    } else {
        m_incomingView.statusLbl.text = @"已下载";
    }
    m_incomingView.uuid = self.uuid;
    return m_incomingView;
}

- (CGSize)mediaViewDisplaySize {
    return CGSizeMake(245, 94);
}

- (NSUInteger)hash {
    return super.hash ^ self.filePath.hash;
}

@end
