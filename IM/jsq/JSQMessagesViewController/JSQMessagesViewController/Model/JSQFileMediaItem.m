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
                    isDownloaded:(BOOL)isDownloaded
                        outgoing:(BOOL)maskAsOutgoing {
    if (self = [super initWithMaskAsOutgoing:maskAsOutgoing]) {
        _filePath = [filePath copy];
        _fileSz = fileSz;
        _isDownloaded = isDownloaded;
        _uuid = [uuid copy];
        _fileName = [fileName copy];
    }
    return self;
}



- (UIView *)mediaView {
    if (self.appliesMediaViewMaskAsOutgoing) {
        m_outgoingView = [[[NSBundle mainBundle] loadNibNamed:@"JSQFileMediaOutgoingView" owner:self options:nil] objectAtIndex:0];
        return m_outgoingView;
    }
    m_incomingView = [[[NSBundle mainBundle] loadNibNamed:@"JSQFileMediaIncomingView" owner:self options:nil] objectAtIndex:0];
    return m_incomingView;
}

- (CGSize)mediaViewDisplaySize {
    return CGSizeMake(245, 94);
}

- (NSUInteger)hash {
    return super.hash ^ self.filePath.hash;
}

@end
