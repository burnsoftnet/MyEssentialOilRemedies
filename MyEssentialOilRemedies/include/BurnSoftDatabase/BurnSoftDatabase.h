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

// Translate Errors from SQLITE integer to English
-(NSString *) dbErrorsIDtoEnglish :(int)ret __attribute__((deprecated("Not used!")));
+(BOOL) resetDBDirectory;
//Pass the Database Name to find the Path of the database
-(NSString *) getDatabasePath :(NSString *) DBNAME __attribute__((deprecated("switching to +(NSString *) getDatabasePath")));
+(NSString *) getDatabasePath :(NSString *) DBNAME;
//Pass the Database name to see if the database is in the path that we need it to be in
-(void)checkDB :(NSString *) DBNAME MessageHandler:(NSString **) msg;
//Pass the name of the database to see if we need to copy the database from the application directory to the documents directory
-(void) copyDbIfNeeded :(NSString *) DBNAME MessageHandler:(NSString **) msg __attribute__((deprecated("switching to +(NSString *) copyDbIfNeeded")));
+(void) copyDbIfNeeded :(NSString *) DBNAME MessageHandler:(NSString **) msg;
//Retore the Factory Database by deleting the database in the user docs and copying it back over.
-(void) restoreFactoryDB :(NSString *) DBNAME MessageHandler:(NSString **) msg;
//Pass a SQL statement, and the database path to execute a statement, if it passes ok, then it will return true
-(BOOL) runQuery :(NSString *) mysql DatabasePath:(NSString *) DBPath MessageHandler:(NSString **) msg;
//Pass a SQL statement and the database path to see if any rows are returned from that statement, if there is something it will return true
-(BOOL) dataExistsbyQuery :(NSString *) sql DatabasePath:(NSString *)dbPath MessageHandler:(NSString **) msg;
//Pass the Name/Value that you are looking for, the column name that it would be in, the Column that that Would Contain an ID that you want, the name of the table, and the database path to get the ID value,  Used to Look up ID of a value in the table to be referenced in your code.
-(NSNumber *) getLastOneEntryIDbyName :(NSString *) name LookForColumnName:(NSString *) searchcolumn GetIDFomColumn:(NSString *) getfromcolumn InTable:(NSString *) tablename DatabasePath:(NSString *) dbPath MessageHandler:(NSString **) msg;
//Get the current Database Version, usualy used for letting the application/user/tech support know if the two version match up
-(NSString *) getCurrentDatabaseVersionfromTable:(NSString *) myTable DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **)errorMsg;

-(BOOL) VersionExists:(NSString *) myCurrentVersion VersionTable:(NSString *) myTable DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
-(int) getTotalNumberofRowsInTable:(NSString *) myTable DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
@end
