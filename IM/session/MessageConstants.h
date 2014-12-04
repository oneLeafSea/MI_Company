//
//  MessageConstants.h
//  WH
//
//  Created by guozw on 14-10-13.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#ifndef WH_MessageConstants_h
#define WH_MessageConstants_h


typedef NS_ENUM(UInt32, MSG) {
    MSG_SVR_TIME 	   = 0x00010000,
    MSG_LOGIN          = 0x00010001,
    MSG_LOGOUT         = 0x00010002,
    MSG_APP_CHECK 	   = 0x00010003,
    MSG_DICT_CHECK 	   = 0x00010004,
    MSG_RECEIVE_PUSH   = 0x00010005,
    MSG_RECEIPT 	   = 0x00010006,
    
    MSG_MAX 	       = 0x0001FFFF
};

typedef NS_ENUM(UInt32, PUSH) {
    PUSH_KICK 	 	   = 0x00020001,
    PUSH_MESSAGE 	   = 0x00020002,
    PUSH_MAX 	   	   = 0x0002FFFF
    
};

static const NSString *kMsgQid = @"qid";
static const NSString *kDevice = @"device";
static const NSString *kDeviceType = @"iphone";


#endif
