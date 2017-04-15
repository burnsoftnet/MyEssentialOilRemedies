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
    int inStockCount;
}
@end

@implementation LIST_OilsTableViewController
#pragma mark Controller Load
//Actions to take when the Controller Loads
- (void)viewDidLoad {
    inStockCount = 0;
    [super viewDidLoad];
    [self setupGlobalVars];
    [[self myTableView]setDelegate:self];
    [[self myTableView]setDataSource:self];
    [self loadData];
    
    //Create an Add Button in Nav Bat
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addMoreOils)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    //Set Tableview to Delete Mode when you swipe left
    self.tableView.allowsSelectionDuringEditing = NO;
    
}
#pragma mark View will reappear
//Sub when the form reloads
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}
#pragma mark View did reappear
//Sub when the form reloads
- (void) viewDidAppear:(BOOL)animated
{
    
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
}
#pragma mark Reload Data
//  Reload the data as is the for first appeared
-(void) reloadData {
    [self setupGlobalVars];
    [self loadData];
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
    [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%i/%lu",inStockCount,(unsigned long)[myOilCollection count]];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%d",[myObjDB getTotalNumberofRowsInTable:@"eo_remedy_list" DatabasePath:dbPathString ErrorMessage:nil]]];
    
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
        OilLists *a = [myOilCollection objectAtIndex:indexPath.row];
        destViewController.OID = [NSString stringWithFormat:@"%d",a.OID];
        [self.navigationController pushViewController:destViewController animated:YES];
    }];
    editAction.backgroundColor = [UIColor blueColor];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your deleteAction here
        OilLists *a = [myOilCollection objectAtIndex:indexPath.row];
        NSString *Msg;
        BurnSoftDatabase *myObj = [BurnSoftDatabase new];
        NSString *sql = [NSString stringWithFormat:@"Delete from eo_oil_list_details where OID=%d",a.OID];
        if ([myObj runQuery:sql DatabasePath:dbPathString MessageHandler:&Msg])
        {
            sql = [NSString stringWithFormat:@"DELETE from eo_oil_list where ID=%d",a.OID];
            if ([myObj runQuery:sql DatabasePath:dbPathString MessageHandler:&Msg])
            {
                [myFunctions sendMessage:[NSString stringWithFormat:@"%@ was deleted!",a.name] MyTitle:@"Delete" ViewController:self];
                [myOilCollection removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [myFunctions sendMessage:[NSString stringWithFormat:@"Error while deleting! %@",Msg] MyTitle:@"ERROR" ViewController:self];
            }
        } else {
            [myFunctions sendMessage:[NSString stringWithFormat:@"Error while deleting! %@",Msg] MyTitle:@"ERROR" ViewController:self];
        }

    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return  @[deleteAction,editAction];
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
