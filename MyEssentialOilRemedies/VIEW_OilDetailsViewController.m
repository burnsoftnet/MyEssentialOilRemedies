//
//  VIEW_OilDetailsViewController.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/20/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//
//  StoryboardiD: ViewOilDetails

#import "VIEW_OilDetailsViewController.h"
#import "EDIT_OilDetailViewController.h"


@interface VIEW_OilDetailsViewController ()

@end

@implementation VIEW_OilDetailsViewController
{
    NSString *dbPathString;
    sqlite3 *MYDB;

}
- (void) viewDidAppear:(BOOL)animated
{

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSettings];
    [self loadData];
   
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editOils)];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) editOils {
    EDIT_OilDetailViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditOils"];
    destViewController.OID = self.OID;
    [self.navigationController pushViewController:destViewController animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditOilSegue"]) {
        EDIT_OilDetailViewController * destViewController = (EDIT_OilDetailViewController *)segue.destinationViewController;
       destViewController.OID = self.OID;
    }
}
-(void) loadSettings
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
    FormFunctions *myFunctions = [FormFunctions new];
    
    [myFunctions setBorderLabel:self.lblName];
    [myFunctions setBorderLabel:self.lblColor];
    [myFunctions setBorderLabel:self.lblViscosity];
    [myFunctions setBorderLabel:self.lblCommonName];
    [myFunctions setBordersTextView:self.lblDescription];
    [myFunctions setBorderLabel:self.lblIngredients];
    [myFunctions setBorderLabel:self.lblSafetyNotes];
    [myFunctions setBorderLabel:self.lblBotanicalName];
    
}

- (void) loadData {
    sqlite3_stmt *statement;
    FormFunctions *objF = [FormFunctions new];
    if (sqlite3_open([dbPathString UTF8String], &MYDB) ==SQLITE_OK)
    {
        NSString *sql = [NSString stringWithFormat:@"select * from view_eo_oil_list_all where ID=%@",self.OID];
        int ret = sqlite3_prepare_v2(MYDB,[sql UTF8String],-1,&statement,NULL);
        int iCol = 0;
        if (ret == SQLITE_OK)
        {
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                iCol = 1;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.lblName.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 4;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.lblDescription.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 5;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.lblBotanicalName.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 6;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.lblIngredients.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 7;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.lblSafetyNotes.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 8;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.lblColor.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 9;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.lblViscosity.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 10;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.lblCommonName.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];}
                iCol = 2;
                NSString *iStock = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, iCol)];
                if ([iStock intValue] == 1) {
                    [self.swInStock setOn:YES];
                }
            }
            sqlite3_close(MYDB);
            sqlite3_finalize(statement);
            MYDB = nil;
        } else {
            NSString *msg = [NSString stringWithFormat:@"Error while creating select statement for oil view. %s",sqlite3_errmsg(MYDB)];
            [objF sendMessage:msg MyTitle:@"LoadData Error" ViewController:self];
        }
    } else {
        NSString *msg = [NSString stringWithFormat:@"Error occured while attempting to open the database. %s",sqlite3_errmsg(MYDB)];
        [objF sendMessage:msg MyTitle:@"OpenDB Error" ViewController:self];
    }
}
- (IBAction)swUpdateStockStatus:(id)sender {
    //Allow the Use to updated if the oil is in stock or out of stock without having to go into editing.
    NSString *iStock = 0;
    NSString *errorMsg;
    if (self.swInStock.isOn){
        iStock = @"1";
    } else {
        iStock = @"0";
    }
    OilLists *objO = [OilLists new];
    [objO updateStockStatus:iStock OilID:self.OID DatabasePath:dbPathString ErrorMessage:&errorMsg];
}

- (IBAction)btnClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}
@end
