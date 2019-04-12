//
//  VIEW_RemedyViewController.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/3/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "VIEW_RemedyViewController.h"

@implementation VIEW_RemedyViewController
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
    [self loadData];
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(startAction)];
    NSArray *NavArray = [NSArray new];
    NavArray = [[NSArray alloc] initWithObjects:actionButton, nil];
    self.navigationItem.rightBarButtonItems = NavArray;
    
    [FormFunctions setBackGroundImage:self.viewOils];
    [FormFunctions setBackGroundImage:self.viewUses];
    [FormFunctions setBackGroundImage:self.myTableView];
    [FormFunctions setBackGroundImage:self.viewDescription];
    
    if (currView == 0) {
        [self changeCurrentViewTo:1];
    }
}

#pragma mark Start Action Sheet
/*! @brief start the action sheet process and gather the data to send to the ActionClass
 */
-(void) startAction
{
    int a;
    NSString *value = [NSString new];
    NSString *oilList = [NSString new];
    oilList = @"\n";
    NSMutableArray *myOils = [NSMutableArray new];
    
    for (a=0;a<[myOilCollection count];a++)
    {
        value = [NSString stringWithFormat:@"%@\n",[[myOilCollection objectAtIndex:a] name]];
        oilList = [oilList stringByAppendingString:value];
        //Save the oil to an Array to be passed to the XML Function
        [myOils addObject:[[myOilCollection objectAtIndex:a] name]];
    }

    NSString *rawText = [ActionClass RemedyDetailsToStringByName:self.lblProblem.text Description:self.lblDescription.text OilsArray:oilList HowToUse:self.lblUses.text];

    NSString *XMLText = [BurnSoftGeneral FCStringXML:[Parser RemedyDetailsToXMLforInsertByName:self.lblProblem.text Description:self.lblDescription.text HowToUse:self.lblUses.text Oils:myOils]];
    
    NSString *outPutFile = [ActionClass writeRemedyDetailsToFileToSendByName:XMLText];

    NSArray *ActionObjects = @[[NSURL fileURLWithPath:outPutFile],rawText];
    
    [ActionClass sendToActionSheetViewController:self ActionSheetObjects:ActionObjects eMailSubject:[NSString stringWithFormat:@"Oil Remedy for: %@",self.lblProblem.text]];
    
    myOils = nil;
}

#pragma mark View Appears Again
/*! @brief when the view is reloaded
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
        [self dismissViewControllerAnimated:YES completion:Nil];
    }
    [super viewWillDisappear:animated];
}

#pragma mark Sub Reload Data
/*! @brief Reloads the Settings and Data
 */
-(void)reloadData
{
    [self loadSettings];
    [self loadData];
}

#pragma mark Load Settings
/*! @brief This will load the setting for the for as well as database and set the borders for the textboxes and text views.
 */
-(void) loadSettings
{
    dbPathString = [BurnSoftDatabase getDatabasePath:@MYDBNAME];
    
    FormFunctions *objf = [FormFunctions new];
    [objf setBorderLabel:self.lblProblem];
    [objf setBordersTextView:self.lblDescription];
    [objf setBordersTextView:self.lblUses];

    objf = nil;
}

#pragma mark Load Data
/*! @brief Loads the information from the Database based on the RID.
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
                    iCol = 1;
                    if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.lblProblem.text  = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,iCol)];}
                
                    iCol = 2;
                    if (sqlite3_column_type(statement,iCol) != SQLITE_NULL) {self.lblDescription.text = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,iCol)];}

                    iCol=3;
                    if (sqlite3_column_type(statement, iCol) != SQLITE_NULL) {self.lblUses.text = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, iCol)];}
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

#pragma mark Edit Button Tool Bar Button
/*! @brief Action to take when the Edit button on the tool bar has been selected
 */
- (IBAction)tbEdit:(id)sender {
    VIEW_RemedyViewController * destinationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditRemedy_Description_ViewController"];
    [destinationViewController setRID:self.RID];
    [self.navigationController pushViewController:destinationViewController animated:YES];
}

#pragma mark Description Button Tool Bar Button
/*! @brief Action to take when the description button on the tool bar has been selected
 */
- (IBAction)tbDescription:(id)sender {
    [self changeCurrentViewTo:1];
}

#pragma mark Close Button Tool Bar Button
/*! @brief Action to take when the Close button on the tool bar as been selected.
 */
- (IBAction)tbClose:(id)sender {
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:NO];
    [navController popViewControllerAnimated:YES];
}

#pragma mark Oil Button Tool Bar Button
/*! @brief Action to take when the oil button on the tool bar has been selected
 */
- (IBAction)tbOils:(id)sender {
    [self changeCurrentViewTo:2];
}

#pragma mark Tab Uses
/*! @brief Actions to take when the Tool Bar Uses button is clicked
 */
- (IBAction)tbUses:(id)sender {
    [self changeCurrentViewTo:3];
}

#pragma mark View popup WIndow for details
/*! @brief Prep Presentation Style for Oil Description View Popup
 */
- (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    presentingController.providesPresentationContextTransitionStyle = YES;
    presentingController.definesPresentationContext = YES;
    [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
}

#pragma mark Prepare for Segue
/*! @brief Actions to take before switching to the next window
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueViewOilPopUp"]){
        PopUpOilViewController *popup = segue.destinationViewController;
        popup.myOilName = SelectedCellID;
        [self setPresentationStyleForSelfController:self presentingController:popup];
    } else {
        VIEW_RemedyViewController *mydestinationViewController = segue.destinationViewController;
        [mydestinationViewController setRID:self.RID];

        if ([segue.identifier isEqualToString:@"segueSearchRemedyOils"]) {
            [self setPresentationStyleForSelfController:self presentingController:mydestinationViewController];
        } else if ([segue.identifier isEqualToString:@"segueSearchUses"]) {
            [self setPresentationStyleForSelfController:self presentingController:mydestinationViewController];
        }
    }
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
    [self performSegueWithIdentifier:@"segueViewOilPopUp" sender:self];
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
        [FormFunctions setBackGroundImage:cell.contentView];
    }
        
    return cell;
}
#pragma mark
@end
