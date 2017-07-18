//
//  DictDb.m
//  WH
//
//  Created by 郭志伟 on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "DictDb.h"
#import "FMDB.h"
#import "LogLevel.h"


static NSString *kDictDbName       = @"dict.db";
static NSString *kTbTmp            = @"tb_temp";


static NSString *kTbDv             = @"tb_dict_verson";
static NSString *kTbDvColName      = @"name";
static NSString *kTbDvColVersion   = @"version";

@interface DictDb() {
    FMDatabaseQueue *m_dbQueue;
    DictsVersion    *m_dictsVer;
}

@end

@implementation DictDb

- (instancetype) initWithDirectory:(NSString *)dir {
    if (self = [super init]) {
        if (![self setup:dir]) {
            self = nil;
        }
    }
    return self;
}

- (void) close {
    [m_dbQueue close];
    m_dbQueue = nil;
}


- (Dict *) getDictByName:(NSString *)dictName {
    if (![self tableExists:dictName]) {
        return nil;
    }
    NSString *dv = [self.dictsVer.data valueForKey:dictName];
    
    if (!dv) {
        DDLogError(@"did not have version for dict: %@", dictName);
        return nil;
    }
    
    NSArray *colsNames = [self getColumnFromDictName:dictName];
    if (!colsNames || colsNames.count == 0) {
        DDLogError(@"the dict: %@ no colsNames", colsNames);
        return nil;
    }
    
    DictData *data = [self getDictDataByName:dictName];
    
    if (!data) {
        DDLogError(@"the dict: %@ no dict data", dictName);
        return nil;
    }
    
    Dict *d = [[Dict alloc] initWithDictData:data colname:colsNames dictName:dictName version:dv];
    return d;
}

- (DictData *) getDictDataByName:(NSString *)dn {
    if (![self tableExists:dn]) {
        return nil;
    }
    
    __block NSMutableArray *dData = [[NSMutableArray alloc] initWithCapacity:128];
    [m_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql  = [NSString stringWithFormat:@"SELECT * FROM %@", dn];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            for (int n = 0; n < rs.columnCount; n++) {
                NSString *colName = [rs columnNameForIndex:n];
                NSString *val     = [rs stringForColumnIndex:n];
                [dict setValue:val forKey:colName];
            }
            [dData addObject:dict];
        }
        [rs close];
    }];
    
    return dData;
}

- (BOOL) rmDict:(NSString *)dictName {
    __block BOOL ret = YES;
    if ([self tableExists:kTbDv]) {
        [m_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            NSString *strFmt = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?;", kTbDv, kTbDvColName];
            ret = [db executeUpdate:strFmt, dictName];
            if (!ret) {
                *rollback = YES;
            }
        }];
        
        ret = [self dropTable:dictName];
    }
    return ret;
}

- (DictsVersion *) dictsVer {
//    if (m_dictsVer) {
//        return m_dictsVer;
//    }
    __block NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:128];
    [m_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", kTbDv];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString *dictName = [rs stringForColumn:kTbDvColName];
            NSString *dictVersion = [rs stringForColumn:kTbDvColVersion];
            [dict setValue:dictVersion forKey:dictName];
        }
        [rs close];
    }];
    m_dictsVer = [[DictsVersion alloc] initWithDvData:dict];
    return m_dictsVer;
}

- (BOOL) importDictWithName:(NSString *) dictName version:(NSString *)version data:(NSData *) data {

    const NSUInteger nDataLen = data.length;
    __block int nOffset = 0;
    
    NSMutableArray *arrCols = [[NSMutableArray alloc]init];
    
    for (; ;) {
        const NSUInteger nColLen = [self length:data offset:nOffset];
        NSString *str = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(nOffset, nColLen)] encoding:NSUTF8StringEncoding];
        [arrCols addObject:str];
        nOffset += (nColLen + 1);
        const char* p = data.bytes;
        if (p[nOffset] == 0) {
            break;
        }
    }
    
    nOffset++;
    NSUInteger nCols = arrCols.count;
    if (nOffset >= nDataLen || nCols < 2) {
        DDLogError(@"非法字典，列数小于2 或者 没有字典数据！");
        return NO;
    }
    
    if (![self createDictTableWithName:kTbTmp cols:arrCols]) {
        DDLogError(@"创建临时表错误!");
        return NO;
    }
    
    __block BOOL bSuc = YES;
    [m_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSMutableArray *arrVal = [[NSMutableArray alloc] init];
        for (; ; ) {
            [arrVal removeAllObjects];
            
            for (int i = 0; i < nCols; i++) {
                const NSUInteger nValueLen = [self length:data offset:nOffset];
                NSString *str = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(nOffset, nValueLen)] encoding:NSUTF8StringEncoding];
                [arrVal addObject:str];
                nOffset += (nValueLen + 1);
            }
            
            const char* p = data.bytes;
            if (p[nOffset] != 0) {
                *rollback = YES;
                bSuc = NO;
                DDLogError(@"数据格式错误！");
                break;
            }
            
            NSMutableString *sql = [[NSMutableString alloc] init];
            [sql appendFormat:@"INSERT INTO %@ VALUES ( ", kTbTmp];
            for (int n = 0; n < arrVal.count; n++) {
                if (n + 1 == arrVal.count) {
                    [sql appendString:@"? )"];
                } else {
                    [sql appendString:@"?, "];
                }
                
            }
            
            bSuc = [db executeUpdate:sql withArgumentsInArray:arrVal];
            if (!bSuc) {
                *rollback = YES;
                DDLogError(@"插入表数据失败！");
                break;
            }
            nOffset++;
            if (nOffset >= nDataLen) break;
        }
    }];
    
    if (bSuc) {
        if ([self dropTable:dictName] && [self renameOldTableName:kTbTmp toNewTbName:dictName]) {
            return [self updateDictVersionTbDictName:dictName dictVersion:version];
        } else {
            [self dropTable:kTbTmp];
        }
    } else {
        [self dropTable:kTbTmp];
    }
    
    return bSuc;

}


#pragma mark -private

- (BOOL)setup:(NSString *)dir {
    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:dir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error != nil) {
        DDLogError(@"error creating directory: %@", error);
        return NO;
    }
    NSString *dbPath = [dir stringByAppendingPathComponent:kDictDbName];
    
    m_dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
    DDLogInfo(@"%@", dbPath);
    
    if (!m_dbQueue) {
        DDLogError(@"error in create database queue.");
        return NO;
    }
    [self rmDict:kTbTmp];
    return [self createDictVersion];
}

- (BOOL) createDictVersion {
    if (m_dbQueue == nil) return NO;
    
    if ([self tableExists:kTbDv]) {
        return YES;
    }
    __block BOOL ret = YES;
    [m_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *strFmt = @"CREATE TABLE %@ (%@ TEXT not null PRIMARY KEY, %@ TEXT not null);";
        ret = [db executeUpdate:[NSString stringWithFormat:strFmt, kTbDv, kTbDvColName, kTbDvColVersion]];
        if (!ret) {
            NSLog(@"create DictVersionTb error");
            *rollback = YES;
        }
    }];
    
    return ret;
}

- (NSArray *) getColumnFromDictName:(NSString *)dictName {
    if (![self tableExists:dictName]) return nil;
    
    __block NSMutableArray *arrCols = [[NSMutableArray alloc] initWithCapacity:32];
    
    [m_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *strFmt = @"SELECT * FROM %@ WHERE 0=1";
        NSString *strSql = [NSString stringWithFormat:strFmt, dictName];
        FMResultSet *rs = [db executeQuery:strSql];
        int nCols = rs.columnCount;
        for (int n = 0; n < nCols; n++) {
            [arrCols addObject:[rs columnNameForIndex:n]];
        }
        [rs close];
    }];
    return arrCols;
}

- (BOOL) dropTable:(NSString *)tableName {
    
    if (m_dbQueue == nil)
        return NO;
    __block BOOL ret = YES;
    [m_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *strFmt = @"DROP TABLE IF EXISTS %@;";
        ret = [db executeUpdate:[NSString stringWithFormat:strFmt, tableName]];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) tableExists:(NSString *) tableName {
    
    if (m_dbQueue == nil) return NO;
    __block BOOL ret = NO;
    [m_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *strFmt = @"SELECT name FROM sqlite_master WHERE type='table' AND name= ?";
        FMResultSet* rs = [db executeQuery:strFmt, tableName];
        if ([rs next]) {
            ret = YES;
        }
        [rs close];
    }];
    return ret;
}

- (NSUInteger)length:(NSData *)data offset:(int) offset {
    NSUInteger nRet = 0;
    
    NSUInteger nDataLen = data.length;
    for (int i=offset; i<nDataLen; i++)
    {
        const char *p = data.bytes;
        if (p[i] == 0) break;
        nRet++;
    }
    return nRet;
    
}

- (BOOL) createDictTableWithName:(NSString *)tbName cols:(NSArray *)cols {
    if (m_dbQueue == nil) return NO;
    
    if ([self tableExists:tbName] && ![self dropTable:tbName]) {
        return NO;
    }
    
    __block NSMutableString *sql = [[NSMutableString alloc]initWithCapacity:256];
    [sql appendString:@"CREATE TABLE "];
    [sql appendString:tbName];
    [sql appendString:@" ("];
    [sql appendString:cols[0]]; [sql appendString:@" TEXT not null, "];
    [sql appendString:cols[1]]; [sql appendString:@" TEXT not null"];
    
    NSUInteger nCols = [cols count];
    for (NSUInteger i = 2; i < nCols; i++) {
        [sql appendString:@", "];
        [sql appendString:cols[i]];
        [sql appendString:@" TEXT"];
    }
    [sql appendString:@");"];
    
    __block BOOL ret = YES;
    [m_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:sql];
        if (!ret) {
            *rollback = YES;
        }
    }];
    
    return ret;
    
}

- (BOOL) renameOldTableName:(NSString *)oldTbName toNewTbName:(NSString *)newTbName {
    if (![self tableExists:oldTbName]) {
        NSLog(@"no old table!");
        return NO;
    }
    
    __block BOOL ret = NO;
    NSString *strFmt = @"ALTER TABLE %@ RENAME TO %@;";
    [m_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:[NSString stringWithFormat:strFmt, oldTbName, newTbName]];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) updateDictVersionTbDictName:(NSString *)dictName dictVersion:(NSString *)version {
    if (![self tableExists:kTbDv]) return NO;
    
    __block BOOL ret = NO;
    [m_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *strFmt = @"SELECT * FROM %@ WHERE %@ = ? ";
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:strFmt, kTbDv, kTbDvColName], dictName];
        if ([rs next]) {
            NSString *fmtSql = @"UPDATE %@ SET %@ = ? WHERE %@ = ?";
            NSString *sql = [NSString stringWithFormat:fmtSql, kTbDv, kTbDvColVersion, kTbDvColName];
            ret = [db executeUpdate:sql, version, dictName];
            if (!ret) {
                *rollback = YES;
            }
        } else {
            NSString *fmtSql = @"INSERT INTO %@ VALUES (?, ?)";
            NSString *sql = [NSString stringWithFormat:fmtSql, kTbDv];
            ret = [db executeUpdate:sql, dictName, version];
        }
        [rs close];
    }];
    return ret;
}


@end
