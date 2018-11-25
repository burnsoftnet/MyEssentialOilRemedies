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
#import "VIEW_RemedyViewController.h"

@interface VIEW_OilDetailsViewController ()

@end

@implementation VIEW_OilDetailsViewController
{
    NSString *dbPathString;
    sqlite3 *MYDB;
    int currView;
    NSMutableArray *myRelatedRemedies;
    NSString *SelectedCellID;
}



#pragma mark View Did Appear
/*! @brief When the view appears again
 */
- (void) viewDidAppear:(BOOL)animated
{

}
#pragma mark Kill everything in the form when the form is no longer active
/*! @brief Kill everything in the form when the form is not longer active
 */
-(void) enduse
{
    _OID = nil;
    _RID = nil;
    _lblName = nil;
    _lblCommonName = nil;
    _lblBotanicalName = nil;
    _lblIngredients = nil;
    _lblSafetyNotes = nil;
    _lblColor = nil;
    _lblViscosity = nil;
    _swInStock = nil;
    _lblDescription = nil;
    _lblVendor = nil;
    _txtWebsite = nil;
    _viewContent = nil;
    _viewRelatedRemedies = nil;
    _RelatedRemediesTable = nil;
    
    myRelatedRemedies = nil;
    MYDB = nil;
    currView = 0;
    SelectedCellID = nil;
    dbPathString = nil;
}
#pragma mark View Did Disappear
/*! @brief When the form disappears set everything to null
 */
-(void) viewDidDisappear:(BOOL)animated
{
    [self enduse];
}

#pragma mark Controller Load
/*! @brief Actions to take when the Controller Loads
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSettings];
    [self loadData];
    [self LoadRelatedRemedies];
    [[self RelatedRemediesTable]setDelegate:self];
    [[self RelatedRemediesTable]setDataSource:self];
   
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editOils)];
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(startAction)];
    NSArray *NavArray = [NSArray new];
    NavArray = [[NSArray alloc] initWithObjects:actionButton,editButton, nil];
    self.navigationItem.rightBarButtonItems = NavArray;
    
    if (currView == 0) {
        [self changeCurrentViewTo:1];
    }

    [FormFunctions setBackGroundImage:self.view];
    [FormFunctions setBackGroundImage:self.viewContent];
    [FormFunctions setBackGroundImage:self.viewRelatedRemedies];
    [FormFunctions setBackGroundImage:self.RelatedRemediesTable];
}

#pragma mark Start Action Sheet
/*! @brief start the action sheet process and gather the data to send to the ActionClass
 */
-(void) startAction
{
    
    NSString *rawText = [ActionClass OilDetailsToStringByName:self.lblName.text CommonName:self.lblCommonName.text BotanicalName:self.lblBotanicalName.text Ingredients:self.lblIngredients.text SafetyNotes:self.lblSafetyNotes.text Color:self.lblColor.text Viscosity:self.lblViscosity.text InStock:[BurnSoftGeneral convertBOOLtoString:self.swInStock.isOn] Vendor:self.lblVendor.text WebSite:self.txtWebsite.text Description:self.lblDescription.text IsBlend:[BurnSoftGeneral convertBOOLtoString:self.swIsBlend.isOn]];
    
    
    NSString *XMLText = [BurnSoftGeneral FCStringXML:[Parser OilDetailsToXMLForInsertByName:self.lblName.text CommonName:self.lblCommonName.text BotanicalName:self.lblBotanicalName.text Ingredients:self.lblIngredients.text SafetyNotes:self.lblSafetyNotes.text Color:self.lblColor.text Viscosity:self.lblViscosity.text InStock:[BurnSoftGeneral convertBOOLtoString:self.swInStock.isOn] Vendor:self.lblVendor.text WebSite:self.txtWebsite.text Description:self.lblDescription.text IsBlend:[BurnSoftGeneral convertBOOLtoString:self.swIsBlend.isOn]]];
    
    NSString *outPutFile = [ActionClass writeOilDetailsToFileToSendByName:XMLText];

    NSArray *ActionObjects = @[[NSURL fileURLWithPath:outPutFile],rawText];
    
    [ActionClass sendToActionSheetViewController:self ActionSheetObjects:ActionObjects eMailSubject:[NSString stringWithFormat:@"Oil Details for: %@",self.lblName.text]];
}

#pragma mark Change Views
/*! @brief This will change the views when a button on the toolbar is touchec
    1 is Description view
    2 is Related Oils
 */
-(void)changeCurrentViewTo:(int) iValue
{
    switch (iValue) {
        case 1:
            self.viewContent.hidden = NO;
            self.viewRelatedRemedies.hidden = YES;
            break;
        case 2:
            self.viewContent.hidden = YES;
            self.viewRelatedRemedies.hidden = NO;
            break;
    }
}

#pragma mark Did Recieve Memory Warning
/*! @brief  Dispose of any resources that can be recreated.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Edit Oils
/*! @brief  Action to take when the Exit option is selected from the table.
 */
- (void) editOils {
    EDIT_OilDetailViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditOils"];
    destViewController.OID = self.OID;
    [self.navigationController pushViewController:destViewController animated:YES];
}

#pragma mark - Navigation
/*! @brief In a storyboard-based application, you will often want to do a little preparation before navigation
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditOilSegue"] || [segue.identifier isEqualToString:@"segueEditOilFromSearch"] ) {
        EDIT_OilDetailViewController * destViewController = (EDIT_OilDetailViewController *)segue.destinationViewController;
       destViewController.OID = self.OID;
        destViewController.IsFromSearch = YES;
    } else if ([segue.identifier isEqualToString:@"segueViewRemedyFromOils"]) {
        VIEW_RemedyViewController * destViewController = (VIEW_RemedyViewController *)segue.destinationViewController;
        destViewController.RID = SelectedCellID;
    }
}

#pragma mark Load Settings
/*! @brief Load Database Path and set the borders for the labels and text view
 */
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
    [myFunctions setBordersTextView:self.lblIngredients];
    [myFunctions setBorderLabel:self.lblSafetyNotes];
    [myFunctions setBorderLabel:self.lblBotanicalName];
    [myFunctions setBorderLabel:self.lblVendor];
    [myFunctions setBordersTextView:self.txtWebsite];
    
    myObj = nil;
    myFunctions = nil;
}

#pragma mark Load Related Remedies
/*! @brief  Load the related remedies in the table.
 */
-(void) LoadRelatedRemedies
{
    myRelatedRemedies = [NSMutableArray new];
    OilLists *myObj = [OilLists new];
    NSString *errMsg = [NSString new];
    myRelatedRemedies = [myObj getRemediesRelatedToOilID:self.OID DatabasePath:dbPathString ErrorMessage:&errMsg];
    
    myObj = nil;
}

#pragma mark Load Data
/*! @brief Connect to the database to load the fields with the data from the selected oil.
 */
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
                iCol=11;
                if (sqlite3_column_type(statement, iCol) != SQLITE_NULL) {self.lblVendor.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, iCol)];
                }
                iCol=12;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.txtWebsite.text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement,iCol)];
                }
                iCol=13;
                NSString *iBlend = @"0";
                if (sqlite3_column_type(statement, iCol) != SQLITE_NULL)
                {
                    iBlend = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, iCol)];
                }
                //#54 Attempt to comp for already null value
                //NSString *iBlend = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, iCol)];
                
                
                if ([iBlend intValue] == 1){
                    [self.swIsBlend setOn:YES];
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
    
    objF = nil;
}

#pragma mark Tab Description
/*! @brief  this will show the contentView when the description tab is touched
 */
- (IBAction)tbDescription:(id)sender {
    [self changeCurrentViewTo:1];
}

#pragma mark Tab Related Remedies
/*! @brief  this will show the Related Remedies when the Related Remedies tab is touched
 */
- (IBAction)tbRelatedRemedies:(id)sender {
    [self changeCurrentViewTo:2];
}

#pragma mark Update Stock Status
/*! @brief Allow the Use to updated if the oil is in stock or out of stock without having to go into editing.
 */
- (IBAction)swUpdateStockStatus:(id)sender {
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
#pragma mark Update Blend Status
/*! @brief Switch for Blend Status
 */
- (IBAction)swUpdateBlendStatus:(id)sender
{
    NSString *iBlend = 0;
    NSString *errorMsg;
    if (self.swIsBlend.isOn){
        iBlend = @"1";
    } else {
        iBlend = @"0";
    }
    
    [OilLists updateBlendStatusWithNewValue:iBlend OilID:self.OID DatabasePath:dbPathString ErrorMessage:&errorMsg];
}

#pragma mark Close Button from Search
/*! @brief Actions to take when the close button is touched
 */
- (IBAction)btnClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark Edit Button form Search
/*! @brief Actions to take when the edit button from search is touched
 */
- (IBAction)btnEdit:(id)sender {
    [self performSegueWithIdentifier:@"segueEditOilFromSearch" sender:self];
}

#pragma mark Can Edit Table Row
/*! @brief Set the ability to swipe left to edit or delete
 */
-(BOOL)tableView:(UITableView *) tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark Number of Sections in Row
/*! @brief  Display the number of sections in the row
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark Table Number of Rows in Section
/*! @brief Count of all the rows
 */
-(NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger)section
{
    return [myRelatedRemedies count];
}

#pragma mark Populate Table
/*! @brief populate the table with data from the array
 */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    OilLists   *displayCollection = [myRelatedRemedies objectAtIndex:indexPath.row];
    cell.textLabel.text = displayCollection.RemedyName;
    cell.tag = displayCollection.RID;
    [FormFunctions setBackGroundImage:cell.contentView];
    return cell;
}

#pragma mark Table Row Selected
/*! @brief actions to take when a row has been selected.
 */
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellTag = [NSString stringWithFormat:@"%ld",(long)cell.tag];
    SelectedCellID = cellTag;
    [self performSegueWithIdentifier:@"segueViewRemedyFromOils" sender:self];
}
@end
