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
}
#pragma mark On Form Load
//When form first loads
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self LoadSettings];
    [self loadVersioning];
}

#pragma mark Load Settings
// Load the Database Path
-(void) LoadSettings;
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
}

#pragma mark Load Version
// Get the version of the App and the Database to view in the label boxes
-(void) loadVersioning
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    NSString *errorMsg;
    
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    self.lblAppVersion.text = [NSString stringWithFormat:@"%@.%@", appVersionString, appBuildString];
    self.lblDBVersion.text = [myObj getCurrentDatabaseVersionfromTable:@"DB_Version" DatabasePath:dbPathString ErrorMessage:&errorMsg];
}

#pragma mark Clear Oils
// Sub to clear the oils table
-(void) ClearDataOil
{
    NSString *statement;
    NSString *errorMsg;
    BurnSoftDatabase *objDB = [BurnSoftDatabase new];
    FormFunctions *objF = [FormFunctions new];
    NSString *myTitle = @"Clear Data";
    
    statement = @"DELETE from eo_remedy_oil_list";
    [objDB runQuery:statement DatabasePath:dbPathString MessageHandler:&errorMsg];
    [objF checkForError:errorMsg MyTitle:myTitle ViewController:self];
    
    statement = @"DELETE from eo_oil_list_details";
    [objDB runQuery:statement DatabasePath:dbPathString MessageHandler:&errorMsg];
    [objF checkForError:errorMsg MyTitle:myTitle ViewController:self];
    
    statement = @"DELETE from eo_oil_list";
    [objDB runQuery:statement DatabasePath:dbPathString MessageHandler:&errorMsg];
    [objF checkForError:errorMsg MyTitle:myTitle ViewController:self];
    
    [objF sendMessage:@"Data Cleared" MyTitle:@"This database is clean!" ViewController:self];
    
}

#pragma mark Clear Remedies
// Sub to clear the Remedies Table
-(void) ClearDataRemedy
{
    NSString *statement;
    NSString *errorMsg;
    BurnSoftDatabase *objDB = [BurnSoftDatabase new];
    FormFunctions *objF = [FormFunctions new];
    NSString *myTitle = @"Clear Data";
    
    statement = @"DELETE from eo_remedy_oil_list";
    [objDB runQuery:statement DatabasePath:dbPathString MessageHandler:&errorMsg];
    [objF checkForError:errorMsg MyTitle:myTitle ViewController:self];
    
    statement =@"DELETE from eo_remedy_list";
    [objDB runQuery:statement DatabasePath:dbPathString MessageHandler:&errorMsg];
    [objF checkForError:errorMsg MyTitle:myTitle ViewController:self];

    [objF sendMessage:@"Data Cleared" MyTitle:@"This database is clean!" ViewController:self];
    
}

#pragma mark Restore Factory Database
// Sub to restore the factory Database, copy it from app path to Doc's directory.
-(void) RestoreFactoryDatabase
{
    NSString *errorMsg;
    BurnSoftDatabase *objDB = [BurnSoftDatabase new];
    FormFunctions *objF = [FormFunctions new];
    NSString *myTitle = @"Restore Factory Database";
    
    [objDB restoreFactoryDB:@MYDBNAME MessageHandler:&errorMsg];
    
    
    [objF sendMessage:myTitle MyTitle:@"DB Restored to Factory." ViewController:self];
}
#pragma mark Clear Oils Button
// Button action to confirm and clear the Oils Table
- (IBAction)btnClearOils:(id)sender {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Clear Oils" message:@"Do you wish to clear out all the oils from the database?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Purify it!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {[self ClearDataOil];}];
    UIAlertAction *defaultNO = [UIAlertAction actionWithTitle:@"Never Mind" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {}];
    [alert addAction:defaultAction];
    [alert addAction:defaultNO];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
#pragma mark Clear Remedies Button
// Button action to confirm and clear the Remedies table
- (IBAction)btnClearRemedies:(id)sender {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Clear Remedies" message:@"Do you wish to clear out all the Remedies from the database?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Purify it!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {[self ClearDataRemedy];}];
    UIAlertAction *defaultNO = [UIAlertAction actionWithTitle:@"Never Mind" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {}];
    [alert addAction:defaultAction];
    [alert addAction:defaultNO];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
#pragma mark Restore Factory Button
// Button action to confirm and replace the database in the docs with the one in the apps directory
- (IBAction)btnRestoreFactory:(id)sender {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Restore Factory Database" message:@"Do you want to restore the the factory Database?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Restore!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {[self RestoreFactoryDatabase];}];
    UIAlertAction *defaultNO = [UIAlertAction actionWithTitle:@"Never Mind" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {}];
    [alert addAction:defaultAction];
    [alert addAction:defaultNO];
    
    [self presentViewController:alert animated:YES completion:nil];

}
#pragma mark Backup Database for iTunes
//This will make a copy of the database for iTunes to to retrived or in case you need to restore.
//This will make a backup file meo_datetime.bak
- (IBAction)btnBackUpDatabaseForiTunes:(id)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    FormFunctions *myObjFF = [FormFunctions new];
    
    NSDateFormatter *dateFormatter=[NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH_mm_ss"];
    
    NSString *newDBName = [NSString new];
    newDBName = [NSString stringWithFormat:@"meo_backup_%@.db",[dateFormatter stringFromDate:[NSDate date]]];
    
    NSError *error;
    BOOL success;
    NSString *msg;
    
    success = [fileManager copyItemAtPath:dbPathString toPath:newDBName error:&error];
    if (!success)
    {
        msg = [NSString stringWithFormat:@"Error backuping database: %@",[error localizedDescription]];
        [myObjFF sendMessage:msg MyTitle:@"Backup Error" ViewController:self];
    } else {
        msg = [NSString stringWithFormat:@"Backup Successful!"];
        [myObjFF sendMessage:msg MyTitle:@"Success!" ViewController:self];
    }
}

@end
