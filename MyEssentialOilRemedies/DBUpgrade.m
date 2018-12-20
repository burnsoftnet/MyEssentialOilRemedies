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
/*! @brief Checks the expected version of the app to see if the database needs to be upgraded by looking at it's version
    @remark USEDBY: MainStartViewController.m
 */
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
        } else if ([@MYDBVERSION doubleValue] == 1.2) {
            [self dbupgrade11];
            [self dbupgrade12];
            [self dbupgrade13];
            //Version 1.2 was released to production any upgrade after this will just need to be the latest dbupgrade.
        } else if ([@MYDBVERSION doubleValue] < 1.3 && [@MYDBVERSION doubleValue] > 1.2 ){
            [self dbupgrade13];
        }
    } else {
        [myObjFF doBuggermeMessage:@"DEBUG: DBVersion is equal to or greater than expected." FromSubFunction:@"DBUpgrade"];
    }
    
    myObj = nil;
    myObjFF = nil;
    dbVersion = 0;
    
}
+(void) checkDBVersionAgainstExpectedVersion
{
    DBUpgrade *obj = [DBUpgrade new];
    [obj checkDBVersionAgainstExpectedVersion];
    obj = nil;
}
#pragma mark DB Upgrade Version 1.1
/*! @brief  PRIVATE - Update Database to version 1.1
    @remark USEDBY: checkDBVersionAgainstExpectedVersion
 */
-(void) dbupgrade11
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    FormFunctions *myObjFF = [FormFunctions new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
    double newDBVersion = 0;
    NSString *msg;
    NSString *sqlstmt = [NSString new];
    newDBVersion = 1.1;
    
    if (![myObj VersionExists:[NSString stringWithFormat:@"%f",newDBVersion] VersionTable:@"DB_Version" DatabasePath:dbPathString ErrorMessage:&msg])
    {
        // Send to doBuggermeMessage if enabled, that the database upgrade is begining
        msg = [NSString stringWithFormat:@"DEBUG: Start DBVersion Upgrade to version %.01f", newDBVersion];
        [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
        
        // Alter Table Add New Column "vendor"
        sqlstmt=@"ALTER TABLE eo_oil_list_details ADD COLUMN vendor STRING(255);";
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        // Alter Table Add New Column "vendor_site"
        sqlstmt=@"ALTER TABLE eo_oil_list_details ADD COLUMN vendor_site TEXT;";
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        // Drop View Before Create
        sqlstmt=@"DROP VIEW view_eo_oil_list_all";
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        // Create View
        sqlstmt=@"CREATE VIEW view_eo_oil_list_all as SELECT ol.ID, ol.name, ol.INSTOCK, old.ID as DetailsID,old.description, old.BotanicalName,old.Ingredients, old.SafetyNotes, old.Color,old.Viscosity, old.CommonName, old.vendor, old.vendor_site from eo_oil_list ol inner join eo_oil_list_details old on old.OID=ol.ID";
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        //Update Database to current Version
        sqlstmt=[NSString stringWithFormat:@"INSERT INTO DB_Version (version) VALUES('%.01f')", newDBVersion];
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        // Send to doBuggermeMessage if enabled that the database was upgraded
        msg = [NSString stringWithFormat:@"DEBUG: End DBVersion Upgrade to version %.01f", newDBVersion];
        [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
    } else {
        msg = [NSString stringWithFormat:@"DEBUG: Database has already had %.01f patch applied!",newDBVersion];
        [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
    }
    
}
#pragma mark DB Upgrade Version 1.2
/*! @brief  PRIVATE Update Database to version x.x
    @remark USEDBY: checkDBVersionAgainstExpectedVersion
*/
-(void) dbupgrade12
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    FormFunctions *myObjFF = [FormFunctions new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
    double newDBVersion = 0;
    NSString *msg;
    NSString *sqlstmt = [NSString new];
    newDBVersion = 1.2;
    if (![myObj VersionExists:[NSString stringWithFormat:@"%f",newDBVersion] VersionTable:@"DB_Version" DatabasePath:dbPathString ErrorMessage:&msg])
    {
        // Send to doBuggermeMessage if enabled, that the database upgrade is begining
        msg = [NSString stringWithFormat:@"DEBUG: Start DBVersion Upgrade to version %.01f", newDBVersion];
        [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
        
        // Drop View Before Create
        sqlstmt=@"DROP VIEW view_oils_in_remedy";
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        // Create View
        sqlstmt=@"CREATE VIEW view_oils_in_remedy as SELECT ro.RID,ol.name,ol.instock,ro.ID,ro.OID, rl.name as remedy from eo_remedy_oil_list ro inner join eo_oil_list ol on ol.id=ro.OID inner join eo_remedy_list rl on rl.id=ro.RID";
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        //Update Database to current Version
        sqlstmt=[NSString stringWithFormat:@"INSERT INTO DB_Version (version) VALUES('%.01f')", newDBVersion];
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        // Send to doBuggermeMessage if enabled that the database was upgraded
        msg = [NSString stringWithFormat:@"DEBUG: End DBVersion Upgrade to version %.01f", newDBVersion];
        [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
    } else {
        msg = [NSString stringWithFormat:@"DEBUG: Database has already had %.01f patch applied!",newDBVersion];
        [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
    }

}
#pragma mark DB Upgrade Version x.x
/*! @brief PRIVATE - Update Database to version x.x
    @remark USEDBY: checkDBVersionAgainstExpectedVersion
 */
-(void) dbupgrade13
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    FormFunctions *myObjFF = [FormFunctions new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
    double newDBVersion = 0;
    NSString *msg;
    NSString *sqlstmt = [NSString new];
    newDBVersion = 1.3;
    if (![myObj VersionExists:[NSString stringWithFormat:@"%f",newDBVersion] VersionTable:@"DB_Version" DatabasePath:dbPathString ErrorMessage:&msg])
    {
        // Send to doBuggermeMessage if enabled, that the database upgrade is begining
        msg = [NSString stringWithFormat:@"DEBUG: Start DBVersion Upgrade to version %.01f", newDBVersion];
        [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
        
        sqlstmt=@"ALTER TABLE eo_oil_list_details ADD isBlend INTEGER;";
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        sqlstmt=@"ALTER TABLE eo_oil_list_details ADD reorder INTEGER;";
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        sqlstmt=@"Update eo_oil_list_details set isBlend=0;";
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        sqlstmt=@"Update eo_oil_list_details set reorder=0;";
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        // Drop View Before Create
        sqlstmt=@"DROP VIEW view_eo_oil_list_all;";
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        sqlstmt=@"CREATE VIEW view_eo_oil_list_all AS SELECT ol.ID, ol.name, ol.INSTOCK, old.ID as DetailsID,old.description, old.BotanicalName,old.Ingredients, old.SafetyNotes, old.Color,old.Viscosity, old.CommonName, old.vendor, old.vendor_site , old.isBlend, old.reorder from eo_oil_list ol inner join eo_oil_list_details old on old.OID=ol.ID;";
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        //Update Database to current Version
        sqlstmt=[NSString stringWithFormat:@"INSERT INTO DB_Version (version) VALUES('%.01f')", newDBVersion];
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        // Send to doBuggermeMessage if enabled that the database was upgraded
        msg = [NSString stringWithFormat:@"DEBUG: End DBVersion Upgrade to version %.01f", newDBVersion];
        [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
    } else {
        msg = [NSString stringWithFormat:@"DEBUG: Database has already had %.01f patch applied!",newDBVersion];
        [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
    }
}

#pragma mark DB Upgrade Version x.x
/*! @brief  PRIVATE - Update Database to version x.x
    @remark USEDBY: checkDBVersionAgainstExpectedVersion
 */
-(void) dbupgradexx
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    FormFunctions *myObjFF = [FormFunctions new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
    double newDBVersion = 0;
    NSString *msg;
    NSString *sqlstmt = [NSString new];
    newDBVersion = 0.0;
    if (![myObj VersionExists:[NSString stringWithFormat:@"%f",newDBVersion] VersionTable:@"DB_Version" DatabasePath:dbPathString ErrorMessage:&msg])
    {
        // Send to doBuggermeMessage if enabled, that the database upgrade is begining
        msg = [NSString stringWithFormat:@"DEBUG: Start DBVersion Upgrade to version %.01f", newDBVersion];
        [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
        
        sqlstmt=@"";
        [myObj runQuery:sqlstmt DatabasePath:dbPathString MessageHandler:&msg];
        [myObjFF checkForErrorLogOnly:msg MyTitle:[NSString stringWithFormat:@"DB Version %.01f",newDBVersion]];
        
        // Send to doBuggermeMessage if enabled that the database was upgraded
        msg = [NSString stringWithFormat:@"DEBUG: End DBVersion Upgrade to version %.01f", newDBVersion];
        [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
    } else {
        msg = [NSString stringWithFormat:@"DEBUG: Database has already had %.01f patch applied!",newDBVersion];
        [myObjFF doBuggermeMessage:msg FromSubFunction:@"DBUpgrade"];
    }
}
@end
