//
//  PopUpOilViewController.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 9/13/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "PopUpOilViewController.h"

@implementation PopUpOilViewController
{
    NSString * dbPathString;
    sqlite3 *MYDB;
}

#pragma mark On Form Load
/*! @brief When form first loads
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lblOilName.text = @"";
    self.lblDescription.text = @"";
    [self loadSettings];
    [self loadData];
    
}

#pragma mark Form Memory Error
/*! @brief When the form gets a memeory error
 */
-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Close Button
/*! @brief then the closed button is touched, it will close out the form
 */
- (IBAction)btnClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark Load Settings
/*! @brief load the database path and set borders
 */
-(void) loadSettings
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
    FormFunctions *myFunctions = [FormFunctions new];
    
    [myFunctions setBorderLabel:self.lblOilName];
    [myFunctions setBordersTextView:self.lblDescription];
}

#pragma mark Load Data
/*! @brief Loads the data from the database about a quick description of the selected oil.
 */
-(void) loadData
{
    sqlite3_stmt *statement;
    FormFunctions *objF = [FormFunctions new];
    if (sqlite3_open([dbPathString UTF8String], &MYDB) == SQLITE_OK)
    {
        NSString *sql = [NSString stringWithFormat:@"select * from view_eo_oil_list_all where name='%@'",self.myOilName];
        int iCol = 0;
        int ret =sqlite3_prepare_v2(MYDB,[sql UTF8String],-1,&statement,NULL);
        if (ret == SQLITE_OK)
        {
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                iCol=1;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) { self.lblOilName.text = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,iCol)];}
                iCol = 4;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) { self.lblDescription.text = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,iCol)];}
                
            }
            sqlite3_close(MYDB);
            sqlite3_finalize(statement);
            MYDB = nil;
        } else {
            NSString *msg = [NSString stringWithFormat:@"Error while loading Oil Details: %s",sqlite3_errmsg(MYDB)];
            [objF checkForError:msg MyTitle:@"Load Oil Details" ViewController:self];
        }
    } else {
        NSString *msg = [NSString stringWithFormat:@"Error while attempting to open database: %s",sqlite3_errmsg(MYDB)];
        [objF checkForError:msg MyTitle:@"Database" ViewController:self];
    }
}
@end
