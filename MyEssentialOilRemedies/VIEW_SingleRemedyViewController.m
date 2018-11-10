//
//  VIEW_SingleRemedyViewController.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 11/7/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "VIEW_SingleRemedyViewController.h"

@interface VIEW_SingleRemedyViewController ()

@end

@implementation VIEW_SingleRemedyViewController
{
    NSString *dbPathString;
    sqlite3 *MYDB;
    NSMutableArray *myOilCollection;
    NSString *SelectedCellID;
    int currView;
}

#pragma mark On Form Load
/*! @brief When form first loads
 */
-(void) viewDidLoad
{
    [super viewDidLoad];
    [[self myTableView]setDelegate:self];
    [[self myTableView]setDataSource:self];
    [self loadSettings];
    [self clearFields];
    [self loadData];
    [self loadForm];
    if (!_isFromSearch){
        self.tbClose.tintColor = [UIColor clearColor];
        self.tbClose.enabled = NO;
    } else {
        self.topConstraint.constant = 20;
    }
    
    if (currView == 0) {
        [self changeCurrentViewTo:1];
    }
}

#pragma mark View appears again
/*! @brief When the view appears again
 */
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

#pragma mark Form Exits
/*! @brief Clean up when the form is leaving
 */
-(void) viewWillDisappear:(BOOL)animated {
    // When Back button is hit on the view it will take you back to view the remidy list.
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        LIST_OilRemediesViewController * destinationVewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RemedyListController"];
        [self.navigationController pushViewController:destinationVewController animated:YES];
        [self dismissViewControllerAnimated:YES completion:Nil];
    }
    [super viewWillDisappear:animated];
}

#pragma mark Reload Data
/*! @brief Reloads the data as if it loaded for the first time, mor like a reset
 */
-(void)reloadData
{
    [self loadSettings];
    [self loadData];
    [self loadForm];
}

#pragma mark Load Settings
/*! @brief load the database path and set borders
 */
-(void) loadSettings
{
    BurnSoftDatabase *objDB = [BurnSoftDatabase new];
    dbPathString = [objDB getDatabasePath:@MYDBNAME];
    
    FormFunctions *objf = [FormFunctions new];
    [objf setBorderLabel:self.lblProblem];
    [objf setBordersTextView:self.lblDescription];
}

#pragma mark  Load Textboxes with Vars
/*! @brief Loads the text boxes in the form with the varables that were set in loaddata
 */
-(void) loadForm
{
    self.lblProblem.text=self.myremedyName;
    self.lblDescription.text=self.myremedyDescription;
    self.lblUses.text=self.myUses;
    
}

#pragma mark Load Data To Variables
/*! @brief Loads the data from the database based on the RID/RemedyID
 */
-(void) loadData
{
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPathString UTF8String],&MYDB) == SQLITE_OK)
    {
        NSString *sql = [NSString stringWithFormat:@"select * from eo_remedy_list where ID=%@",self.RID];
        int ret = sqlite3_prepare_v2(MYDB,[sql UTF8String],-1,&statement,NULL);
        int iCol = 0;
        if (ret == SQLITE_OK)
        {
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                if (_myremedyName == nil)
                {
                    iCol = 1;
                    if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {_myremedyName  = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,iCol)];}
                    
                }
                if (_myremedyDescription == nil)
                {
                    iCol = 2;
                    if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {_myremedyDescription = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,iCol)];}
                }
                if (_myUses == nil)
                {
                    iCol=3;
                    if (sqlite3_column_type(statement, iCol) != SQLITE_NULL) {_myUses = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, iCol)];}
                }
            }
            sqlite3_close(MYDB);
            sqlite3_finalize(statement);
            MYDB = nil;
        }
    }
    FormFunctions *myFunctions = [FormFunctions new];
    NSString *errorMsg = [NSString new];
    OilRemedies *myObj = [OilRemedies new];
    myOilCollection = [myObj getAllOilfForremedyByRID:self.RID DatabasePath:dbPathString ErrorMessage:&errorMsg];
    [myFunctions checkForError:errorMsg MyTitle:@"LoadData" ViewController:self];
    [[self myTableView] reloadData];
    
}

#pragma mark Clear All Fields
/*! @brief Clears the textboxes
 */
-(void) clearFields
{
    self.lblProblem.text = @"";
    self.lblDescription.text = @"";
    self.lblUses.text=@"";
}

#pragma mark Toolbar Save Button
/*! @brief  Save information and Exit
    @remark Might not be in use.
 */
- (IBAction)tbSave:(id)sender {
    //[self runToView:@"EditRemedy_Description_ViewController"];
}

#pragma mark Toolbar Description Button
/*! @brief Switch to the Descriptions view
 */
- (IBAction)tbDescription:(id)sender {
    [self changeCurrentViewTo:1];
}

#pragma mark Toolbar Close Button
/*! @brief Close the entire view
 */
- (IBAction)tbClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark Toolbar Oils Button
/*! @brief Switch to the Oils View
 */
- (IBAction)tbOils:(id)sender {
    [self changeCurrentViewTo:2];
}

#pragma mark Chage Views 
/*! @brief This will changethe views when a button on the toolbar is touched
 */
-(void)changeCurrentViewTo :(int) iValue
{
    switch (iValue) {
        case 1:
            self.ViewDescription.hidden = NO;
            self.ViewOils.hidden = YES;
            self.ViewUses.hidden = YES;
            break;
        case 2:
            self.ViewDescription.hidden = YES;
            self.ViewOils.hidden = NO;
            self.ViewUses.hidden = YES;
            break;
        case 3:
            self.ViewDescription.hidden = YES;
            self.ViewOils.hidden = YES;
            self.ViewUses.hidden = NO;
             break;
        default:
            self.ViewDescription.hidden = NO;
            self.ViewOils.hidden = YES;
            break;
    }
    currView = iValue;
}

#pragma mark Toolbar Uses Button
/*! @brief Switch to Use's View
 */
- (IBAction)tbUses:(id)sender {
    [self changeCurrentViewTo:3];
}

#pragma mark View popup WIndow for details
/*! @brief Setup to Presentation for the Pop View Controllers
 */
- (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    presentingController.providesPresentationContextTransitionStyle = YES;
    presentingController.definesPresentationContext = YES;
    [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
}

#pragma mark Prepare for Segue
/*! @brief Actions to Take before moving to next controller
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueViewOilPopUpSearch"]){
        PopUpOilSearchViewController *popup = segue.destinationViewController;
        popup.myOilName = SelectedCellID;
        [self setPresentationStyleForSelfController:self presentingController:popup];
    } else if ([segue.identifier isEqualToString:@"segueEditRemedyFromSearch"]){
        EDIT_RemedyViewController *editMe = segue.destinationViewController;
        editMe.RID=self.RID;
        [self setPresentationStyleForSelfController:self presentingController:editMe];
    }
}

#pragma mark Table Set Cell Data
/*! @brief set the cell data by use of an array
 */
-(BOOL)tableView:(UITableView *) tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark Table Set Sections
/*! @brief set the sections in the table
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark Table Set Number of Rows
/*! @brief set the number of rows int he table
 */
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [myOilCollection count];
}

#pragma mark Table Row Selected
/*! @brief actions to take when a row has been selected.
 */
-(void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellTag = [NSString stringWithFormat:@"%@",cell.textLabel.text];
    SelectedCellID = cellTag;
    //Change behind the segue
    [self setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self performSegueWithIdentifier:@"segueViewOilPopUpSearch" sender:self];
}
#pragma mark Table Set Cell Data
/*! @brief set the cell data by use of an array
 */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    OilRemedies *displayCollection = [myOilCollection objectAtIndex:indexPath.row];
    NSString *instock = displayCollection.oilInStock;
    cell.textLabel.text = displayCollection.name;
    if ([instock intValue] == 1)
    {
        cell.contentView.backgroundColor = [UIColor greenColor];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

@end
