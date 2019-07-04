//
//  SearchDatabase.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 9/23/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "SearchDatabase.h"

@implementation SearchDatabase
{
    NSMutableArray *remedyCollection;
    NSMutableArray *oilRemedyCollection;
    NSMutableArray *oilCollection;
    sqlite3 *OilDB;
}

#pragma mark Get All Search Data
/*! @brief Public Function that will combine the searchAllOilsAllData and searchAllRemediesAllData Private function into one array.
 */
-(NSMutableArray *) getAllSearchData:(NSString *) dbPath ErrorMessage:(NSString *) errorMsg
{
    NSMutableArray *myOilCollection;
    NSMutableArray *MyRemedyCollection;
    myOilCollection = [NSMutableArray new];
    MyRemedyCollection = [NSMutableArray new];
    
    myOilCollection = [self searchAllOilsAllData:dbPath ErrorMessage:&errorMsg];
    MyRemedyCollection = [self searchAllRemediesAllData:dbPath ErrorMessage:&errorMsg];
    return [[myOilCollection arrayByAddingObjectsFromArray:MyRemedyCollection] mutableCopy];
}

#pragma mark Get All Search Data Simple
/*! @brief Public Function that will combine the searchAllOilsListSimple and the SearchAllRemediesSimple Private functions into one array.
 */
-(NSMutableArray *) getAllSearchDataSimple:(NSString *) dbPath ErrorMessage:(NSString *) errorMsg
{
    NSMutableArray *myOilCollection;
    NSMutableArray *MyRemedyCollection;
    myOilCollection = [NSMutableArray new];
    MyRemedyCollection = [NSMutableArray new];
    NSMutableArray *myEndResults = [NSMutableArray new];
    
    myOilCollection = [self searchAllOilsListSimple:dbPath ErrorMessage:&errorMsg];
    MyRemedyCollection = [self searchAllRemediesSimple:dbPath ErrorMessage:&errorMsg];
    myEndResults = [[myOilCollection arrayByAddingObjectsFromArray:MyRemedyCollection] mutableCopy];
    return myEndResults;
}

#pragma mark Search All Oils Simple List
/*! @brief Private Function that will put all the Oils by Name in an Array
 */
-(NSMutableArray *) searchAllOilsListSimple :(NSString *) dbPath ErrorMessage: (NSString **) errorMsg;
{
    oilCollection = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPath UTF8String],&OilDB) == SQLITE_OK) {
        [oilCollection removeAllObjects];
        NSString *querySQL = [NSString stringWithFormat:@"select name,description,INSTOCK,ID,DetailsID from view_eo_oil_list_all order by name asc"];
        int ret = sqlite3_prepare_v2(OilDB,[querySQL UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement,0)];
                [oilCollection addObject:name];
            }
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while creating select statement for searchAllOilsList . '%s'", sqlite3_errmsg(OilDB)];
        }
        sqlite3_finalize(statement);
    }
    return oilCollection;
}

#pragma mark Simple Search all Remedies
/*! @brief Private Function that will put all the Remedies by Name in an Array.
 */
-(NSMutableArray *) searchAllRemediesSimple :(NSString *)dbPathString ErrorMessage:(NSString **)errorMsg
{
    remedyCollection = [NSMutableArray new];
    sqlite3_stmt *statement;
    if ( sqlite3_open([dbPathString UTF8String],&OilDB) == SQLITE_OK) {
        [remedyCollection removeAllObjects];
        NSString *querySQL = [NSString stringWithFormat:@"select * from eo_remedy_list order by name asc"];
        int ret = sqlite3_prepare_v2(OilDB,[querySQL UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK){
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *name = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,1)];
                [remedyCollection addObject:name];
            }
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error whie creating select statement for SearchAllRemedies . '%s'", sqlite3_errmsg(OilDB)];
        }
        sqlite3_finalize(statement);
    }
    return  remedyCollection;
}

#pragma mark Search All Remedies All Data
/*! @brief Private Function that is mostly used to combine the results from the Remedies table.  Mostly used for search.
*/
 -(NSMutableArray *) searchAllRemediesAllData : (NSString *)dbPathString ErrorMessage:(NSString **)errorMsg
{
    remedyCollection = [NSMutableArray new];
    sqlite3_stmt *statement;
    if ( sqlite3_open([dbPathString UTF8String],&OilDB) == SQLITE_OK) {
        [remedyCollection removeAllObjects];
        NSString *querySQL = [NSString stringWithFormat:@"select * from eo_remedy_list order by name asc"];
        int ret = sqlite3_prepare_v2(OilDB,[querySQL UTF8String],-1,&statement,NULL);
        if (ret ==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                NSString *name = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *MyCombinedResults = [NSString new];
                NSString *myDescription = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *myUses = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                MyCombinedResults = [NSString stringWithFormat:@"%@ - %@ - %@",name,myDescription,myUses];
                [remedyCollection addObject:MyCombinedResults];
            }
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error occured while creating select statement for searchAllRemediesAllData. '%s'", sqlite3_errmsg(OilDB)];
        }
        sqlite3_finalize(statement);
                              
    }
    return remedyCollection;
}

#pragma mark Search All Oils All Data
/*! @brief Private Function that is mostly used to combine the results from the Oils Table.  Mostly used for search.
 */
-(NSMutableArray *) searchAllOilsAllData : (NSString *) dbPathString ErrorMessage:(NSString **)errorMsg
{
    oilCollection  = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPathString UTF8String],&OilDB) ==SQLITE_OK) {
        [oilCollection removeAllObjects];
        NSString *querySQL = [NSString stringWithFormat:@"select name,description,BotanicalName,Ingredients,SafetyNotes,CommonName from view_eo_oil_list_all order by name asc"];
        int ret = sqlite3_prepare_v2(OilDB, [querySQL UTF8String], -1, &statement, NULL);
        if (ret == SQLITE_OK)
        {
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                NSString *description = [[NSString alloc ] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                NSString *botName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                NSString *Ingred = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                NSString *safetyNote = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                NSString *commonName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                NSString *myCombinedResults = [NSString stringWithFormat:@"%@ - %@ - %@ - %@ - %@ - %@",name,description,botName,Ingred,safetyNote,commonName];
                [oilCollection addObject:myCombinedResults];
            }
        }
    } else {
        *errorMsg = [NSString stringWithFormat:@"Error Occured while creating select statement for SearchAllOilsAllData. '%s'",sqlite3_errmsg(OilDB)];
    }
    return  oilCollection;
}
#pragma mark Get Oil ID by Name
 /*! @brief Public Function that will return the ID of the oil in the database if it is found in the database.
 This is mostly used in the search function since the display is not based on Object ID but by name so
 we need to figure out if it is an oil or a remedy since both the results are combined.
 If 0 if returned then it is something that is not in the Oil Database by that name.
 */
-(NSInteger) isOilbyName:(NSString *) sValue databasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg
{
    NSInteger iAns = 0;
    sqlite3_stmt *statement;
    if ( sqlite3_open([dbPath UTF8String],&OilDB) == SQLITE_OK)
    {
        NSString *sql = [NSString stringWithFormat:@"select id from eo_oil_list where name='%@'",sValue];
        int ret = sqlite3_prepare_v2(OilDB,[sql UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK)
        {
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                NSString *oid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,0)];
                iAns = [oid intValue];
            }
        }else {
            *errorMsg = [NSString stringWithFormat:@"Error whie creating select statement for isOilbyName . '%s'", sqlite3_errmsg(OilDB)];
        }
        sqlite3_finalize(statement);
    }
    return iAns;
}

#pragma mark Get Remedy ID by Name
/*! @brief Public Function that will return the ID of the Remedy in the database if it is found in the database.
 This is mostly used in the search function since the display is not based on Object ID but by name so
 we need to figure out if it is an oil or a remedy since both the results are combined.
 If 0 is returned then it is something that is not in the Remedy Database by that name.
 */
-(NSInteger) isRemedybyName:(NSString *) sValue databasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg
{
    NSInteger iAns = 0;
    sqlite3_stmt *statement;
    if ( sqlite3_open([dbPath UTF8String],&OilDB) == SQLITE_OK)
    {
        NSString *sql = [NSString stringWithFormat:@"select id from eo_remedy_list where name='%@'",sValue];
        int ret = sqlite3_prepare_v2(OilDB,[sql UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK)
        {
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                NSString *oid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,0)];
                iAns = [oid intValue];
            }
        }else {
            *errorMsg = [NSString stringWithFormat:@"Error whie creating select statement for isRemedybyName . '%s'", sqlite3_errmsg(OilDB)];
        }
        sqlite3_finalize(statement);
    }
    return iAns;
}
@end
