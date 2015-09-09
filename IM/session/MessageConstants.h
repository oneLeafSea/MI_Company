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
    MSG_SVR_TIME                 = 0x00010000,
    MSG_LOGIN                    = 0x00010001,
    MSG_LOGOUT                   = 0x00010002,
    MSG_APP_CHECK                = 0x00010003,
    MSG_DICT_CHECK               = 0x00010004,
    MSG_RECEIVE_PUSH             = 0x00010005,
    MSG_RECEIPT                  = 0x00010006,

    
    MSG_MAX 	       = 0x0001FFFF
};

typedef NS_ENUM(UInt32, IM) {
    IM_MESSAGE_ACK               = 0x00030000,
    IM_MESSAGE,
    IM_PRESENCE,
    IM_VOICEVIDEO,
    IM_MESSAGE_IQ                = 0x00031000, // IM消息ACK
    IM_ROSTER_ITEM_ADD_REQUEST,
    IM_ROSTER_ITEM_ADD_RESULT,
    IM_ROSTER_ITEM_DEL_REQUEST,
    IM_CHATROOM                  = 0x00031004,
    
    IM_NOTIFY_ROSTER_ADD         = 0x00040000,      // 加好友成功通知
    IM_NOTIFY_ROSTER_DEL,                            // 删除好友通知
    IM_NOTIFY_MESSAGE,
    IM_NOTIFY_FC                 = 0x00040005       // 朋友圈
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
