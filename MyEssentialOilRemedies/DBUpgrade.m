//
//  DBUpgrade.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 12/30/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "DBUpgrade.h"

@implementation DBUpgrade
{
    NSString *dbPathString;
}
#pragma mark Check if DB needs upgrading
//NOTE: Checks the expected version of the app to see if the database needs to be upgraded by looking at it's version
//USEDBY: MainStartViewController.m
-(void) checkDBVersionAgainstExpectedVersion
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    FormFunctions *myObjFF = [FormFunctions new];
    NSString *errorMsg;
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
    double dbVersion = [[myObj getCurrentDatabaseVersionfromTable:@"DB_Version" DatabasePath:dbPathString ErrorMessage:&errorMsg] doubleValue];

    if ([@MYDBVERSION doubleValue] > dbVersion) {
        [myObjFF doBuggermeMessage:@"DEBUG: DBVersion is less than expected!!!" FromSubFunction:@"DBUpgrade"];
        if ([@MYDBVERSION doubleValue] == 1.1) {
            [self dbupgrade11];
        }
    } else {
        [myObjFF doBuggermeMessage:@"DEBUG: DBVersion is equal to or greater than expected." FromSubFunction:@"DBUpgrade"];
    }
}
#pragma mark DB Upgrade Version 1.1
//NOTE: Update Database to version 1.1
//USEDBY: checkDBVersionAgainstExpectedVersion
-(void) dbupgrade11
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    FormFunctions *myObjFF = [FormFunctions new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
    double newDBVersion = 0;
    NSString *msg;
    NSString *sqlstmt = [NSString new];
    newDBVersion = 1.1;
    
    msg = [NSString stringWithFormat:@"DEBUG: Start DBVersion Upgrade to version %.01f", newDBVersion];
    [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
    
    sqlstmt=@"ALTER TABLE eo_oil_list_details ADD COLUMN vendor STRING(255);";
    [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
    [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
    
    sqlstmt=@"ALTER TABLE eo_oil_list_details ADD COLUMN vendor_site TEXT;";
    [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
    [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
    
    sqlstmt=@"DROP VIEW view_eo_oil_list_all";
    [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
    [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
    
    sqlstmt=@"CREATE VIEW view_eo_oil_list_all as SELECT ol.ID, ol.name, ol.INSTOCK, old.ID as DetailsID,old.description, old.BotanicalName,old.Ingredients, old.SafetyNotes, old.Color,old.Viscosity, old.CommonName, old.vendor, old.vendor_site from eo_oil_list ol inner join eo_oil_list_details old on old.OID=ol.ID";
    [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
    [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
    
    sqlstmt=[NSString stringWithFormat:@"INSERT INTO DB_Version (version) VALUES('%.01f')", newDBVersion];
    [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
    [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
    msg = [NSString stringWithFormat:@"DEBUG: End DBVersion Upgrade to version %.01f", newDBVersion];
    [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
}
#pragma mark DB Upgrade Version x.x
//NOTE: Update Database to version x.x
//USEDBY: checkDBVersionAgainstExpectedVersion
-(void) dbupgradexx
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    FormFunctions *myObjFF = [FormFunctions new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
    double newDBVersion = 0;
    NSString *msg;
    NSString *sqlstmt = [NSString new];
    newDBVersion = 0.0;
    
    msg = [NSString stringWithFormat:@"DEBUG: Start DBVersion Upgrade to version %.01f", newDBVersion];
    [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
    
    sqlstmt=@"";
    [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
    [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
    
    msg = [NSString stringWithFormat:@"DEBUG: End DBVersion Upgrade to version %.01f", newDBVersion];
    [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
}

@end
