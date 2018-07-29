//
//  LIST_OilsTableViewController.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//
//  StoryboardiD: OilLists
// test delete me later

#import "LIST_OilsTableViewController.h"
#import "EDIT_OilDetailViewController.h"

@interface LIST_OilsTableViewController ()
{
    NSString *dbPathString;
    NSMutableArray *myOilCollection;
    NSString *SelectedCellID;
    int inStockCount; // Mark if it is instock or not or the badge count
    int RemedyCount; //Added for Lite Version tracking
    int OilCount; //Added for Lite Version tracking
    int ReOrderCount;
}
@end

@implementation LIST_OilsTableViewController

#pragma mark Controller Load
//Actions to take when the Controller Loads
- (void)viewDidLoad {
    inStockCount = 0;
    ReOrderCount = 0;
    [super viewDidLoad];
    
    [self setupGlobalVars];
    [[self myTableView]setDelegate:self];
    [[self myTableView]setDataSource:self];
    [self loadData];
    
    //Set Tableview to Delete Mode when you swipe left
    self.tableView.allowsSelectionDuringEditing = NO;
}
-(void) addNavButton
{
    //Create an Add Button in Nav Bat
    if (ISLITE)
    {
        if (OilCount <= ((int)LITE_LIMIT -1 ))
        {
            UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addMoreOils)];
            self.navigationItem.rightBarButtonItem = addButton;
        } else {
            self.navigationItem.rightBarButtonItem = nil;
             [FormFunctions AlertonLimitForViewController:self];
        }
    } else {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addMoreOils)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
}

#pragma mark View will reappear
//Sub when the form reloads
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

#pragma mark View Did Disappear
//Action to take when the view disappears, more of cleanup
-(void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    myOilCollection = nil;
    inStockCount = 0;
    SelectedCellID = nil;
    dbPathString = nil;
}
-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    myOilCollection = nil;
    inStockCount = 0;
    SelectedCellID = nil;
    dbPathString = nil;
}

#pragma mark Did Recieve Memory Warning
// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Refresh Table Data
// when you swipe down on the table, it will reload the data
- (IBAction)refresh:(UIRefreshControl *)sender {
    [self.myTableView reloadData];
        [self loadData];
    [sender endRefreshing];
    [self addNavButton];
}

#pragma mark Reload Data
//  Reload the data as is the for first appeared
-(void) reloadData {
    [self setupGlobalVars];
    [self loadData];
     [self addNavButton];
}

#pragma mark Setup Global Variables
// Setup the global variablies like the database path
-(void) setupGlobalVars
{
    BurnSoftDatabase *myPath = [BurnSoftDatabase new];
    dbPathString = [myPath getDatabasePath:@MYDBNAME];
    FormFunctions *myFunctions = [FormFunctions new];
    
    [myFunctions doBuggermeMessage:dbPathString FromSubFunction:@"LIST_OilsTableViewController.setupGlobalVars.DatabasePath"];
    myOilCollection = [NSMutableArray new];
    
    myPath = nil;
    myFunctions = nil;
}

#pragma mark Load Data
// Load the data from the database into the local array
- (void) loadData
{
    [myOilCollection removeAllObjects];
    BurnSoftDatabase *myObjDB = [BurnSoftDatabase new];
    OilLists *myObj  = [OilLists new];
    FormFunctions *myFunctions = [FormFunctions new];
    NSString *errorMsg = [NSString new];
    myOilCollection = [myObj getAllOilsList:dbPathString :&errorMsg];
    [myFunctions checkForError:errorMsg MyTitle:@"LoadData:" ViewController:self];
    [[self myTableView] reloadData];
    inStockCount = [myObj getInStockCountByDatabase:dbPathString ErrorMessage:&errorMsg];
    
    if (inStockCount == 0) {
        [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)[myOilCollection count]];
    } else {
        [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%i/%lu",inStockCount,(unsigned long)[myOilCollection count]];
    }
    //Added for Lite Version tracking
    OilCount = (int)[myOilCollection count];
    RemedyCount = [myObjDB getTotalNumberofRowsInTable:@"eo_remedy_list" DatabasePath:dbPathString ErrorMessage:nil];
    
    [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%d",RemedyCount]];
    
    ReOrderCount = [OilLists listInShopping:dbPathString ErrorMessage:&errorMsg];
    
    if (ReOrderCount > 0)
    {
        [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%d",ReOrderCount]];
    } else {
        [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
    }
    myObj = nil;
    myObjDB = nil;
    myFunctions = nil;
    
}


#pragma mark Table set Edit Mode
// Set if you can edit the table by swiping left to view options.
-(BOOL)tableView:(UITableView *) tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark Table Set Sections
//set the sections in the table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark Table Set Number of Rows
//set the number of rows int he table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [myOilCollection count];
}

#pragma mark Table Set Cell Data
//set the cell data by use of an array
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    OilLists *displayCollection = [myOilCollection objectAtIndex:indexPath.row];
    cell.textLabel.text = displayCollection.name;
    cell.detailTextLabel.text = displayCollection.mydescription;
    cell.tag = displayCollection.OID;
    NSString *instock = displayCollection.InStock;
    if ([instock intValue] == 1)
    {
        cell.contentView.backgroundColor = [UIColor greenColor];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    NSString *isBlend = displayCollection.isBlend;
    
    if ([isBlend intValue] == 1)
    {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
    }
    return cell;
}

#pragma mark Table Row Selected
//actions to take when a row has been selected.
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellTag = [NSString stringWithFormat:@"%ld",(long)cell.tag];
    SelectedCellID = cellTag;
    [self performSegueWithIdentifier:@"OilSelected" sender:self];
}

#pragma mark Table Edit actions
//actions to take when a row has been selected for editing.
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    FormFunctions *myFunctions = [FormFunctions new];
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){EDIT_OilDetailViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditOils"];
        OilLists *a = [self->myOilCollection objectAtIndex:indexPath.row];
        destViewController.OID = [NSString stringWithFormat:@"%d",a.OID];
        [self.navigationController pushViewController:destViewController animated:YES];
    }];
    editAction.backgroundColor = [UIColor blueColor];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your deleteAction here
        OilLists *a = [self->myOilCollection objectAtIndex:indexPath.row];
        NSString *Msg;
        int OID = a.OID;
        BurnSoftDatabase *myObj = [BurnSoftDatabase new];
        NSString *sql = [NSString stringWithFormat:@"Delete from eo_oil_list_details where OID=%d",OID];
        if ([myObj runQuery:sql DatabasePath:self->dbPathString MessageHandler:&Msg])
        {
            sql = [NSString stringWithFormat:@"DELETE from eo_oil_list where ID=%d",OID];
            if ([myObj runQuery:sql DatabasePath:self->dbPathString MessageHandler:&Msg])
            {
                [myFunctions sendMessage:[NSString stringWithFormat:@"%@ was deleted!",a.name] MyTitle:@"Delete" ViewController:self];
                [self->myOilCollection removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [myFunctions sendMessage:[NSString stringWithFormat:@"Error while deleting! %@",Msg] MyTitle:@"ERROR" ViewController:self];
            }
        } else {
            [myFunctions sendMessage:[NSString stringWithFormat:@"Error while deleting! %@",Msg] MyTitle:@"ERROR" ViewController:self];
        }
        [self reloadData];

    }];
    deleteAction.backgroundColor = [UIColor redColor];
    UITableViewRowAction *reOrderAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Add to Shopping Cart" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        OilLists *a = [self->myOilCollection objectAtIndex:indexPath.row];
        NSString *Msg;
        int OID = a.OID;
        BurnSoftDatabase *myObj = [BurnSoftDatabase new];
        NSString *sql = [NSString stringWithFormat:@"UPDATE eo_oil_list_details set reorder=1 where OID=%d",OID];
        if ([myObj runQuery:sql DatabasePath:self->dbPathString MessageHandler:&Msg])
        {
            [a updateStockStatus:@"0" OilID:[NSString stringWithFormat:@"%d",OID] DatabasePath:self->dbPathString ErrorMessage:&Msg];
            [myFunctions sendMessage:[NSString stringWithFormat:@"%@ was put in the shopping cart!",a.name] MyTitle:@"Order" ViewController:self];
        } else {
            [myFunctions sendMessage:[NSString stringWithFormat:@"Error while adding to shopping cart! %@",Msg] MyTitle:@"ERROR" ViewController:self];
        }
        [self reloadData];
    }];
    reOrderAction.backgroundColor = [UIColor darkGrayColor];
    return  @[deleteAction,editAction,reOrderAction];
}

#pragma mark Prepare for Segue
//Actions to take before switching to the next window
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"OilSelected"]) {
        VIEW_OilDetailsViewController *destViewController = (VIEW_OilDetailsViewController *)segue.destinationViewController;
        destViewController.OID = SelectedCellID;
    }
}
#pragma mark Add More Oils
// Sub to add more Oils.
-(void) addMoreOils {
    [self performSegueWithIdentifier:@"NewOil" sender:self];
}
@end
