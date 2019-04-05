//
//  SettingsViewController.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/30/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController
{
    NSString *dbPathString;
    sqlite3 *OilDB;
    NSArray *filePathsArray;
}

#pragma mark Backup to iCloud Button
/*! @brief Action to start the backup to iCloud Drive
 */
- (IBAction)btnBackuptoiCloud:(id)sender {
    DatabaseManagement *myObjDM = [DatabaseManagement new];
    FormFunctions *myObjFF = [FormFunctions new];
    NSString *msg = [NSString new];
    [BurnSoftDatabase updateDatabaseForiCloudBackup:dbPathString MessageHandler:&msg];
    
    BOOL success = [myObjDM backupDatabaseToiCloudByDBName:@MYDBNAME LocalDatabasePath:dbPathString ErrorMessage:&msg];
    if (success){
        msg = [NSString stringWithFormat:@"Databae Backup was successful!"];
        [myObjFF sendMessage:msg MyTitle:@"Success!" ViewController:self];
    } else {
        [myObjFF sendMessage:msg MyTitle:@"ERROR!" ViewController:self];
    }
    [DatabaseManagement startiCloudSync];
    
    myObjDM = nil;
    myObjFF = nil;
}

#pragma mark Restore from iCloud Button
/*! @brief Action to start the restore from iCloud Drive
 */
- (IBAction)btnRestoreFromiCloud:(id)sender {
    [DatabaseManagement startiCloudSync];
    DatabaseManagement *myObjDM = [DatabaseManagement new];
    FormFunctions *myObjFF = [FormFunctions new];
    NSString *msg = [NSString new];
    BOOL success =[myObjDM restoreDatabaseFromiCloudByDBName:@MYDBNAME LocalDatabasePath:dbPathString ErrorMessage:&msg];
    if (success){
        DBUpgrade *myDB = [DBUpgrade new];
        [myDB checkDBVersionAgainstExpectedVersion];
        msg = [NSString stringWithFormat:@"Databae Restore was successful!"];
        [myObjFF sendMessage:msg MyTitle:@"Success!" ViewController:self];
    } else {
        [myObjFF sendMessage:msg MyTitle:@"ERROR!" ViewController:self];
    }
    
    myObjDM = nil;
    myObjFF = nil;
}
#pragma mark View will Disappear
/*! @brief Handle when the form is no longer active
 */
-(void) viewWillDisappear:(BOOL)animated
{
    dbPathString = nil;
    OilDB = nil;
    filePathsArray = nil;
    _lblAppVersion = nil;
    _lblDBVersion = nil;
}

#pragma mark On Form Load
/*! @brief When form first loads
 */
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self LoadSettings];
    [self loadVersioning];
    [FormFunctions setBackGroundImage:self.view];
    [FormFunctions setBackGroundImage:self.viewMain];
}

#pragma mark Form Loads Again
/*! @brief When the view reloads itself
 */
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
}

#pragma mark Reload Data
/*! @brief Reload the settings and information as if the form first load.
 */
-(void) reloadData
{
    [self LoadSettings];
    [self loadVersioning];
}

#pragma mark Load Settings
/*! @brief Load the Database Path
 */
-(void) LoadSettings;
{
    //BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    //dbPathString = [myObj getDatabasePath:@MYDBNAME];
    dbPathString = [BurnSoftDatabase getDatabasePath:@MYDBNAME];
    [DatabaseManagement startiCloudSync];
    //myObj = nil;
}

#pragma mark Load Version
/*! @brief Get the version of the App and the Database to view in the label boxes
 */
-(void) loadVersioning
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    NSString *errorMsg;
    
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    self.lblAppVersion.text = [NSString stringWithFormat:@"%@.%@", appVersionString, appBuildString];
    self.lblDBVersion.text = [myObj getCurrentDatabaseVersionfromTable:@"DB_Version" DatabasePath:dbPathString ErrorMessage:&errorMsg];
    
    myObj = nil;
    
}

#pragma mark Clear Oils
/*! @brief Sub to clear the oils table
 */
-(void) ClearDataOil
{
    NSString *statement;
    NSString *errorMsg;
    BurnSoftDatabase *objDB = [BurnSoftDatabase new];
    FormFunctions *objF = [FormFunctions new];
    
    statement = @"DELETE from eo_remedy_oil_list";
    [objDB runQuery:statement DatabasePath:dbPathString MessageHandler:&errorMsg];
    
    statement = @"DELETE from eo_oil_list_details";
    [objDB runQuery:statement DatabasePath:dbPathString MessageHandler:&errorMsg];
    
    statement = @"DELETE from eo_oil_list";
    [objDB runQuery:statement DatabasePath:dbPathString MessageHandler:&errorMsg];
    
    [objF sendMessage:@"Data Cleared" MyTitle:@"This database is clean!" ViewController:self];
    
    objDB = nil;
    objF = nil;
    
    
}

#pragma mark Clear Remedies
/*! @brief Sub to clear the Remedies Table
 */
-(void) ClearDataRemedy
{
    NSString *statement;
    NSString *errorMsg;
    BurnSoftDatabase *objDB = [BurnSoftDatabase new];
    FormFunctions *objF = [FormFunctions new];
    
    statement = @"DELETE from eo_remedy_oil_list";
    [objDB runQuery:statement DatabasePath:dbPathString MessageHandler:&errorMsg];
    
    statement =@"DELETE from eo_remedy_list";
    [objDB runQuery:statement DatabasePath:dbPathString MessageHandler:&errorMsg];

    [objF sendMessage:@"Data Cleared" MyTitle:@"This database is clean!" ViewController:self];
    
    objDB = nil;
    objF = nil;
}

#pragma mark Restore Factory Database
/*! @brief Sub to restore the factory Database, copy it from app path to Doc's directory.
 */
-(void) RestoreFactoryDatabase
{
    NSString *errorMsg;
    BurnSoftDatabase *objDB = [BurnSoftDatabase new];
    FormFunctions *objF = [FormFunctions new];
    NSString *myTitle = @"Restore Factory Database";
    
    [objDB restoreFactoryDB:@MYDBNAME MessageHandler:&errorMsg];
    [objF sendMessage:myTitle MyTitle:@"DB Restored to Factory." ViewController:self];
    
    objDB = nil;
    objF = nil;
    
}

#pragma mark Clear Oils Button
/*! @brief Button action to confirm and clear the Oils Table
 */
- (IBAction)btnClearOils:(id)sender {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Clear Oils" message:@"Do you wish to clear out all the oils from the database?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Purify it!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {[self ClearDataOil];}];
    UIAlertAction *defaultNO = [UIAlertAction actionWithTitle:@"Never Mind" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {}];
    [alert addAction:defaultAction];
    [alert addAction:defaultNO];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark Clear Remedies Button
/*! @brief Button action to confirm and clear the Remedies table
 */
- (IBAction)btnClearRemedies:(id)sender {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Clear Remedies" message:@"Do you wish to clear out all the Remedies from the database?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Purify it!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {[self ClearDataRemedy];}];
    UIAlertAction *defaultNO = [UIAlertAction actionWithTitle:@"Never Mind" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {}];
    [alert addAction:defaultAction];
    [alert addAction:defaultNO];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark Restore Factory Button
/*! @brief Button action to confirm and replace the database in the docs with the one in the apps directory
 */
- (IBAction)btnRestoreFactory:(id)sender {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Restore Factory Database" message:@"Do you want to restore the the factory Database?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Restore!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {[self RestoreFactoryDatabase];}];
    UIAlertAction *defaultNO = [UIAlertAction actionWithTitle:@"Never Mind" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {}];
    [alert addAction:defaultAction];
    [alert addAction:defaultNO];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark Delete File by Name
/*! @brief Delete the file + path that you want to delete
 */
-(BOOL)DeleteFileByName:(NSString *) sFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *deleteFile = [docPath stringByAppendingString:[NSString stringWithFormat:@"/%@",sFile]];
    
    NSError *error;
    BOOL success;
    NSString *msg;

    success = [fileManager removeItemAtPath:deleteFile error:&error];
    if (!success)
    {
        msg = [NSString stringWithFormat:@"Error deleting database: %@",[error localizedDescription]];
    }else {
        msg = [NSString stringWithFormat:@"Delete Successful!"];
    }
    
    fileManager = nil;
    
    return success;
}
@end
