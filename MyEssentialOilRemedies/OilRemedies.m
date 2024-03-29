//
//  OilRemedies.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "OilRemedies.h"

@implementation OilRemedies
{
    NSMutableArray *remedyCollection;
    NSMutableArray *oilRemedyCollection;
    NSMutableArray *EditOilsInRemedy;
    sqlite3 *OilDB;
}

#pragma mark Remedy Exists By Name
/*! @brief Look up the Remedy by name to see if it already exists in the database, if it doesn't return NO, else yes
 */
-(BOOL) RemedyExistsByName:(NSString *) oilname DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg
{
    BOOL bAns = NO;
    
    if (sqlite3_open([dbPath UTF8String], &OilDB) == SQLITE_OK)
    {
        NSString *sql = [NSString stringWithFormat:@"select * from eo_remedy_list where name='%@' COLLATE NOCASE",oilname];
        sqlite3_stmt *statement;
        int ret = sqlite3_prepare_v2(OilDB,[sql UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                bAns = YES;
            }
            sqlite3_finalize(statement);
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while creating select statement for RemedyExistsByName . '%s'", sqlite3_errmsg(OilDB)];
        }
    }
    return  bAns;
}

#pragma mark Get Remedy ID By Name
/*! @brief Look up the Remedy by name to get the ID in the database, if it doesn't return 0, else ID
 */
+(NSNumber *) getRemedyIDByName:(NSString *) Remedyname DatabasePath:(NSString *) dbPath ErrorMessage:(NSString *_Nullable*) errorMsg
{
    NSNumber *nAns = 0;
    BurnSoftDatabase *myObjDB = [BurnSoftDatabase new];
    NSString *errMsg = @"";
    nAns = [myObjDB getLastOneEntryIDbyName:Remedyname LookForColumnName:@"name" GetIDFomColumn:@"ID" InTable:@"eo_remedy_list" DatabasePath:dbPath MessageHandler:&errMsg];
    
    return nAns;
}

#pragma mark Get all Oils for Remedy
/*! @brief Array to get all the oils needed that have been tagged for a remedy based on the Remedy ID.
 @remark View Remedies, Edit Remedies
 */
-(NSMutableArray *) getAllOilfForremedyByRID:(NSString *) RID DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **)errorMsg
{
    oilRemedyCollection = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPathString UTF8String], &OilDB) == SQLITE_OK){
        [oilRemedyCollection removeAllObjects];
        NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * from view_oils_in_remedy where RID=%@",RID];
        if (sqlite3_prepare_v2(OilDB,[sqlQuery UTF8String],-1,&statement,NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *inStock = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];

                OilRemedies *myCollection = [OilRemedies new];
                [myCollection setOilInStock:inStock];
                [myCollection setName:name];
                [oilRemedyCollection addObject:myCollection];
            }
            sqlite3_finalize(statement);
            sqlite3_close(OilDB);
        }
        OilDB = nil;
    }
    return oilRemedyCollection;
}
#pragma mark Get all Oils for Remedy Name Only
/*! @brief  Array to get all the oils needed that have been tagged for a remedy based on the Remedy ID.
 @remark View Edit Remedies
 */
-(NSMutableArray *) getAllOilfForremedyByRIDNameOnly:(NSString *) RID DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **)errorMsg
{
    EditOilsInRemedy = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPathString UTF8String], &OilDB) == SQLITE_OK){
        [oilRemedyCollection removeAllObjects];
        NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * from view_oils_in_remedy where RID=%@",RID];
        if (sqlite3_prepare_v2(OilDB,[sqlQuery UTF8String],-1,&statement,NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                
                [EditOilsInRemedy addObject:name];
                
            }
            sqlite3_finalize(statement);
            sqlite3_close(OilDB);
        }
        OilDB = nil;
    }
    return EditOilsInRemedy;
}

#pragma mark Get a List of all Remedies Name Only
/*! @brief Array to get all the Remedies.
 @remark List, Edit remedy
 */
-(NSMutableArray *) getAllRemedies:(NSString *)dbPathString :(NSString **)errorMsg
{
    remedyCollection = [NSMutableArray new];
    sqlite3_stmt *statement;
    if ( sqlite3_open([dbPathString UTF8String],&OilDB) == SQLITE_OK) {
        [remedyCollection removeAllObjects];
        NSString *querySQL = [NSString stringWithFormat:@"select * from eo_remedy_list order by name COLLATE NOCASE ASC"];
        int ret = sqlite3_prepare_v2(OilDB,[querySQL UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK){
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *rid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,0)];
                NSString *name = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,1)];
                NSString *description = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,2)];
                NSString *uses = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,3)];
                NSString *section = section = [name substringToIndex:1];
                OilRemedies *myCollection = [OilRemedies new];
                [myCollection setName:name];
                [myCollection setRID:[rid intValue]];
                [myCollection setMyDescription:description];
                [myCollection setMyUses:uses];
                [myCollection setSection:section];
                
                [remedyCollection addObject:myCollection];
            }
            sqlite3_finalize(statement);
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error whie creating select statement for getAllRemedies . '%s'", sqlite3_errmsg(OilDB)];
        }
        //sqlite3_finalize(statement);
    }
    return  remedyCollection;
}
#pragma mark See if Oil Exists
/*! @brief  Checks to see if the oil already exists in the database by name
 @remark USEDFOR:  Add New Remedy, or Edit Remedy
 USEDBY: AddOilName, PRIVATE
 */
-(BOOL) oilNameExists:(NSString *) lookforoilname DatabasePath:(NSString *)dbPathString ERRORMESSAGE:(NSString **)errorMsg
{
    BOOL bAns;
    bAns = NO;
    NSString *statement;
    statement = [NSString stringWithFormat:@"select * from eo_oil_list where lower(name)='%@'",[lookforoilname lowercaseString]];
    
    BurnSoftDatabase *objDB = [BurnSoftDatabase new];
    bAns = [objDB dataExistsbyQuery:statement DatabasePath:dbPathString MessageHandler:errorMsg];
    return bAns;
}
#pragma mark Add Oil to Database
/*! @brief This will add the Oil to the Database, but it will check first to see if the oil is already in the database before adding, if it does exist, then it will get the oil ID to add to the remediy oil relations table.
 @remark  Add New Remedy, or Edit Remedy
 */
-(NSString *)AddOilName :(NSString *) myoilname DatabasePath:(NSString *)dbPathString ERRORMESSAGE:(NSString **) errorMsg
{
    NSString *sAns =@"0";
    NSString *statement;
    BurnSoftDatabase *objDB = [BurnSoftDatabase new];
    BurnSoftGeneral *objG = [BurnSoftGeneral new];

    myoilname = [objG FCString:myoilname];
    if ([self oilNameExists:myoilname DatabasePath:dbPathString ERRORMESSAGE:errorMsg])
    {
        sAns = [NSString stringWithFormat:@"%@",[objDB getLastOneEntryIDbyName:myoilname LookForColumnName:@"name" GetIDFomColumn:@"ID" InTable:@"eo_oil_list" DatabasePath:dbPathString MessageHandler:errorMsg]];
    } else
    {
        statement =[NSString stringWithFormat:@"INSERT INTO eo_oil_list (name) VALUES ('%@')",myoilname];
        [objDB runQuery:statement DatabasePath:dbPathString MessageHandler:errorMsg];
        sAns = [NSString stringWithFormat:@"%@",[objDB getLastOneEntryIDbyName:myoilname LookForColumnName:@"name" GetIDFomColumn:@"ID" InTable:@"eo_oil_list" DatabasePath:dbPathString MessageHandler:errorMsg]];
        statement = [NSString stringWithFormat:@"INSERT INTO eo_oil_list_details (OID,description,isBlend,reorder) VALUES(%@,'N/A',0,0)",[objG FCString:sAns]];
        [objDB runQuery:statement DatabasePath:dbPathString MessageHandler:errorMsg];
    }
    return sAns;
}
#pragma mark Add Oil to remedy Oil List
/*! @brief This works with AddOilName by the ID that is returned to add to the Remedy oil List relations table.
 @remark  Add New Remedy, or Edit Remedy
 */
-(void) addOilToremedyOilList:(NSString *) oilID RID:(NSString *) RemedyID DatabasePath:(NSString *) dbPathString ERRORMESSAGE:(NSString **) errorMsg
{
    NSString *statement;
    BurnSoftDatabase *objDB = [BurnSoftDatabase new];
    statement = [NSString stringWithFormat:@"INSERT INTO eo_remedy_oil_list (OID,RID) VALUES(%@,%@)",oilID,RemedyID];
    [objDB runQuery:statement DatabasePath:dbPathString MessageHandler:errorMsg];
}
#pragma mark Add Remedy to Database
/*! @brief  This will add the remedy to the database and Returnt he Remedy ID
 @remark tbSave Action in Remedy Edit and Add
 */
-(NSString *)AddRemedyDetailsByName:(NSString *) RemedyName Description:(NSString *) myDescription Uses:(NSString *) myUses DatabasePath:(NSString *) dbPathString ERRORMESSAGE:(NSString **) errorMsg
{
    NSString *sAns;
    NSString *statement;
    BurnSoftDatabase *objDB = [BurnSoftDatabase new];
    BurnSoftGeneral *objG = [BurnSoftGeneral new];
    
    BOOL bAns;
    statement = [NSString stringWithFormat:@"INSERT INTO eo_remedy_list (name,description,uses) VALUES('%@','%@','%@')",[objG FCString:RemedyName],[objG FCString:myDescription],[objG FCString:myUses]];
    bAns = [objDB runQuery:statement DatabasePath:dbPathString MessageHandler:errorMsg];
    if (bAns)
    {
        sAns = [NSString stringWithFormat:@"%@",[objDB getLastOneEntryIDbyName:RemedyName LookForColumnName:@"name" GetIDFomColumn:@"ID" InTable:@"eo_remedy_list" DatabasePath:dbPathString MessageHandler:errorMsg]];
    } else {
        sAns =@"0";
    }
    return sAns;
}
#pragma mark Update Remedy Details by RID
/*! @brief This will update the remedy details
 @remark Edit Remedy
 */
-(BOOL) updateRemedyDetailsByRID:(NSString *) RID Name:(NSString *) RemedyName Description:(NSString *) myDescription Uses:(NSString *) myUses DatabasePath:(NSString *) dbPathString ERRORMESSAGE:(NSString **) errorMsg
{
    BOOL bAns = NO;
    BurnSoftDatabase *objDB = [BurnSoftDatabase new];
    BurnSoftGeneral *objG = [BurnSoftGeneral new];
    
    NSString *sql = [NSString stringWithFormat:@"update eo_remedy_list set name='%@',description='%@',uses='%@' where ID=%@",[objG FCString:RemedyName],[objG FCString:myDescription],[objG FCString:myUses],RID];
    bAns = [objDB runQuery:sql DatabasePath:dbPathString MessageHandler:errorMsg];
    return bAns;
}
#pragma mark Delete Remedy
/*! @brief Delete the Remedy and the oils that are tagged to it without deleting the oils themselfs.
 @remark List Remedy Details.
 */
-(BOOL) deleteRemedyByID:(NSString *)RID DatabasePath:(NSString *) dbPathString MessageHandler:(NSString **) errorMsg
{
    BOOL bAns = NO;
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    NSString *sql =[NSString stringWithFormat:@"DELETE from eo_remedy_list where ID=%@",RID];
    
    if ([self ClearOilsPerRemedyByRID:RID DatabasePath:dbPathString MessageHandler:errorMsg])
    {
        if ([myObj runQuery:sql DatabasePath:dbPathString MessageHandler:errorMsg])
        {
            bAns = YES;
        }
    }
    
    return bAns;
}
#pragma mark Delete Related Links of Oils by Remedy ID
/*! @brief  This will delete all the oils that are int eh remedy oil list table that are tied to the RID:
 @remark deleteRemedyByID
 */
-(BOOL) ClearOilsPerRemedyByRID:(NSString *) RID DatabasePath:(NSString *) dbPathString MessageHandler:(NSString **) errorMsg
{
    BOOL bAns = NO;
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    NSString *sql = [NSString stringWithFormat:@"delete from eo_remedy_oil_list where RID=%@",RID];
    if ([myObj runQuery:sql DatabasePath:dbPathString MessageHandler:errorMsg])
    {
        bAns = YES;
    }
    
    return bAns;
}

#pragma mark Add Oils to Remedy
/*! @brief  This will delete all the oils that are int eh remedy oil list table that are tied to the RID:
 @remark deleteRemedyByID
 */
-(void) addOilsToRemedyByRemedyID:(NSString *) RID OilsArray:(NSArray *) oilList DatabasePath:(NSString *) dbpath ErrorMessage:(NSString **) ErrMsg
{
    NSString *oilName = [NSString new];
    NSString *errorMsg;
    NSString *OID;
    BurnSoftGeneral *myObjG = [BurnSoftGeneral new];
    
    for (int x = 0; x < [oilList count]; x++) {
        oilName = [myObjG FCString:oilList[x]];
        oilName = [oilName stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        OID = [self AddOilName:oilName DatabasePath:dbpath ERRORMESSAGE:&errorMsg];
        [self addOilToremedyOilList:OID RID:RID DatabasePath:dbpath ERRORMESSAGE:&errorMsg];
    }
}
@end
