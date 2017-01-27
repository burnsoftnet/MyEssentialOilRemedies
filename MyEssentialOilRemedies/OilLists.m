//
//  OilLists.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "OilLists.h"

@implementation OilLists
{
    NSMutableArray *oilCollection;
    NSMutableArray *remedyCollection;
    sqlite3 *OilDB;
}
#pragma mark Get List of Oils Only Name
//NOTE: This will Get the List of oils in the table and put them into an Array, This only returns the name
//USEDBY:
-(NSMutableArray *) getOilNameOnly :(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
{
    oilCollection = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPath UTF8String], &OilDB) == SQLITE_OK)
    {
        [oilCollection removeAllObjects];
        NSString *sql = [NSString stringWithFormat:@"select name from eo_oil_list order by name COLLATE NOCASE ASC"];
        int ret = sqlite3_prepare_v2(OilDB,[sql UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement,0)];
                
                OilLists *myCollection = [OilLists new];
                [myCollection setName:name];
                
                [oilCollection addObject:myCollection];
            }
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while creating select statement for getOilNameOnly . '%s'", sqlite3_errmsg(OilDB)];
        }
        sqlite3_finalize(statement);
    }
    return oilCollection;
}
#pragma mark "Oil Exists By Name
// Look up the oil by name to see if it already exists in the database, if it doesn't return NO, else yes
-(BOOL) oilExistsByName:(NSString *) oilname DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg
{
    BOOL bAns = NO;

    if (sqlite3_open([dbPath UTF8String], &OilDB) == SQLITE_OK)
    {
        NSString *sql = [NSString stringWithFormat:@"select * from eo_oil_list where name='%@' COLLATE NOCASE",oilname];
        sqlite3_stmt *statement;
        int ret = sqlite3_prepare_v2(OilDB,[sql UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                bAns = YES;
            }
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while creating select statement for oilExistsByName . '%s'", sqlite3_errmsg(OilDB)];
        }
        sqlite3_finalize(statement);
    }
    return  bAns;
}
#pragma mark Get Remedies that Contain Oil
//Gets the list of Remedies that have the oil listed in the Oils to remedy table, this does not include anything in the uses and description sections
-(NSMutableArray *) getRemediesRelatedToOilID :(NSString *) oilID DatabasePath: (NSString *) dbPath ErrorMessage:(NSString **) errorMsg
{
    remedyCollection = [NSMutableArray new];
    sqlite3_stmt * statement;
    if (sqlite3_open([dbPath UTF8String], &OilDB) == SQLITE_OK)
    {
        [remedyCollection removeAllObjects];
        NSString *sql = [NSString stringWithFormat:@"select rid,remedy from view_oils_in_remedy where OID=%@ order by name COLLATE NOCASE ASC",oilID];
        int ret = sqlite3_prepare_v2(OilDB,[sql UTF8String],-1, &statement, NULL);
        if (ret == SQLITE_OK)
        {
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                NSString *rid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                
                OilLists * myCollection = [OilLists new];
                [myCollection setRID:[rid intValue]];
                [myCollection setRemedyName:name];
                
                [remedyCollection addObject:myCollection];
            }
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error occured while creating select statement for  getRemediesRelatedtoOilID . '%s'", sqlite3_errmsg(OilDB)];
        }
        sqlite3_finalize(statement);
    }
    return remedyCollection;
}
#pragma mark Get List of Oils
//NOTE: This will Get the List of oils in the table and put them into an Array,
//      This returns the Name, Description, Stock Status, Oil ID and Details ID.
//USEDBY:
-(NSMutableArray *) getAllOilsList :(NSString *) dbPath : (NSString **) errorMsg;
{
    oilCollection = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPath UTF8String],&OilDB) == SQLITE_OK) {
        [oilCollection removeAllObjects];
        NSString *querySQL = [NSString stringWithFormat:@"select name,description,INSTOCK,ID,DetailsID from view_eo_oil_list_all order by name COLLATE NOCASE ASC"];
        int ret = sqlite3_prepare_v2(OilDB,[querySQL UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement,0)];
                NSString *description = [NSString new];
                
                if ( sqlite3_column_type(statement, 1) != SQLITE_NULL )
                {
                    description = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,1)];
                } else {
                    description = @" ";
                }
                NSString *InStock = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement,2)];
                NSString *oid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,3)];
                NSString *detailsid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,4)];
                
                OilLists *myCollection = [OilLists new];
                [myCollection setName:name];
                [myCollection setOID:[oid intValue]];
                [myCollection setInStock:InStock];
                [myCollection setMydescription:description];
                [myCollection setDetailsID:detailsid];
                
                [oilCollection addObject:myCollection];
            }
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while creating select statement for getAllOilsList . '%s'", sqlite3_errmsg(OilDB)];
        }
        sqlite3_finalize(statement);
    }
    return oilCollection;
}
#pragma mark Get Only InStock Oils
//NOTE: This will return an array of only the oils that are in stock
//USEDBY:
-(NSMutableArray *) getInStockOilsList :(NSString *) dbPath : (NSString **) errorMsg;
{
    oilCollection = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPath UTF8String],&OilDB) == SQLITE_OK) {
        [oilCollection removeAllObjects];
        NSString *querySQL = [NSString stringWithFormat:@"select name,description,INSTOCK,ID,DetailsID from view_eo_oil_list_all where INSTOCK=1 order by name COLLATE NOCASE ASC"];
        int ret = sqlite3_prepare_v2(OilDB,[querySQL UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement,0)];
                NSString *description = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,1)];
                NSString *InStock = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement,2)];
                NSString *oid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,4)];
                NSString *detailsid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,5)];
                
                OilLists *myCollection = [OilLists new];
                [myCollection setName:name];
                [myCollection setOID:[oid intValue]];
                [myCollection setInStock:InStock];
                [myCollection setMydescription:description];
                [myCollection setDetailsID:detailsid];
                
                [oilCollection addObject:myCollection];
            }
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while creating select statement for getInStockOilsList . '%s'", sqlite3_errmsg(OilDB)];
        }
    }
    return oilCollection;
}
#pragma mark Get Only Out-Of-Stock Oils
//NOTE:  This will only return the oils that are out of stock
//USEDBY:
-(NSMutableArray *) getOutOfStockOilsList :(NSString *) dbPath : (NSString **) errorMsg;
{
    oilCollection = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPath UTF8String],&OilDB) == SQLITE_OK) {
        [oilCollection removeAllObjects];
        NSString *querySQL = [NSString stringWithFormat:@"select name,description,INSTOCK,ID,DetailsID from view_eo_oil_list_all where INSTOCK=0 order by name COLLATE NOCASE ASC"];
        int ret = sqlite3_prepare_v2(OilDB,[querySQL UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement,0)];
                NSString *description = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,1)];
                NSString *InStock = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement,2)];
                NSString *oid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,4)];
                NSString *detailsid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,5)];
                
                OilLists *myCollection = [OilLists new];
                [myCollection setName:name];
                [myCollection setOID:[oid intValue]];
                [myCollection setInStock:InStock];
                [myCollection setMydescription:description];
                [myCollection setDetailsID:detailsid];
                
                [oilCollection addObject:myCollection];
            }
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while creating select statement for getOutOfStockOilsList. '%s'", sqlite3_errmsg(OilDB)];
        }
    }
    return oilCollection;
}
#pragma mark Delete Oil
//NOTE:  This will delete the oil from the database
//USEDBY:  Oil List View
-(void) deleteOil :(NSString * ) name :(NSString *) oid :(NSString *) dbPath :(NSString **) msg;
{
    char *error;
    if (sqlite3_open([dbPath UTF8String], &OilDB) == SQLITE_OK)
    {
        NSString *deleteQuery = @"";
        
        if (sqlite3_exec(OilDB,[deleteQuery UTF8String],NULL,NULL,&error) ==SQLITE_OK) {
            *msg = [NSString stringWithFormat:@"%@ was deleted!",name];
        } else {
            *msg = [NSString stringWithFormat:@"Error while creating select statement for Oil Lists. %s",sqlite3_errmsg(OilDB)];
        }
    }
}
#pragma mark Update Stock Status
//NOTE: This will update the oil Stock status, pass the new value In-Stock=1, Out-Of-Stock-0
//USEDBY: Oil List View
-(void) updateStockStatus :(NSString *) newValue OilID:(NSString *) myOID DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg
{
    BurnSoftDatabase *objDB = [BurnSoftDatabase new];
    NSString *sql = [NSString stringWithFormat:@"update eo_oil_list set INSTOCK=%@ where ID=%@",newValue,myOID];
    [objDB runQuery:sql DatabasePath:dbPath MessageHandler:errorMsg];
}
@end
