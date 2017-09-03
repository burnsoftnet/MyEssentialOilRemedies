//
//  Add_RemedyViewController.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/3/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "Add_RemedyViewController.h"

@implementation Add_RemedyViewController
{
    NSString *dbPathString;
    sqlite3 *MYDB;
    int currView;
}

#pragma mark On Form Load
//When form first loads
-(void) viewDidLoad
{
    [super viewDidLoad];
    [self loadSettings];
    [[self myTableView]setDelegate:self];
    [[self myTableView]setDataSource:self];
    
    if (currView == 0) {
        [self changeCurrentViewTo:1];
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark View appears again
//When the view appears again
-(void) viewDidAppear:(BOOL)animated
{
    [self loadSettings];
}

#pragma mark Remedy Name Texbox Lost Focus
// occurs after the usee finished editing the field and touches elsewhere on the form
- (IBAction)RemedyNameLostFocus:(id)sender {
    FormFunctions *myObj = [FormFunctions new];
    OilRemedies *myOilRemedies = [OilRemedies new];
    
    NSString *errMsg = [NSString new];
    NSString *myRemedyName = self.RemedyName.text;
    
    if ([myOilRemedies RemedyExistsByName:myRemedyName DatabasePath:dbPathString ErrorMessage:&errMsg])
    {
        [myObj sendMessage:[NSString stringWithFormat:@"An remedy already exists with the name %@",myRemedyName] MyTitle:@"Remedy Exists!" ViewController:self];
    }
    myObj = nil;
    myOilRemedies = nil;
}

#pragma mark Form Exits
//Clean up when the form is leaving
// When Back button is hit on the view it will take you back to view the remidy list.
-(void) viewWillDisappear:(BOOL)animated {
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:NO];
    [navController popViewControllerAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:Nil];
    [super viewWillDisappear:animated];
}

#pragma mark Add Oil Button
//Action to take when the Add oil Button has been selected
- (IBAction)btnAddOil:(id)sender {
    NSString *newOil = self.txtOilName.text;
    
    if (ISLITE)
    {
        BurnSoftDatabase *myObjDB = [BurnSoftDatabase new];
        int OilCount = [myObjDB getTotalNumberofRowsInTable:@"eo_oil_list" DatabasePath:dbPathString ErrorMessage:nil];
        
        //Add for Lite Version restriction
        if (OilCount <= (LITE_LIMIT - 1))
        {
            if (![newOil isEqualToString:@""])
            {
                [self.myOils addObject:self.txtOilName.text];
                [self.myTableView reloadData];
            }
            self.txtOilName.text=@"";
        } else {
            [FormFunctions sendMessage:@"Reached Max Limit on Lite Version!\n If you want to add more, please purchase the full version." MyTitle:@"Reached Lite Limit" ViewController:self];
        }
    } else {
        //Original Code before lite version
        if (![newOil isEqualToString:@""])
        {
            [self.myOils addObject:self.txtOilName.text];
            [self.myTableView reloadData];
        }
        self.txtOilName.text=@"";
    }
}

#pragma mark Load Settings
//This will load the setting for the for as well as database and set the borders for the textboxes and text views.
-(void) loadSettings
{
    FormFunctions *mysettings = [FormFunctions new];
    [mysettings setBorderTextBox:self.RemedyName];
    [mysettings setBordersTextView:self.RemedyDescription];
    [mysettings setBorderTextBox:self.txtOilName];
    [mysettings setBordersTextView:self.txtUses];
    [self.myTableView reloadData];
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
    
    mysettings = nil;
    myObj = nil;
}

#pragma mark Change Views
//This will change the views when a button on the toolbar is touched
// 1 is Description View is selected
// 2 is Oils View was selcted
// 3 is the Uses View was selected
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

#pragma mark Dissmiss Keyboard
//Dissmiss the keyboard when the view is selected
-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.txtUses resignFirstResponder];
    [self.RemedyName resignFirstResponder];
    [self.RemedyDescription resignFirstResponder];
    [self.txtOilName resignFirstResponder];
    
}

#pragma mark Oils Array Handler
//if this is the first time loading that database into the array, then initialize the array
-(NSMutableArray *) myOils
{
    if (_myOils == nil ) {
        _myOils = [[NSMutableArray alloc] init];
    }
    return _myOils;
}

#pragma mark Tab Uses
//Actions to take when the Tool Bar Uses button is clicked
- (IBAction)tbUses:(id)sender {
    //[self runToView:@"AddRemedy_Uses_ViewController"];
    [self changeCurrentViewTo:3];
}

#pragma mark Add Oils to Remedy
// Sub to add the oils in the table to the database
- (void) addOilsToRemedy: (NSString *) RemedyID
{
    OilRemedies *objDB = [OilRemedies new];
    FormFunctions *objFF = [FormFunctions new];
    NSString *oilName = [NSString new];
    NSString *errorMsg;
    NSString *OID;
    for (id obj in self.myOils)
    {
        oilName = obj;
        OID = [objDB AddOilName:oilName DatabasePath:dbPathString ERRORMESSAGE:&errorMsg];
        [objFF doBuggermeMessage:[NSString stringWithFormat:@"Add New OID=%@",OID] FromSubFunction:@"Add_RemedyViewController.addOilstoRemedy"];
        
        [objDB addOilToremedyOilList:OID RID:RemedyID DatabasePath:dbPathString ERRORMESSAGE:&errorMsg];
        [objFF doBuggermeMessage:errorMsg FromSubFunction:@"Add_RemedyViewController.addOilstoRemedy"];
    }
    
    objDB = nil;
    objFF = nil;
    
}

#pragma mark Clear and Exit
//Use this to close out the view and go back to the Main view.
-(void) ClearAndExit
{
    [self.myOils removeAllObjects];
    [self viewWillDisappear:NO];
}

#pragma mark Save ToolBar Button
//Action to take when the Save button on the tool bar has been sleected
- (IBAction)tbSave:(id)sender {
    NSString *RID;
    NSString *errorMsg;
    NSString *myRN = self.RemedyName.text;
    NSString *myRD = self.RemedyDescription.text;
    NSString *myU = self.txtUses.text;
    BOOL MissingRemedyName = [myRN isEqualToString:@""];
    BOOL MissingRemedyDescription = (BOOL)[myRD isEqualToString:@""];
    
    
    
    if (!MissingRemedyName && !MissingRemedyDescription) {
        BurnSoftGeneral *myObj = [BurnSoftGeneral new];
        OilRemedies *objDB = [OilRemedies new];
        RID = [objDB AddRemedyDetailsByName:[myObj FCString:myRN] Description:myRD Uses:myU DatabasePath:dbPathString ERRORMESSAGE:&errorMsg];
        [self addOilsToRemedy:RID];
        [self ClearAndExit];
        myObj = nil;
    } else {
        if (MissingRemedyDescription && !MissingRemedyName) {
            [FormFunctions sendMessage:@"Please put in a Problem description!" MyTitle:@"Missing Value" ViewController:self];
        } else if (MissingRemedyName && !MissingRemedyDescription) {
            [FormFunctions sendMessage:@"Please Put in a Problem Name!" MyTitle:@"Missing Value" ViewController:self];
        } else if (MissingRemedyDescription && MissingRemedyName) {
            [FormFunctions sendMessage:@"Please Put in a Problem Name & Description!" MyTitle:@"Missing Value" ViewController:self];
        }
        
        //FormFunctions *myAlert = [FormFunctions new];
        
        //[myAlert sendMessage:@"Please put in a Problem description!" MyTitle:@"Add Error" ViewController:self];
    }
    
}

#pragma mark Oil Button Tool Bar Button
//Action to take when the oil button on the tool bar has been selected
- (IBAction)tbOils:(id)sender {
    [self changeCurrentViewTo:2];
}

#pragma mark Description Button Tool Bar Button
//Action to take when the description button on the tool bar has been selected
- (IBAction)tbDescription:(id)sender {
    [self changeCurrentViewTo:1];
}

#pragma mark TableView EditRowAt Index
//Set to enable or diable the ablity to be able to edit the ros on the table
-(BOOL)tableView:(UITableView *) tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark TableView Number of Section
//Set the number of sections allowed in the table view
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark TableView Number of Rows
//set the number of rows that are in the able
-(NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.myOils count];
}

#pragma mark TableView Populate Table with Database or Array
//This is where the table gets populated with the data from an array or direct from the database.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = self.myOils [indexPath.row];
    return cell;
}
@end
