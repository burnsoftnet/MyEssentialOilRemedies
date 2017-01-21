//
//  ADD_OilDetailsViewController.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/20/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//
//  StoryboardiD: AddOils

#import "ADD_OilDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ADD_OilDetailsViewController ()

@end

@implementation ADD_OilDetailsViewController
{
    NSString *dbPathString;
}
#pragma mark Controller Load
//Actions to take when the Controller Loads
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSettings];
    
    //Part of the function to make the keyboard dissapear when the view is selected
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}
#pragma mark Make Keyboard Dissapear
    //Dissmiss the keyboard when the view is selected
-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.txtName resignFirstResponder];
    [self.txtCommonName resignFirstResponder];
    [self.txtBotanicalName resignFirstResponder];
    [self.txtIngredients resignFirstResponder];
    [self.txtSafetyNotes resignFirstResponder];
    [self.txtColor resignFirstResponder];
    [self.txtViscosity resignFirstResponder];
    [self.txtDescription resignFirstResponder];
    [self.txtVedor resignFirstResponder];
    [self.txtWebsite resignFirstResponder];
}
#pragma mark Memroy Error
//events to take when a memory error occurs
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark LoadSettings
//Set the Database Path and Textbox borders
- (void)loadSettings
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
    FormFunctions *myFunctions = [FormFunctions new];
    [myFunctions setBordersTextView:self.txtSafetyNotes];
    [myFunctions setBordersTextView:self.txtIngredients];
    [myFunctions setBordersTextView:self.txtDescription];
    [myFunctions setBorderTextBox:self.txtName];
    [myFunctions setBorderTextBox:self.txtCommonName];
    [myFunctions setBorderTextBox:self.txtBotanicalName];
    [myFunctions setBorderTextBox:self.txtColor];
    [myFunctions setBorderTextBox:self.txtViscosity];
    [myFunctions setBorderTextBox:self.txtVedor];
    [myFunctions setBorderTextBox:self.txtWebsite];
}

#pragma mark Add Oil Button
//Perform actions to save database to database
- (IBAction)btnAdd:(id)sender {
    BurnSoftGeneral *myObjOF = [BurnSoftGeneral new];
    BurnSoftDatabase *myObjDB = [BurnSoftDatabase new];
    FormFunctions *myobjF = [FormFunctions new];
    
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
    NSString *vendor = [myObjOF FCString:self.txtVedor.text];
    NSString *website = [myObjOF FCString:self.txtWebsite.text];
    NSString *iStock = 0;
    
    if (self.swInStock.isOn){
        iStock = @"1";
    } else {
        iStock = @"0";
    }
    if (![name isEqualToString:@""])
    {
        sql = [NSString stringWithFormat:@"INSERT INTO eo_oil_list (name,instock) VALUES ('%@',%i)",name,[iStock intValue]];
        
        if ([myObjDB runQuery:sql DatabasePath:dbPathString MessageHandler:&msg]){
            NSNumber *MYOID = [myObjDB getLastOneEntryIDbyName:name LookForColumnName:@"name" GetIDFomColumn:@"ID" InTable:@"eo_oil_list" DatabasePath:dbPathString MessageHandler:&msg];
            if (!(MYOID==0)){
                sql = [NSString stringWithFormat:@"INSERT INTO eo_oil_list_details (OID,description,BotanicalName,Ingredients,SafetyNotes,Color,Viscosity,CommonName,vendor,vendor_site) VALUES(%@,'%@','%@','%@','%@','%@','%@','%@','%@','%@')", MYOID,description,BotName,Ingredients,safetyNotes,color,viscosity,commonName,vendor,website];
                
                if ([myObjDB runQuery:sql DatabasePath:dbPathString MessageHandler:&msg]) {
                    UINavigationController *navController = self.navigationController;
                    [navController popViewControllerAnimated:NO];
                    [navController popViewControllerAnimated:YES];
                } else {
                    [myobjF checkForError:msg MyTitle:@"Adding Details" ViewController:self];
                }
            }
        } else {
            [myobjF checkForError:msg MyTitle:@"Adding Name" ViewController:self];
        }
    } else {
        FormFunctions *myAlert = [FormFunctions new];
        [myAlert sendMessage:@"Please put in an Oil Name!" MyTitle:@"Missing Name" ViewController:self];
    }
    
}

@end
