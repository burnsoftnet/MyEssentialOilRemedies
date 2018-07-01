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
#warning #45 Code Optimization
    /*
    oilCollection = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPath UTF8String],&OilDB) == SQLITE_OK) {
        [oilCollection removeAllObjects];
        NSString *querySQL = [NSString stringWithFormat:@"select name,description,INSTOCK,ID,DetailsID,isBlend from view_eo_oil_list_all order by name COLLATE NOCASE ASC"];
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
                NSString *isBlend = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                
                OilLists *myCollection = [OilLists new];
                [myCollection setName:name];
                [myCollection setOID:[oid intValue]];
                [myCollection setInStock:InStock];
                [myCollection setMydescription:description];
                [myCollection setDetailsID:detailsid];
                [myCollection setIsBlend:isBlend];
                
                [oilCollection addObject:myCollection];
            }
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while creating select statement for getAllOilsList . '%s'", sqlite3_errmsg(OilDB)];
        }
        sqlite3_finalize(statement);
    }
    return oilCollection;
    */
     //NSString **errMsg=[NSString new];
    NSString *querySQL = [NSString stringWithFormat:@"select name,description,INSTOCK,ID,DetailsID,isBlend,reorder,BotanicalName,Ingredients,SafetyNotes,Color,Viscosity,CommonName,vendor,vendor_site from view_eo_oil_list_all order by name COLLATE NOCASE ASC"];
    return [self returnOilListsBySQLStatement:querySQL DatabasePath:dbPath ErrorMessage:errorMsg];
}
#pragma mark Get Only InStock Oils
//NOTE: This will return an array of only the oils that are in stock
//USEDBY:
-(NSMutableArray *) getInStockOilsList :(NSString *) dbPath : (NSString **) errorMsg;
{
    #warning #45 Code Optimization
    /*
    oilCollection = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPath UTF8String],&OilDB) == SQLITE_OK) {
        [oilCollection removeAllObjects];
        NSString *querySQL = [NSString stringWithFormat:@"select name,description,INSTOCK,ID,DetailsID,isBlend from view_eo_oil_list_all where INSTOCK=1 order by name COLLATE NOCASE ASC"];
        int ret = sqlite3_prepare_v2(OilDB,[querySQL UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement,0)];
                NSString *description = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,1)];
                NSString *InStock = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement,2)];
                NSString *oid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,4)];
                NSString *detailsid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,5)];
                NSString *isBlend = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 6)];
                
                OilLists *myCollection = [OilLists new];
                [myCollection setName:name];
                [myCollection setOID:[oid intValue]];
                [myCollection setInStock:InStock];
                [myCollection setMydescription:description];
                [myCollection setDetailsID:detailsid];
                [myCollection setIsBlend:isBlend];
                
                [oilCollection addObject:myCollection];
            }
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while creating select statement for getInStockOilsList . '%s'", sqlite3_errmsg(OilDB)];
        }
    }
    return oilCollection;
     */
     NSString *querySQL = [NSString stringWithFormat:@"select name,description,INSTOCK,ID,DetailsID,isBlend,reorder,BotanicalName,Ingredients,SafetyNotes,Color,Viscosity,CommonName,vendor,vendor_site from view_eo_oil_list_all where INSTOCK=1 order by name COLLATE NOCASE ASC"];
    return [self returnOilListsBySQLStatement:querySQL DatabasePath:dbPath ErrorMessage:errorMsg];
}
#pragma mark Private Return Oil Lists By SQL Statement
// Private function to return the oil list based on the sql statement, the fields for the SQL
// statement need to include:
// name,description,INSTOCK,ID,DetailsID,isBlend,reorder,BotanicalName,Ingredients,SafetyNotes,Color,Viscosity,CommonName,vendor,vendor_site
//in that order
- (NSMutableArray *) returnOilListsBySQLStatement :(NSString *) querySQL DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg
{
    oilCollection = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPath UTF8String],&OilDB) == SQLITE_OK) {
        [oilCollection removeAllObjects];
        int ret = sqlite3_prepare_v2(OilDB,[querySQL UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *name = @"";
                NSString *description = @"";
                NSString *InStock = @"";
                NSString *oid = @"";
                NSString *detailsid = @"";
                NSString *isBlend = @"";
                NSString *reOrder = @"";
                NSString *BotanicalName = @"";
                NSString *Ingredients = @"";
                NSString *SafetyNotes = @"";
                NSString *Color = @"";
                NSString *Viscosity = @"";
                NSString *CommonName = @"";
                NSString *Vendor = @"";
                NSString *VendorWeb = @"";
                int iCol=0;
                
                if ( sqlite3_column_type(statement, iCol) != SQLITE_NULL )
                {
                    name = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];
                }
                
                iCol = 1;
                if ( sqlite3_column_type(statement, iCol) != SQLITE_NULL )
                {
                    description = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];
                }
                
                iCol = 2;
                if ( sqlite3_column_type(statement, iCol) != SQLITE_NULL )
                {
                    InStock = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement,iCol)];
                }
                
                iCol = 3;
                if ( sqlite3_column_type(statement, iCol) != SQLITE_NULL )
                {
                    oid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];
                }
                
                iCol = 4;
                if ( sqlite3_column_type(statement, iCol) != SQLITE_NULL )
                {
                    detailsid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];
                }
                
                iCol = 5;
                if ( sqlite3_column_type(statement, iCol) != SQLITE_NULL )
                {
                    isBlend = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];
                }
                
                iCol = 6;
                
                if ( sqlite3_column_type(statement, iCol) != SQLITE_NULL )
                {
                    reOrder = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];
                }
                
                iCol = 7;
                if ( sqlite3_column_type(statement, iCol) != SQLITE_NULL )
                {
                    BotanicalName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];
                }
                
                iCol = 8;
                if ( sqlite3_column_type(statement, iCol) != SQLITE_NULL )
                {
                    Ingredients = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];
                }
                
                iCol = 9;
                if ( sqlite3_column_type(statement, iCol) != SQLITE_NULL )
                {
                    SafetyNotes = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];
                }
                
                iCol = 10;
                if ( sqlite3_column_type(statement, iCol) != SQLITE_NULL )
                {
                    Color = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];
                }
                
                iCol = 11;
                if ( sqlite3_column_type(statement, iCol) != SQLITE_NULL )
                {
                    Viscosity = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];
                }
                
                iCol = 12;
                if ( sqlite3_column_type(statement, iCol) != SQLITE_NULL )
                {
                    CommonName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];
                }
                
                iCol = 13;
                if ( sqlite3_column_type(statement, iCol) != SQLITE_NULL )
                {
                    Vendor = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];
                }
                
                iCol = 14;
                if ( sqlite3_column_type(statement, iCol) != SQLITE_NULL )
                {
                    VendorWeb = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];
                }
                
                OilLists *myCollection = [OilLists new];
                [myCollection setName:name];
                [myCollection setOID:[oid intValue]];
                [myCollection setInStock:InStock];
                [myCollection setMydescription:description];
                [myCollection setDetailsID:detailsid];
                [myCollection setIsBlend:isBlend];
                [myCollection setIsReOrder:reOrder];
                [myCollection setBotanicalName:BotanicalName];
                [myCollection setIngredients:Ingredients];
                [myCollection setSafetyNotes:SafetyNotes];
                [myCollection setColor:Color];
                [myCollection setViscosity:Viscosity];
                [myCollection setCommonName:CommonName];
                [myCollection setVendor:Vendor];
                [myCollection setVendorWebSite:VendorWeb];
                
                [oilCollection addObject:myCollection];
            }
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while creating select statement for returnOilListsBySQLStatement . '%s'", sqlite3_errmsg(OilDB)];
        }
    }
    return oilCollection;
}
#pragma mark Get Oils for Re-Order
// Get the list of oils that are marked for reOrder.
// Used By List_ReOrderTableViewController
- (NSMutableArray *) getOilsForReOrder: (NSString *) dbPath ErrorMessage:(NSString **) errorMsg
{
    NSString *querySQL = [NSString stringWithFormat:@"select name,description,INSTOCK,ID,DetailsID,isBlend,reorder,BotanicalName,Ingredients,SafetyNotes,Color,Viscosity,CommonName,vendor,vendor_site from view_eo_oil_list_all where reorder=1 order by name COLLATE NOCASE ASC"];
    return [self returnOilListsBySQLStatement:querySQL DatabasePath:dbPath ErrorMessage:errorMsg];
}

#pragma mark Get InStock Count from Database
//Function that will return all the oils marked as instock form the datbase
//USEDBY: listInStock
-(int) getInStockCountByDatabase :(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
{
#warning #45 Code REfacotring and consolidation
    /*
    int iAns = 0;
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPath UTF8String],&OilDB) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"select count(*) from view_eo_oil_list_all where INSTOCK=1 order by name COLLATE NOCASE ASC"];
        int ret = sqlite3_prepare_v2(OilDB,[querySQL UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                iAns = [[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement,0)] intValue];
            }
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while creating select statement for getOutOfStockOilsList. '%s'", sqlite3_errmsg(OilDB)];
        }

    }
    return iAns;
     */
    NSString *querySQL = [NSString stringWithFormat:@"select count(*) from view_eo_oil_list_all where INSTOCK=1 order by name COLLATE NOCASE ASC"];
    OilLists *myobj = [OilLists new];
    return [myobj getCountOfTableBySQL:querySQL DatabasePath:dbPath FromFunction:@"-listInStock" ErrorMessage:errorMsg];
}
#pragma mark List In Stock
//method version of the get instockcountbydatabase
+(int) listInStock:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg
{
    #warning #45 Code REfacotring and consolidation
    /*
    OilLists *myobj = [OilLists new];
    return [myobj getInStockCountByDatabase:dbPath ErrorMessage:errorMsg];
    */
    NSString *querySQL = [NSString stringWithFormat:@"select count(*) from view_eo_oil_list_all where INSTOCK=1 order by name COLLATE NOCASE ASC"];
    OilLists *myobj = [OilLists new];
    return [myobj getCountOfTableBySQL:querySQL DatabasePath:dbPath FromFunction:@"+listInStock" ErrorMessage:errorMsg];
}

#pragma mark Count all the items marked to reorder
//  Get a count of all the oils that are marked for order or re-order
+(int) listInShopping:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg
{
    NSString *querySQL = [NSString stringWithFormat:@"select count(*) from view_eo_oil_list_all where reorder=1 order by name COLLATE NOCASE ASC"];
    OilLists *myobj = [OilLists new];
    return [myobj getCountOfTableBySQL:querySQL DatabasePath:dbPath FromFunction:@"+listInStock" ErrorMessage:errorMsg];
}

-(int) getCountOfTableBySQL:(NSString *) querySQL DatabasePath:(NSString *) dbPath FromFunction:(NSString *) fromFunction ErrorMessage:(NSString **) errorMsg
{
    int iAns = 0;
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPath UTF8String],&OilDB) == SQLITE_OK) {
        int ret = sqlite3_prepare_v2(OilDB,[querySQL UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                iAns = [[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement,0)] intValue];
            }
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while creating select statement for '%@'. '%s'",fromFunction, sqlite3_errmsg(OilDB)];
        }
        
    }
    return iAns;
}

#pragma mark Get Only Out-Of-Stock Oils
//NOTE:  This will only return the oils that are out of stock
//USEDBY:
-(NSMutableArray *) getOutOfStockOilsList :(NSString *) dbPath : (NSString **) errorMsg;
{
    #warning #45 Code Optimization
    /*
    oilCollection = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPath UTF8String],&OilDB) == SQLITE_OK) {
        [oilCollection removeAllObjects];
        NSString *querySQL = [NSString stringWithFormat:@"select name,description,INSTOCK,ID,DetailsID,isBlend from view_eo_oil_list_all where INSTOCK=0 order by name COLLATE NOCASE ASC"];
        int ret = sqlite3_prepare_v2(OilDB,[querySQL UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement,0)];
                NSString *description = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,1)];
                NSString *InStock = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement,2)];
                NSString *oid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,4)];
                NSString *detailsid = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,5)];
                NSString *isBlend = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 6)];
                
                OilLists *myCollection = [OilLists new];
                [myCollection setName:name];
                [myCollection setOID:[oid intValue]];
                [myCollection setInStock:InStock];
                [myCollection setMydescription:description];
                [myCollection setDetailsID:detailsid];
                [myCollection setIsBlend:isBlend];
                
                [oilCollection addObject:myCollection];
            }
            sqlite3_close(OilDB);
        } else {
            *errorMsg = [NSString stringWithFormat:@"Error while creating select statement for getOutOfStockOilsList. '%s'", sqlite3_errmsg(OilDB)];
        }
    }
    return oilCollection;
     */
    NSString *querySQL = [NSString stringWithFormat:@"select name,description,INSTOCK,ID,DetailsID,isBlend,reorder,BotanicalName,Ingredients,SafetyNotes,Color,Viscosity,CommonName,vendor,vendor_site from view_eo_oil_list_all where INSTOCK=0 order by name COLLATE NOCASE ASC"];
    return [self returnOilListsBySQLStatement:querySQL DatabasePath:dbPath ErrorMessage:errorMsg];
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

#pragma mark Get Oil ID by Name
//Get the Oil ID by name, if it will check to see if it exists, if not, it will attempt to insert it and return the ID of that name.
+(NSNumber *) getOilIDByName:(NSString *) name InStock:(int) iStock DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString *_Nullable*) msg
{
    BurnSoftGeneral *myObjG = [BurnSoftGeneral new];
    BurnSoftDatabase *myObjDB = [BurnSoftDatabase new];
    OilLists *myOils = [OilLists new];
    
    NSString *errMsg = @"";
    NSNumber *nAns = 0;
    
    if (![myOils oilExistsByName:[myObjG FCString:name] DatabasePath:dbPathString ErrorMessage:&errMsg])
    {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO eo_oil_list (name,instock) VALUES ('%@',%i)",name,iStock];
        if ([myObjDB runQuery:sql DatabasePath:dbPathString MessageHandler:&errMsg])
        {
            nAns = [myObjDB getLastOneEntryIDbyName:name LookForColumnName:@"name" GetIDFomColumn:@"ID" InTable:@"eo_oil_list" DatabasePath:dbPathString MessageHandler:&errMsg];
        } else {
            *msg = errMsg;
        }
    } else {
        nAns = [myObjDB getLastOneEntryIDbyName:name LookForColumnName:@"name" GetIDFomColumn:@"ID" InTable:@"eo_oil_list" DatabasePath:dbPathString MessageHandler:&errMsg];
    }
    return  nAns;
}

#pragma mark Insert Oil Details
//Insert the Oil Details if sucessful then it will return true, else false if there was a problem with the insert
+(BOOL) insertOilDetailsByOID:(NSNumber *) MYOID Description:(NSString *) description BotanicalName:(NSString *) BotName Ingredients:(NSString *) ingredients SafetyNotes:(NSString *) safetyNotes Color:(NSString *) color Viscosity:(NSString *) viscosity CommonName:(NSString *) commonName Vendor:(NSString *) vendor WebSite:(NSString *) website Blended:(NSString *) isBlend DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString *_Nullable*) msg
{
    BOOL bAns = NO;
    NSString *errMsg = @"";
    BurnSoftGeneral *myObjG = [BurnSoftGeneral new];
    BurnSoftDatabase *myObjDB = [BurnSoftDatabase new];
    //TODO Need to Update Instert with the IsBlended
    //  Currently going to wait until the interface needs it and will concentrate on the display listing
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO eo_oil_list_details (OID,description,BotanicalName,Ingredients,SafetyNotes,Color,Viscosity,CommonName,vendor,vendor_site,isBlend) VALUES(%@,'%@','%@','%@','%@','%@','%@','%@','%@','%@',%i)", MYOID,[myObjG FCString:description],[myObjG FCString:BotName],[myObjG FCString:ingredients],[myObjG FCString:safetyNotes],[myObjG FCString:color],[myObjG FCString:viscosity],[myObjG FCString:commonName],[myObjG FCString:vendor],[myObjG FCString:website],[isBlend intValue]];
    
    if ([myObjDB runQuery:sql DatabasePath:dbPathString MessageHandler:&errMsg]) {
        bAns = YES;
    } else {
        bAns = NO;
        *msg = errMsg;
    }
    return bAns;
}

#pragma mark Update Oil Details
//Update the Oil Details if sucessful then it will return true, else false if there was a problem with the insert
+(BOOL) updateOilDetailsByOID:(NSNumber *) MYOID Description:(NSString *) description BotanicalName:(NSString *) BotName Ingredients:(NSString *) ingredients SafetyNotes:(NSString *) safetyNotes Color:(NSString *) color Viscosity:(NSString *) viscosity CommonName:(NSString *) commonName Vendor:(NSString *) vendor WebSite:(NSString *) website IsBlend:(NSString *) isblend DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString *_Nullable*) msg
{
    BOOL bAns = NO;
    NSString *errMsg = @"";
    BurnSoftGeneral *myObjG = [BurnSoftGeneral new];
    BurnSoftDatabase *myObjDB = [BurnSoftDatabase new];
    int iblend=[isblend intValue];
    
    //TODO:  Need to Update this section with the isBlended
    //  Currently going to wait until the interface needs it and will concentrate on the display listing
    NSString *sql = [NSString stringWithFormat:@"UPDATE eo_oil_list_details set description='%@',BotanicalName='%@',Ingredients='%@',SafetyNotes='%@',Color='%@',Viscosity='%@',CommonName='%@',vendor='%@',vendor_site='%@',isBlend=%i where OID=%@",[myObjG FCString:description],[myObjG FCString:BotName],[myObjG FCString:ingredients],[myObjG FCString:safetyNotes],[myObjG FCString:color],[myObjG FCString:viscosity],[myObjG FCString:commonName],[myObjG FCString:vendor],[myObjG FCString:website],iblend, MYOID];
    
    if ([myObjDB runQuery:sql DatabasePath:dbPathString MessageHandler:&errMsg]) {
        bAns = YES;
    } else {
        bAns = NO;
        *msg = errMsg;
    }
    return bAns;
}
@end
