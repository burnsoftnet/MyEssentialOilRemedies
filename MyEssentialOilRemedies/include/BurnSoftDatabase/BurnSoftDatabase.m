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

#pragma mark Get The Database Path Only
/*!
    @brief Just return that path of the location where the database is going to be stored
 */
+(NSString *) getDatabasePathOnly
{
    NSString *dbDirectory = [NSString stringWithFormat:@"/data/"];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingString:dbDirectory];
    return dbPath;
}

#pragma mark reset Database Directory
/*!
    @brief Delete the database directory and all the files in it, and recreate the directory empty
 */
+(BOOL) resetDBDirectory
{
    BOOL bAns = NO;
    BOOL isDir;
    NSString *dbPath = [self getDatabasePathOnly];
    NSFileManager *fileManager= [NSFileManager defaultManager];
    
    if ([fileManager removeItemAtPath:dbPath error:nil])
    {
        if(![fileManager fileExistsAtPath:dbPath isDirectory:&isDir])
        {
            bAns = [fileManager createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:NULL];
        }
    }
    
    return bAns;
}

#pragma mark Get Database Path and File Name
/*!
    @brief Pass the database Name to find the path of the database.
*/
+(NSString *) getDatabasePath :(NSString *) DBNAME
{
    //NSString *dbDirectory = [NSString stringWithFormat:@"/db/"];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    //NSString *dbPath = [docPath stringByAppendingString:dbDirectory];
    NSString *dbPath = [self getDatabasePathOnly];
    NSLog(@"%@", dbPath);
    BOOL isDir;
    NSString *fullDBPath = [dbPath stringByAppendingPathComponent:DBNAME];
    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:dbPath isDirectory:&isDir])
    {
        if([fileManager createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:NULL])
        {
            NSString *oldPathString = [docPath stringByAppendingPathComponent:DBNAME];
            if ([fileManager moveItemAtPath:oldPathString toPath:fullDBPath error:nil])
            {
                [fileManager removeItemAtPath:[docPath stringByAppendingPathComponent:@"MEO.db-shm"] error:nil];
                [fileManager removeItemAtPath:[docPath stringByAppendingPathComponent:@"MEO.db-wal"] error:nil];
            }
        }
    }
    
    return fullDBPath;
}

#pragma mark Copy the Database is needed
/*!
    @brief Pass the name of the database to see if we need to copy the database from the application directory to the documents directory
 */
+(void) copyDbIfNeeded :(NSString *) DBNAME MessageHandler:(NSString **) msg
{
    
    @try {
        NSString *myDBinAppPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DBNAME];
        NSString *myDBinDocsPath = [self getDatabasePath:DBNAME];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:myDBinDocsPath]) {
            NSError *error;
            BOOL success = [fileManager copyItemAtPath:myDBinAppPath toPath:myDBinDocsPath error:&error];
            //success = [fileManager copyItemAtPath:myDBinAppPath toPath:myDBinDocsPath error:&error];
            if (!success) [NSException raise:@"Copy Error" format:@"Error coping database: %@.",[error localizedDescription]];
                //{
                //*msg = [NSString stringWithFormat:@"Error coping database: %@.",[error localizedDescription]];
            //}
        }
        
        fileManager = nil;
    } @catch (NSException *exception) {
        *msg = [NSString stringWithFormat:@"%@",[exception reason]];
    }
   
}
#pragma mark Restory Factory Database
/*!
    @brief Retore the Factory Database by deleting the database in the user docs and copying it back over.
 */
-(void) restoreFactoryDB :(NSString *) DBNAME MessageHandler:(NSString **) msg
{
    NSString *myDBinDocsPath = [BurnSoftDatabase getDatabasePath:DBNAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:myDBinDocsPath]){
        NSError *error;
        BOOL success;
        success = [fileManager removeItemAtPath:myDBinDocsPath error:&error];
        if (!success) {
            *msg = [NSString stringWithFormat:@"Error deleting database: %@",[error localizedDescription]];
        } else {
            [BurnSoftDatabase copyDbIfNeeded:DBNAME MessageHandler:msg];
        }
    }
    
    fileManager = nil;
}
#pragma mark Check Database
/*!
    @brief Pass the Database name to see if the database is in the path that we need it to be in
 */
-(void)checkDB :(NSString *) DBNAME MessageHandler:(NSString **) msg
{
    NSString *dbPathString = [BurnSoftDatabase getDatabasePath:DBNAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dbPathString]) {
        *msg = [NSString stringWithFormat:@"Database is missing from Path! %@", dbPathString];
    } else {
        *msg = @"Database found!";
    }
    fileManager = nil;
}
#pragma mark Execute Statements
/*!
    @brief Pass a SQL statement, and the database path to execute a statement, if it passes ok, then it will return true
 */
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
#pragma mark update The Database Table before ann I cloud backup
/*!
    @brief This will add and delete a table to change the date modifed ont he file, since adding data doesn't really chnage the date.
 */
+(BOOL) updateDatabaseForiCloudBackup:(NSString *) DBPath MessageHandler:(NSString **) msg
{
    BOOL bAns= NO;
        BurnSoftDatabase *obj = [BurnSoftDatabase new];
    NSString *delTable =@"DROP TABLE IF EXISTS TEMPUPDATE;";
    [obj runQuery:delTable DatabasePath:DBPath MessageHandler:msg];
    NSString *sqlstmt=@"CREATE TABLE IF NOT EXISTS TEMPUPDATE (id INTEGER PRIMARY KEY);";
    bAns = [obj runQuery:sqlstmt DatabasePath:DBPath MessageHandler:msg];
    return bAns;
}

#pragma mark See if Data Exists
/*!
    @brief Pass a SQL statement and the database path to see if any rows are returned from that statement, if there is something it will return true
 */
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
/*!
    @brief Pass the Name/Value that you are looking for, the column name that it would be in, the Column that that Would Contain an ID that you want, the name of the table, and the database path to get the ID value,  Used to Look up ID of a value in the table to be referenced in your code.
 */
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
/*!
    @brief Get the current Database Version, usualy used for letting the application/user/tech support know if the two version match up
 */
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
/*!
    @brief This will check to see if a previouc version exists of the hotfix, if it exists it will skip updating the database.
 */
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
            sqlite3_finalize(statement);
            sqlite3_close(MYDB);
            MYDB = nil;
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while executing statement! %s",sqlite3_errmsg(MYDB)];
            sqlite3_finalize(statement);
            sqlite3_close(MYDB);
        }
        //sqlite3_finalize(statement);
    }else {
        *errorMsg = [NSString stringWithFormat:@"Error occured while attempting to connect to database! %s", sqlite3_errmsg(MYDB)];
    }
    return bAns;
}
#pragma mark Get Total Number of Rows in Table
/*!
    @brief Get the Total Number of Rosw in a Table
 */
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
#pragma mark Turn Off Journaling in SQLite Database
/*!
    @breif Turn off Journaling in the SQLLite Database
 */
 
+(BOOL) TurnOffJournaling:(NSString *) dbPath ErrorMessage:(NSString *_Nullable*) errMsg
{
    BOOL bAns = NO;
    NSString *sqlstmt=@"PRAGMA journal_mode=OFF;";
    BurnSoftDatabase *obj = [BurnSoftDatabase new];
    bAns = [obj runQuery:sqlstmt DatabasePath:dbPath MessageHandler:errMsg];
    return bAns;
}
@end
