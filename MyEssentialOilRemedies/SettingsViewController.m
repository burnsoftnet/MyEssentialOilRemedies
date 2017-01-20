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
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self LoadSettings];
    [self loadVersioning];
}
-(void) LoadSettings;
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
   
}

-(void) loadVersioning
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    NSString *errorMsg;
    
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    self.lblAppVersion.text = [NSString stringWithFormat:@"%@.%@", appVersionString, appBuildString];
    self.lblDBVersion.text = [myObj getCurrentDatabaseVersionfromTable:@"DB_Version" DatabasePath:dbPathString ErrorMessage:&errorMsg];
}

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
-(void) RestoreFactoryDatabase
{
    NSString *errorMsg;
    BurnSoftDatabase *objDB = [BurnSoftDatabase new];
    FormFunctions *objF = [FormFunctions new];
    NSString *myTitle = @"Restore Factory Database";
    
    [objDB restoreFactoryDB:@MYDBNAME MessageHandler:&errorMsg];
    
    
    [objF sendMessage:myTitle MyTitle:@"DB Restored to Factory." ViewController:self];
}

- (IBAction)btnClearOils:(id)sender {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Clear Oils" message:@"Do you wish to clear out all the oils from the database?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Purify it!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {[self ClearDataOil];}];
    UIAlertAction *defaultNO = [UIAlertAction actionWithTitle:@"Never Mind" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {}];
    [alert addAction:defaultAction];
    [alert addAction:defaultNO];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnClearRemedies:(id)sender {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Clear Remedies" message:@"Do you wish to clear out all the Remedies from the database?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Purify it!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {[self ClearDataRemedy];}];
    UIAlertAction *defaultNO = [UIAlertAction actionWithTitle:@"Never Mind" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {}];
    [alert addAction:defaultAction];
    [alert addAction:defaultNO];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnRestoreFactory:(id)sender {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Restore Factory Database" message:@"Do you want to restore the the factory Database?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Restore!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {[self RestoreFactoryDatabase];}];
    UIAlertAction *defaultNO = [UIAlertAction actionWithTitle:@"Never Mind" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {}];
    [alert addAction:defaultAction];
    [alert addAction:defaultNO];
    
    [self presentViewController:alert animated:YES completion:nil];

}

@end
