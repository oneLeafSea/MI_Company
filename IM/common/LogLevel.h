//
//  LogLevel.h
//  WH
//
//  Created by guozw on 14-10-14.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#ifndef WH_LogLevel_h
#define WH_LogLevel_h

#import "DDLog.h"
#import "DDTTYLogger.h"

// you'd better include this file in .m file. not .h file.

#if DEBUG

static const int ddLogLevel = LOG_LEVEL_INFO;

#else

static const int ddLogLevel = LOG_LEVEL_ERROR;

#endif

#endif
