//
//  BurnSoftDatabase.h
//  BurnSoftDatabase
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BurnSoftDatabase : NSObject
@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;


+(BOOL) resetDBDirectory;
+(NSString *) getDatabasePath :(NSString *) DBNAME;
-(void)checkDB :(NSString *) DBNAME MessageHandler:(NSString **) msg;
+(void) copyDbIfNeeded :(NSString *) DBNAME MessageHandler:(NSString **) msg;
-(void) restoreFactoryDB :(NSString *) DBNAME MessageHandler:(NSString **) msg;
-(BOOL) runQuery :(NSString *) mysql DatabasePath:(NSString *) DBPath MessageHandler:(NSString **) msg;
-(BOOL) dataExistsbyQuery :(NSString *) sql DatabasePath:(NSString *)dbPath MessageHandler:(NSString **) msg;
-(NSNumber *) getLastOneEntryIDbyName :(NSString *) name LookForColumnName:(NSString *) searchcolumn GetIDFomColumn:(NSString *) getfromcolumn InTable:(NSString *) tablename DatabasePath:(NSString *) dbPath MessageHandler:(NSString **) msg;
-(NSString *) getCurrentDatabaseVersionfromTable:(NSString *) myTable DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **)errorMsg;
-(BOOL) VersionExists:(NSString *) myCurrentVersion VersionTable:(NSString *) myTable DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
-(int) getTotalNumberofRowsInTable:(NSString *) myTable DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
+(BOOL) updateDatabaseForiCloudBackup:(NSString *) DBPath MessageHandler:(NSString **) msg;
@end
