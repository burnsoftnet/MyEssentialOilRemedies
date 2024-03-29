//
//  EDIT_RemedyViewController.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/3/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "EDIT_RemedyViewController.h"

@implementation EDIT_RemedyViewController
{
    NSString *dbPathString;
    sqlite3 *MYDB;
    NSString *SelectedCellID;
    int currView;
}
#pragma mark Form Load
/*! @brief When the form is loading
 */
-(void) viewDidLoad
{
    [super viewDidLoad];
    [self loadSettings];
    [self loadData];
    [[self myTableView]setDelegate:self];
    [[self myTableView]setDataSource:self];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [FormFunctions setBackGroundImage:self.viewDescription];
    [FormFunctions setBackGroundImage:self.viewUses];
    [FormFunctions setBackGroundImage:self.viewOils];

    [FormFunctions setBackGroundImage:self.myTableView];
    
    if (currView == 0) {
        [self changeCurrentViewTo:1];
    }
    
    if (_isFromSearch) {
        double MyConstant = 20;
        if (self.topConstraint.constant == 0) {
            self.topConstraint.constant = MyConstant;
        } else {
            double myNewValue = (self.topConstraint.constant + MyConstant);
            if (self.topConstraint.constant < 0) {
                myNewValue = ( - self.topConstraint.constant);
                self.topConstraint.constant = (myNewValue + self.topConstraint.constant);
            }
        }
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

#pragma mark Button Add Oil
/*! @brief when the Add button is pressed
 */
-(IBAction)btnAddOil:(id)sender
{
    NSString *newOil = self.txtOilName.text;
    if (![newOil isEqualToString:@""])
    {
        [self.myOils addObject:self.txtOilName.text];
        [self.myTableView reloadData];
    }
    self.txtOilName.text=@"";
}

#pragma mark Did Recieve Memory Warning
/*! @brief  Dispose of any resources that can be recreated.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Form Exits
/*! @brief Clean up when the form is leaving
 */
-(void) viewWillDisappear:(BOOL)animated {
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:NO];
    [navController popViewControllerAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:Nil];
    [super viewWillDisappear:animated];
}

#pragma mark Clear and Exit
/*! @brief Clear out the values and exit
 */
-(void) ClearAndExit
{
    [self.myOils removeAllObjects];
    [self viewWillDisappear:NO];
}

#pragma mark Keyboard Disappear
/*! @brief Makes the Keyboard disappear when outside of the textbox is clicked
 */
-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.txtUses resignFirstResponder];
    [self.txtRemedy resignFirstResponder];
    [self.txtDescription resignFirstResponder];
    [self.txtOilName resignFirstResponder];
    
}

#pragma mark Load Data
/*! @brief load the data when the form starts or when nedded.
 */
-(void) loadData
{
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPathString UTF8String],&MYDB) == SQLITE_OK)
    {
        NSString *sql = [NSString stringWithFormat:@"select * from eo_remedy_list where ID=%@",self.RID];
        int iCol = 0;
        if (sqlite3_prepare_v2(MYDB,[sql UTF8String],-1,&statement,NULL) ==SQLITE_OK)
        {
            while (sqlite3_step(statement) ==SQLITE_ROW)
            {
                iCol = 1;
                if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.txtRemedy.text= [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,iCol)];}

                iCol=2;
                if (sqlite3_column_type(statement, iCol) != SQLITE_NULL) {self.txtDescription.text = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, iCol)];}

                iCol=3;
                if (sqlite3_column_type(statement, iCol) != SQLITE_NULL) {self.txtUses.text = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, iCol)];}
            }
            sqlite3_close(MYDB);
            sqlite3_finalize(statement);
            MYDB = nil;
        } else {
            [FormFunctions doBuggermeMessage:[NSString stringWithFormat:@"Error while creating select statement for LoadData. '%s'", sqlite3_errmsg(MYDB)] FromSubFunction:@"EDIT_RemedyViewController.loadData"];
        }
    }
    FormFunctions *myFunctions = [FormFunctions new];
    NSString *errorMsg = [NSString new];
    OilRemedies *myObj = [OilRemedies new];
    _myOils = [myObj getAllOilfForremedyByRIDNameOnly:self.RID DatabasePath:dbPathString ErrorMessage:&errorMsg];
    [myFunctions checkForError:errorMsg MyTitle:@"LoadData" ViewController:self];
    [[self myTableView] reloadData];
}

#pragma mark Reload Data
/*! @brief Reload everything as if the form was new but it isn't
 */
-(void) reloadData
{
    [self loadSettings];
    [self loadData];
}

#pragma mark Load Settings
/*! @brief  Load the database path and make the borders around the textboxes and text views
 */
-(void) loadSettings
{
    dbPathString = [BurnSoftDatabase getDatabasePath:@MYDBNAME];
    
    FormFunctions *objF = [FormFunctions new];
    [objF setBorderTextBox:self.txtRemedy];
    [objF setBordersTextView:self.txtUses];
    [objF setBorderTextBox:self.txtOilName];
    [objF setBordersTextView:self.txtDescription];

    objF = nil;
}

#pragma mark Change Views
/*! @brief This will change the views when a button on the toolbar is touched
    1 is Description View is selected
    2 is Oils View was selcted
    3 is the Uses View was selected
 */
-(void)changeCurrentViewTo:(int) iValue
{
    switch (iValue) {
        case 1:
            self.viewDescription.hidden = NO;
            self.viewOils.hidden = YES;
            self.viewUses.hidden = YES;
            break;
        case 2:
            self.viewDescription.hidden = YES;
            self.viewOils.hidden = NO;
            self.viewUses.hidden = YES;
            break;
        case 3:
            self.viewDescription.hidden = YES;
            self.viewOils.hidden = YES;
            self.viewUses.hidden = NO;
    }
}

#pragma mark Oils Arral
/*! @brief swap the oils array for next view
 */
-(NSMutableArray *) myOils
{
    if (_myOils == nil ) {
        _myOils = [[NSMutableArray alloc] init];
    }
    return _myOils;
}

#pragma mark Add Oils to Remedy
/*! @brief Add the oils lsted to the remedy link table
 */
- (void) addOilsToRemedy: (NSString *) RemedyID
{
    OilRemedies *objDB = [OilRemedies new];
    NSString *oilName = [NSString new];
    NSString *errorMsg;
    NSString *OID;
    
    for (id obj in self.myOils)
    {
        oilName = obj;
        OID = [objDB AddOilName:oilName DatabasePath:dbPathString ERRORMESSAGE:&errorMsg];
        [objDB addOilToremedyOilList:OID RID:RemedyID DatabasePath:dbPathString ERRORMESSAGE:&errorMsg];
    }
}

#pragma mark Uses ToolBar button
/*! @brief Button to switch to the uses view
 */
-(IBAction)tbUses:(id)sender
{
    [self changeCurrentViewTo:3];
}

#pragma mark Description ToolBar button
/*! @brief buttong to switch to the description view
 */
-(IBAction)tbDescription:(id)sender
{
     [self changeCurrentViewTo:1];
}

#pragma mark Oils ToolBar button
/*! @brief buttong to switch to the oils view
 */
-(IBAction)tbOils:(id)sender
{
    [self changeCurrentViewTo:2];
}

#pragma mark Update Button
/*! @brief Start the update process
 */
-(IBAction)tbUpdate:(id)sender
{
    FormFunctions *myObj = [FormFunctions new];
    NSString *errorMsg;
    NSString *myRN = self.txtRemedy.text;
    NSString *myRD = self.txtDescription.text;
    NSString *myU = self.txtUses.text;
    
    
    OilRemedies *objDB = [OilRemedies new];

    if ([objDB updateRemedyDetailsByRID:self.RID Name:myRN Description:myRD Uses:myU DatabasePath:dbPathString ERRORMESSAGE:&errorMsg])
    {
        if ([objDB ClearOilsPerRemedyByRID:self.RID DatabasePath:dbPathString MessageHandler:&errorMsg])
        {
            [self addOilsToRemedy:self.RID];
            [self ClearAndExit];
        } else {
            [myObj sendMessage:errorMsg MyTitle:@"Error Clearing Oils" ViewController:self];
        }
    } else {
        [myObj sendMessage:errorMsg MyTitle:@"Error Updating Remedy" ViewController:self];
    }
}

#pragma mark Close Button
/*! @brief action to take when the close button has been touched.
 */
- (IBAction)tbClose:(id)sender {
    [self ClearAndExit];
}

#pragma mark Table Edit Rows
/*! @brief function for table editing
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
    return  [_myOils count];
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
    [FormFunctions setBackGroundImage:cell.contentView];
    cell.textLabel.text = self.myOils [indexPath.row];
    return cell;
}

#pragma mark New Table Handlers on Swipe
/*!
 @discussion This is the new section that is used in iOS 13 or greater to get rid of the warnings.
 @brief  trailing swipe action configuration for table row
 @return return UISwipeActionsConfiguration
 */
-(id)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self getRowActions:tableView indexPath:indexPath];
}

#pragma mark Get Ro Actions
/*!
 @brief  Contains the action to perform when you swipe on the table
 @param indexPath of table
 @return return UISwipeActionConfiguration
 @remark This is the new section that is used in iOS 13 or greater to get rid of the warnings.
 */
-(id)getRowActions:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self.myOils removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    UISwipeActionsConfiguration *swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    swipeActions.performsFirstActionWithFullSwipe = NO;
    return swipeActions;
}

@end
