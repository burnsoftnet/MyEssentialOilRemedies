//
//  BurnSoftDatabase.m
//  BurnSoftDatabase
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "BurnSoftDatabase.h"
#import <sqlite3.h>

@interface BurnSoftDatabase()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableArray *arrResults;

@end

@implementation BurnSoftDatabase
{
    sqlite3 *MYDB;
}

#pragma mark Error Handling
//NOTE: Translate Errors from SQLITE integer to English
//USEDBY: GENERAL
-(NSString *) dbErrorsIDtoEnglish :(int)ret
{
    NSString *msg;
    switch (ret) {
        case SQLITE_ERROR :
            msg = [NSString stringWithFormat:@"SQL error or missing database, ERROR #: %d",ret];
            break;
        case SQLITE_INTERNAL :
            msg = [NSString stringWithFormat:@"Internal logic error in SQLite, ERROR #: %d",ret];
            break;
        case SQLITE_PERM :
            msg = [NSString stringWithFormat:@"Access permission denied, ERROR #: %d",ret];
            break;
        case SQLITE_ABORT :
            msg = [NSString stringWithFormat:@"Callback routine requested an abort, ERROR #: %d",ret];
            break;
        case SQLITE_BUSY :
            msg = [NSString stringWithFormat:@"The database file is locked, ERROR #: %d",ret];
            break;
        case SQLITE_LOCKED :
            msg = [NSString stringWithFormat:@"A table in the database is locked, ERROR #: %d",ret];
            break;
        case SQLITE_NOMEM :
            msg = [NSString stringWithFormat:@"A malloc() failed, ERROR #: %d",ret];
            break;
        case SQLITE_READONLY :
            msg = [NSString stringWithFormat:@"Attempt to write a readonly database, ERROR #: %d",ret];
            break;
        case SQLITE_INTERRUPT :
            msg = [NSString stringWithFormat:@"Operation terminated by sqlite3_interrupt(), ERROR #: %d",ret];
            break;
        case SQLITE_IOERR :
            msg = [NSString stringWithFormat:@"Some kind of disk I/O error occurred, ERROR #: %d",ret];
            break;
        case SQLITE_CORRUPT :
            msg = [NSString stringWithFormat:@"The database disk image is malformed, ERROR #: %d",ret];
            break;
        case SQLITE_NOTFOUND :
            msg = [NSString stringWithFormat:@"Unknown opcode in sqlite3_file_control(), ERROR #: %d",ret];
            break;
        case SQLITE_FULL :
            msg = [NSString stringWithFormat:@"Insertion failed because database is full, ERROR #: %d",ret];
            break;
        case SQLITE_CANTOPEN :
            msg = [NSString stringWithFormat:@"Unable to open the database file, ERROR #: %d",ret];
            break;
        case SQLITE_PROTOCOL :
            msg = [NSString stringWithFormat:@"Database lock protocol error, ERROR #: %d",ret];
            break;
        case SQLITE_EMPTY :
            msg = [NSString stringWithFormat:@"Database is empty, ERROR #: %d",ret];
            break;
        case SQLITE_SCHEMA :
            msg = [NSString stringWithFormat:@"The database schema changed, ERROR #: %d",ret];
            break;
        case SQLITE_TOOBIG :
            msg = [NSString stringWithFormat:@"String or BLOB exceeds size limit, ERROR #: %d",ret];
            break;
        case SQLITE_CONSTRAINT :
            msg = [NSString stringWithFormat:@"Abort due to constraint violation, ERROR #: %d",ret];
            break;
        case SQLITE_MISMATCH :
            msg = [NSString stringWithFormat:@"Data type mismatch, ERROR #: %d",ret];
            break;
        case SQLITE_MISUSE :
            msg = [NSString stringWithFormat:@"Library used incorrectly, ERROR #: %d",ret];
            break;
        case SQLITE_NOLFS :
            msg = [NSString stringWithFormat:@"Uses OS features not supported on host, ERROR #: %d",ret];
            break;
        case SQLITE_AUTH :
            msg = [NSString stringWithFormat:@"Authorization denied, ERROR #: %d",ret];
            break;
        case SQLITE_FORMAT :
            msg = [NSString stringWithFormat:@"Auxiliary database format error, ERROR #: %d",ret];
            break;
        case SQLITE_RANGE :
            msg = [NSString stringWithFormat:@"2nd parameter to sqlite3_bind out of range, ERROR #: %d",ret];
            break;
        case SQLITE_NOTADB :
            msg = [NSString stringWithFormat:@"File opened that is not a database file, ERROR #: %d",ret];
            break;
        case SQLITE_NOTICE :
            msg = [NSString stringWithFormat:@"Notifications from sqlite3_log(), ERROR #: %d",ret];
            break;
        case SQLITE_WARNING :
            msg = [NSString stringWithFormat:@"Warnings from sqlite3_log(), ERROR #: %d",ret];
            break;
        case SQLITE_ROW :
            msg = [NSString stringWithFormat:@"sqlite3_step() has another row ready, ERROR #: %d",ret];
            break;
        case SQLITE_DONE :
            msg = [NSString stringWithFormat:@"sqlite3_step() has finished executing , ERROR #: %d",ret];
            break;
        default:
            msg = [NSString stringWithFormat:@"UNKNOWN Error Number: %d",ret];
            break;
    }
    return msg;
}
#pragma mark Get Database Path
//NOTE: Pass the Database Name to find the Path of the database
//USEDBY: GENERAL, copyDbIfNeeded
-(NSString *) getDatabasePath :(NSString *) DBNAME
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    return [docPath stringByAppendingPathComponent:DBNAME];
}
#pragma mark Copy DB if Needed
//NOTE: Pass the name of the database to see if we need to copy the database from the application directory to the documents directory
//USEDBY: GENERAL & restoreFactoryDB
-(void) copyDbIfNeeded :(NSString *) DBNAME MessageHandler:(NSString **) msg
{
    NSString *myDBinAppPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DBNAME];
    NSString *myDBinDocsPath = [self getDatabasePath:DBNAME];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:myDBinDocsPath]) {
        NSError *error;
        BOOL success;
        success = [fileManager copyItemAtPath:myDBinAppPath toPath:myDBinDocsPath error:&error];
        if (!success) {
            *msg = [NSString stringWithFormat:@"Error coping database: %@.",[error localizedDescription]];
        }
    }
    
    fileManager = nil;
}
#pragma mark Restory Factory Database
//NOTE: Retore the Factory Database by deleting the database in the user docs and copying it back over.
//USEDBBY: GENERAL
-(void) restoreFactoryDB :(NSString *) DBNAME MessageHandler:(NSString **) msg
{
    NSString *myDBinDocsPath = [self getDatabasePath:DBNAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:myDBinDocsPath]){
        NSError *error;
        BOOL success;
        success = [fileManager removeItemAtPath:myDBinDocsPath error:&error];
        if (!success) {
            *msg = [NSString stringWithFormat:@"Error deleting database: %@",[error localizedDescription]];
        } else {
            [self copyDbIfNeeded:DBNAME MessageHandler:msg];
        }
    }
    
    fileManager = nil;
}
#pragma mark Check Database
//NOTE: Pass the Database name to see if the database is in the path that we need it to be in
//USEDBY: GENERAL
-(void)checkDB :(NSString *) DBNAME MessageHandler:(NSString **) msg
{
    NSString *dbPathString = [self getDatabasePath:DBNAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dbPathString]) {
        *msg = [NSString stringWithFormat:@"Database is missing from Path! %@", dbPathString];
    } else {
        *msg = @"Database found!";
    }
    fileManager = nil;
}
#pragma mark Execute Statements
//NOTE: Pass a SQL statement, and the database path to execute a statement, if it passes ok, then it will return true
//USEDBY: GENERAL
-(BOOL) runQuery :(NSString *) mysql DatabasePath:(NSString *) DBPath MessageHandler:(NSString **) msg
{
    char *error;
    BOOL bAns=NO;
    if (sqlite3_open([DBPath UTF8String], &MYDB) == SQLITE_OK) {
        if (sqlite3_exec(MYDB, [mysql UTF8String], NULL, NULL, &error) == SQLITE_OK) {
            //*msg = @"";
            sqlite3_close(MYDB);
            MYDB = nil;
            bAns = YES;
        } else {
            *msg = [NSString stringWithFormat:@"Error while executing query: %s",sqlite3_errmsg(MYDB)];
            sqlite3_close(MYDB);
            bAns = NO;
        }
    } else
    {
        *msg = @"error while opening database!";
        sqlite3_close(MYDB);
        bAns = NO;
    }
    return bAns;
}

#pragma mark See if Data Exists
//NOTE: Pass a SQL statement and the database path to see if any rows are returned from that statement, if there is something it will return true
//USEDBY: GENERAL
-(BOOL) dataExistsbyQuery :(NSString *) sql DatabasePath:(NSString *)dbPath MessageHandler:(NSString **) msg
{
    sqlite3_stmt *statement;
    int rows = 0;
    BOOL bAns = NO;
    if (sqlite3_open([dbPath UTF8String], &MYDB)==SQLITE_OK)
    {
        int ret = sqlite3_prepare_v2(MYDB,[sql UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ERROR){
                *msg = [NSString stringWithFormat:@"Error while counting rows: %s.", sqlite3_errmsg(MYDB)];
                bAns=NO;
            } else {
                rows = sqlite3_column_int(statement,0);
                if (rows > 0 ){
                    *msg = [NSString stringWithFormat:@"Found %i rows",rows];
                    bAns=YES;
                } else {
                    *msg = @"No rows found!";
                    bAns=NO;
                }
            }
        } else {
            *msg = [NSString stringWithFormat:@"Error in statement! %s", sqlite3_errmsg(MYDB)];
            bAns=NO;
        }
        sqlite3_close(MYDB);
        sqlite3_finalize(statement);
        MYDB = nil;
    } else {
        *msg = [NSString stringWithFormat:@"Error while attempting to connection! %s",sqlite3_errmsg(MYDB)];
        sqlite3_close(MYDB);
        bAns= NO;
    }
    MYDB = nil;
    return bAns;
}
#pragma mark Get Data from Database
//NOTE: Pass the Name/Value that you are looking for, the column name that it would be in, the Column that that Would Contain an ID that you want, the name of the table, and the database path to get the ID value,  Used to Look up ID of a value in the table to be referenced in your code.
//USEDBY: GENERAL
-(NSNumber *) getLastOneEntryIDbyName :(NSString *) name LookForColumnName:(NSString *) searchcolumn GetIDFomColumn:(NSString *) getfromcolumn InTable:(NSString *) tablename DatabasePath:(NSString *) dbPath MessageHandler:(NSString **) msg
{
    NSNumber *iAns = 0;
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ from %@ where lower(%@)='%@' order by %@ desc limit 1",getfromcolumn,tablename,searchcolumn,[name lowercaseString],getfromcolumn];
    
    if (sqlite3_open([dbPath UTF8String], &MYDB) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        int ret = sqlite3_prepare_v2(MYDB, [sql UTF8String], -1, &statement, NULL);
        if (ret == SQLITE_OK){
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                iAns = [NSNumber numberWithInt:sqlite3_column_int(statement, 0)];
            }
            sqlite3_close(MYDB);
            MYDB = nil;
        } else {
            *msg = [NSString stringWithFormat:@"Error while executing statement! %s", sqlite3_errmsg(MYDB)];
                    sqlite3_close(MYDB);
        }
        sqlite3_finalize(statement);
    } else {
        *msg = [NSString stringWithFormat:@"Error occured while attempting to connect to database! %s", sqlite3_errmsg(MYDB)];
    }
        
    return iAns;
}
#pragma mark Get Current Database Version
//NOTE: Get the current Database Version, usualy used for letting the application/user/tech support know if the two version match up
//USEDBY: GENERAL
-(NSString *) getCurrentDatabaseVersionfromTable:(NSString *) myTable DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **)errorMsg
{
    NSString *sAns = @"0";
    NSString *sql = [NSString stringWithFormat:@"select version from %@ order by id desc limit 1",myTable];
    
    if (sqlite3_open([dbPath UTF8String], &MYDB) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        int ret = sqlite3_prepare_v2(MYDB, [sql UTF8String], -1, &statement, NULL);
        if (ret == SQLITE_OK)
        {
            while (sqlite3_step(statement) ==SQLITE_ROW)
            {
                sAns = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement,0)];
            }
            sqlite3_close(MYDB);
            MYDB = nil;
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while executing statement! %s",sqlite3_errmsg(MYDB)];
            sqlite3_close(MYDB);
        }
        sqlite3_finalize(statement);
    } else {
        *errorMsg = [NSString stringWithFormat:@"Error occured while attempting to connect to database! %s", sqlite3_errmsg(MYDB)];
    }
    
    return sAns;
}
#pragma mark Version Exists
// This will check to see if a previouc version exists of the hotfix, if it exists it will skip updating the database.
//USEDBY: DBUpgrade.m
-(BOOL) VersionExists:(NSString *) myCurrentVersion VersionTable:(NSString *) myTable DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg
{
    BOOL bAns = NO;
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where version=%@",myTable,myCurrentVersion];
    
    if (sqlite3_open([dbPath UTF8String], &MYDB) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        int ret = sqlite3_prepare_v2(MYDB, [sql UTF8String], -1, &statement, NULL);
        if (ret == SQLITE_OK)
        {
            while (sqlite3_step(statement) ==SQLITE_ROW)
            {
                bAns = YES;
            }
            sqlite3_close(MYDB);
            MYDB = nil;
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while executing statement! %s",sqlite3_errmsg(MYDB)];
            sqlite3_close(MYDB);
        }
        sqlite3_finalize(statement);
    }else {
        *errorMsg = [NSString stringWithFormat:@"Error occured while attempting to connect to database! %s", sqlite3_errmsg(MYDB)];
    }
    return bAns;
}
-(int) getTotalNumberofRowsInTable:(NSString *) myTable DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg
{
    int iAns = 0;
    NSString *sql = [NSString stringWithFormat:@"select count(*) as mytotal from %@", myTable];
    if (sqlite3_open([dbPath UTF8String], &MYDB) == SQLITE_OK )
    {
        sqlite3_stmt *statement;
        int ret = sqlite3_prepare_v2(MYDB, [sql UTF8String], -1, &statement, NULL);
        if (ret == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                iAns = sqlite3_column_int(statement, 0);
            }
            sqlite3_close(MYDB);
            MYDB = nil;
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while executing statement! %s",sqlite3_errmsg(MYDB)];
            sqlite3_close(MYDB);
        }
        sqlite3_finalize(statement);
    } else {
        *errorMsg = [NSString stringWithFormat:@"Error occured while attempting to connect to database! %s", sqlite3_errmsg(MYDB)];
    }
    return iAns;
}
@end
