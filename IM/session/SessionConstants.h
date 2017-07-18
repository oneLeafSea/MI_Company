//
//  sessionConstants.h
//  WH
//
//  Created by 郭志伟 on 14-10-12.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#ifndef _SessionConstants_h
#define _SessionConstants_h

/**
 * 消息的格式(message format)
 *   -------------------------------
 *  | dataLen | datatype | bsonData |
 *  |-------------------------------
 *  | 4bytes  |  4bytes  | dataLen-4|
 *  |-------------------------------
 **/

const unsigned int kDataLengthSz   = 4;     // 数据长度 4字节
const unsigned int kDataTypeSz     = 4;     // 数据类型 4字节


#endif
