//
//  RosterSql.h
//  IM
//
//  Created by 郭志伟 on 14-12-25.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>
// roster表
extern NSString *kSQLRosterCreate;
extern NSString *kSQLRosterInsert;
extern NSString *kSQLRosterQueryByUid;
extern NSString *kSQLRosterQuery;
extern NSString *kSQLRosterUpdate;
extern NSString *kSQLRosterDel;
extern NSString *kSQLRosterDelAll;

// roster versin table.
extern NSString *kSQLRosterVerCreate;

// rosterdelrequest 表
extern NSString *kSQLRosterItemAddReqCreate;
extern NSString *kSQLRosterItemAddReqInsert;
extern NSString *kSQLRosterItemAddReqUpdate;
extern NSString *kSQLRosterItemUpdateReqStatusByFrom ;
extern NSString *kSQLRosterItemAddReqUpdateStatus;
extern NSString *kSQLRosterItemAddReqDel;
extern NSString *kSQLRosterItemAddReqGetWithMsgid;


// roster_del_req 表

extern NSString *kSQLRosterItemDelReqCreate;
extern NSString *kSQLRosterItemDelReqInsert;
extern NSString *kSQLRosterItemDelReqUpdate;
extern NSString *kSQLRosterItemDelReqUpdateStatus;
extern NSString *kSQLRosterItemDelReqDel;

// roster_add_result 表
extern NSString *kSQLRosterItemAddResultCreate;
extern NSString *kSQLRosterItemAddResultInsert;
extern NSString *kSQLRosterItemAddResultUpdate;
extern NSString *kSQLRosterItemAddResultUpdateStatus;
extern NSString *kSQLRosterItemAddResultDel;
extern NSString *kSQLRosterItemAddReqGetAllButMe;
extern NSString *kSQLRosterItemAddReqDelAll;

// roster_grp table.
extern NSString *kSQLRosterGrpCreate;
extern NSString *kSQLRosterGrpUpdate;
extern NSString *kSQLRosterGrpDelAll;
extern NSString *kSQLRosterGrpInsert;
extern NSString *kSQLRosterGrpDelWithGid;


// roster_grp_version table.
extern NSString *kSQLRosterGrpVerCreate;
