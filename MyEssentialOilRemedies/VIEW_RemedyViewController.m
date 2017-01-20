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
}
#pragma mark Controller Sub and Functions
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
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}
-(void) viewWillDisappear:(BOOL)animated {
    // When Back button is hit on the view it will take you back to view the remidy list.
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        LIST_OilRemediesViewController * destinationVewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RemedyListController"];
        [self.navigationController pushViewController:destinationVewController animated:YES];
        [self dismissViewControllerAnimated:YES completion:Nil];
    }
    [super viewWillDisappear:animated];
}
#pragma mark
#pragma mark General Sub and Functions
-(void)reloadData
{
    [self loadSettings];
    [self loadData];
    [self loadForm];
}
-(void) loadSettings
{
    BurnSoftDatabase *objDB = [BurnSoftDatabase new];
    dbPathString = [objDB getDatabasePath:@MYDBNAME];
    
    FormFunctions *objf = [FormFunctions new];
    [objf setBorderLabel:self.lblProblem];
    [objf setBordersTextView:self.lblDescription];
}

-(void) loadForm
{
    self.lblProblem.text=self.myremedyName;
    self.lblDescription.text=self.myremedyDescription;
    self.lblUses.text=self.myUses;
    
}
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

-(void) clearFields
{
    self.lblProblem.text = @"";
    self.lblDescription.text = @"";
    self.lblUses.text=@"";
}
-(void)runToView:(NSString *)controllerName
{
    VIEW_RemedyViewController * destinationViewController = [self.storyboard instantiateViewControllerWithIdentifier:controllerName];
    NSString *myRN = self.lblProblem.text;
    NSString *myRD = self.lblDescription.text;
    NSString *myU = self.lblUses.text;
    
    if (myRN == nil )
    {
        myRN = _myremedyName;
    }
    if (myRD == nil )
    {
        myRD = _myremedyDescription;
    }
    if (myU == nil )
    {
        myU = _myUses;
    }
    [destinationViewController setMyremedyName:myRN];
    [destinationViewController setMyremedyDescription:myRD];
    [destinationViewController setMyUses:myU];
    [destinationViewController setRID:self.RID];
    [destinationViewController setIsFromSearch:self.isFromSearch];
    
    if (self.isFromSearch)
    {
        //[self dismissViewControllerAnimated:YES completion:^{
        //    [presentViewController dismissViewControllerAnimated:YES competion:nil];
        //}];
        //VIEW_RemedyViewController *currentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RemedyDetailsViewControllerFromSearch"];
        //[self presentViewController:destinationViewController animated:YES completion:nil];
        //[self dismissViewControllerAnimated:YES completion:^{[self presentViewController:destinationViewController animated:YES completion:nil];}];
        //[self presentViewController:destinationViewController animated:YES completion:^{[currentViewController dismissViewControllerAnimated:YES completion:nil];}];
        
        //[self dismissViewControllerAnimated:YES completion:nil];
    } else {
            
        [self.navigationController pushViewController:destinationViewController animated:YES];
    }
}
#pragma mark
#pragma mark Toolbar Functions
- (IBAction)tbSave:(id)sender {
    [self runToView:@"EditRemedy_Description_ViewController"];
}

- (IBAction)tbDescription:(id)sender {
    if (!_isFromSearch)
    {
        [self runToView:@"RemedyDetailsViewController"];
    } else {
        [self runToView:@"RemedyDetailsViewControllerFromSearch"];
    }
}

- (IBAction)tbClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)tbOils:(id)sender {
    if (!_isFromSearch)
    {
        [self runToView:@"View_RemedyOilsViewController"];
    } else {
        //[self runToView:@"View_RemedyOilsViewControllerFromSearch"];
        [self performSegueWithIdentifier:@"segueSearchRemedyOils" sender:self];
    }
}

- (IBAction)tbUses:(id)sender {
    if (!_isFromSearch)
    {
        [self runToView:@"View_RemedyUsesViewController"];
    } else {
        //[self runToView:@"View_RemedyUsesViewControllerFromSearch"];
        [self performSegueWithIdentifier:@"segueSearchUses" sender:self];
    }
}
#pragma mark
#pragma mark View popup WIndow for details
- (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    presentingController.providesPresentationContextTransitionStyle = YES;
    presentingController.definesPresentationContext = YES;
    [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueViewOilPopUp"]){
        PopUpOilViewController *popup = segue.destinationViewController;
        popup.myOilName = SelectedCellID;
        [self setPresentationStyleForSelfController:self presentingController:popup];
    } else {
        VIEW_RemedyViewController *mydestinationViewController = segue.destinationViewController;
        NSString *myRN = self.lblProblem.text;
        NSString *myRD = self.lblDescription.text;
        NSString *myU = self.lblUses.text;
        
        if (myRN == nil )
        {
            myRN = _myremedyName;
        }
        if (myRD == nil )
        {
            myRD = _myremedyDescription;
        }
        if (myU == nil )
        {
            myU = _myUses;
        }
        [mydestinationViewController setMyremedyName:myRN];
        [mydestinationViewController setMyremedyDescription:myRD];
        [mydestinationViewController setMyUses:myU];
        [mydestinationViewController setRID:self.RID];
        
        [mydestinationViewController setIsFromSearch:self.isFromSearch];
        if ([segue.identifier isEqualToString:@"segueSearchRemedyOils"]) {
            [self setPresentationStyleForSelfController:self presentingController:mydestinationViewController];
        } else if ([segue.identifier isEqualToString:@"segueSearchUses"]) {
            [self setPresentationStyleForSelfController:self presentingController:mydestinationViewController];
        } //else {
        //    NSLog(@"%@",segue.identifier);
       // }

    }
    /*VIEW_RemedyViewController *mydestinationViewController = segue.destinationViewController;
    NSString *myRN = self.lblProblem.text;
    NSString *myRD = self.lblDescription.text;
    NSString *myU = self.lblUses.text;
    
    if (myRN == nil )
    {
        myRN = _myremedyName;
    }
    if (myRD == nil )
    {
        myRD = _myremedyDescription;
    }
    if (myU == nil )
    {
        myU = _myUses;
    }
    [mydestinationViewController setMyremedyName:myRN];
    [mydestinationViewController setMyremedyDescription:myRD];
    [mydestinationViewController setMyUses:myU];
    [mydestinationViewController setRID:self.RID];
    
    [mydestinationViewController setIsFromSearch:self.isFromSearch];
    if ([segue.identifier isEqualToString:@"segueViewOilPopUp"]){
        PopUpOilViewController *popup = segue.destinationViewController;
        popup.myOilName = SelectedCellID;
        [self setPresentationStyleForSelfController:self presentingController:popup];
    } else if ([segue.identifier isEqualToString:@"segueSearchRemedyOils"]) {
        [self setPresentationStyleForSelfController:self presentingController:mydestinationViewController];
    } else if ([segue.identifier isEqualToString:@"segueSearchUses"]) {
        [self setPresentationStyleForSelfController:self presentingController:mydestinationViewController];
    } else {
        NSLog(@"%@",segue.identifier);
    }
     */
}
#pragma mark
#pragma mark Table Functions
-(BOOL)tableView:(UITableView *) tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return YES;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [myOilCollection count];
}
-(void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellTag = [NSString stringWithFormat:@"%@",cell.textLabel.text];
    SelectedCellID = cellTag;
    //Change behind the segue
    [self setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self performSegueWithIdentifier:@"segueViewOilPopUp" sender:self];
}
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
#pragma mark
@end
