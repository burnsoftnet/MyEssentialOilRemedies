//
//  EDIT_OilDetailViewController.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 7/1/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//  StoryboardiD: EditOilDetails
//  test delete me later

#import "EDIT_OilDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface EDIT_OilDetailViewController ()

@end

@implementation EDIT_OilDetailViewController
{
    NSString *dbPathString;
    sqlite3 *MYDB;
}
#pragma mark Load Controller
//Sub to perform actions when the controller loads
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSettings];
    [self loadData];
    
    
    //Part of the dissmiss the keyboard functions
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}
#pragma mark Make Keyboard Dissapear
//When the view is selected, make the keyboard dissapear
-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.txtName resignFirstResponder];
    [self.txtCommonName resignFirstResponder];
    [self.txtDescription resignFirstResponder];
    [self.txtViscosity resignFirstResponder];
    [self.txtColor resignFirstResponder];
    [self.txtSafetyNotes resignFirstResponder];
    [self.txtIngredients resignFirstResponder];
    [self.txtBotanicalName resignFirstResponder];
}
#pragma mark View did reappear
//Sub when the form reloads
- (void)viewDidAppear:(BOOL)animated
{
    [self loadSettings];
    [self loadData];
}
#pragma mark Memroy Error
//Sub when a memory error occurs
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark Prepare For Segue
//Action to take before segue occurs
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditOilDetails"]) {
        EDIT_OilDetailViewController *destViewController = (EDIT_OilDetailViewController *)segue.destinationViewController;
        destViewController.OID = self.OID;
    }
}
#pragma mark Update Button
//Actions to take when the Update button is touched
- (IBAction)btnUpdate:(id)sender {
    BurnSoftGeneral *myObjOF = [BurnSoftGeneral new];
    BurnSoftDatabase *myObjDB = [BurnSoftDatabase new];
    FormFunctions *myObjF = [FormFunctions new];
    
    NSString *sql = @"";
    NSString *msg = @"";
    NSString *name = [myObjOF FCString:self.txtName.text];
    NSString *commonName = [myObjOF FCString:self.txtCommonName.text];
    NSString *BotName = [myObjOF FCString:self.txtBotanicalName.text];
    NSString *Ingredients = [myObjOF FCString:self.txtIngredients.text];
    NSString *safetyNotes = [myObjOF FCString:self.txtSafetyNotes.text];
    NSString *color = [myObjOF FCString:self.txtColor.text];
    NSString *viscosity = [myObjOF FCString:self.txtViscosity.text];
    NSString *description = [myObjOF FCString:self.txtDescription.text];
    NSString *iStock = 0;
    NSString *vendor = [myObjOF FCString:self.txtVendor.text];
    NSString *website = [myObjOF FCString:self.txtWebsite.text];
    
    if (self.swInStock.isOn){
        iStock = @"1";
    } else {
        iStock = @"0";
    }
    sql = [NSString stringWithFormat:@"UPDATE eo_oil_list set name='%@',instock=%i where OID=%@",name,[iStock intValue],self.OID];
    
    if ([myObjDB runQuery:sql DatabasePath:dbPathString MessageHandler:&msg]){
        if (!(self.OID==0)){
            sql = [NSString stringWithFormat:@"UPDATE eo_oil_list_details set description='%@',BotanicalName='%@',Ingredients='%@',SafetyNotes='%@',Color='%@',Viscosity='%@',CommonName='%@',vendor='%@',vendor_site='%@' where OID=%@",description,BotName,Ingredients,safetyNotes,color,viscosity,commonName,vendor,website, self.OID];
            
            if ([myObjDB runQuery:sql DatabasePath:dbPathString MessageHandler:&msg]) {
                UINavigationController *navController = self.navigationController;
                [navController popViewControllerAnimated:NO];
                [navController popViewControllerAnimated:YES];
            } else {
                [myObjF checkForError:msg MyTitle:@"Updating Details" ViewController:self];
            }
        }
    } else {
        [myObjF checkForError:msg MyTitle:@"Updating Name" ViewController:self];
    }
    
}
#pragma mark Load Settings
//Loads the Database Path and the borders to the textboxes
-(void) loadSettings
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
    FormFunctions *myFunctions = [FormFunctions new];
    
    [myFunctions setBordersTextView:self.txtIngredients];
    [myFunctions setBordersTextView:self.txtDescription];
    [myFunctions setBordersTextView:self.txtSafetyNotes];
    [myFunctions setBorderTextBox:self.txtName];
    [myFunctions setBorderTextBox:self.txtCommonName];
    [myFunctions setBorderTextBox:self.txtColor];
    [myFunctions setBorderTextBox:self.txtViscosity];
    [myFunctions setBorderTextBox:self.txtBotanicalName];
    [myFunctions setBorderTextBox:self.txtVendor];
    [myFunctions setBorderTextBox:self.txtWebsite];
}
#pragma mark Load Data
//Load the Data from the database to populate the fields
-(void) loadData
{
    sqlite3_stmt *statement;
    FormFunctions *objF = [FormFunctions new];
    if (sqlite3_open([dbPathString UTF8String],&MYDB) ==SQLITE_OK)
    {
        NSString *sql = [NSString stringWithFormat:@"select * from view_eo_oil_list_all where ID=%@", self.OID];
        int ret = sqlite3_prepare_v2(MYDB,[sql UTF8String],-1,&statement,NULL);
        int iCol = 0;
        if (ret == SQLITE_OK)
        {
            while (sqlite3_step(statement) ==SQLITE_ROW)
            {
                iCol = 1;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) { self.txtName.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 4;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.txtDescription.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 5;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.txtBotanicalName.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 6;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.txtIngredients.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 7;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.txtSafetyNotes.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 8;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.txtColor.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 9;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.txtViscosity.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 10;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.txtCommonName.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 2;
                NSString *iStock = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, iCol)];
                if ([iStock intValue] == 1) {
                    [self.swInStock setOn:YES];
                }
                iCol = 11;
                if (sqlite3_column_type(statement, iCol) != SQLITE_NULL) {self.txtVendor.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, iCol)];
                }
                iCol = 12;
                if (sqlite3_column_type(statement, iCol) != SQLITE_NULL) {self.txtWebsite.text = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, iCol)];
                }
                
            }
            sqlite3_close(MYDB);
            MYDB = nil;
        } else {
            NSString *msg = [NSString stringWithFormat:@"Error while creating select statmenet for oil editing!  %s", sqlite3_errmsg(MYDB)];
            [objF sendMessage:msg MyTitle:@"LoadData Error" ViewController:self];
        }
    } else {
        NSString *msg = [NSString stringWithFormat:@"Error while attempting to open the database! %s",sqlite3_errmsg(MYDB)];
        [objF sendMessage:msg MyTitle:@"OpenDatabase Error" ViewController:self];
    }
}
@end
