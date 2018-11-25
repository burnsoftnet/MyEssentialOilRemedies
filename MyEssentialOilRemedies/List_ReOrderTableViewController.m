//
//  List_ReOrderTableViewController.m
//  My Essential Oil Remedies
//
//  Created by burnsoft on 6/30/18.
//  Copyright © 2018 burnsoft. All rights reserved.
//

#import "List_ReOrderTableViewController.h"
#import "VIEW_OilDetailsViewController.h"

@interface List_ReOrderTableViewController ()
{
    NSString *dbPathString;
    NSMutableArray *myReOrderLists;
    NSString *SelectedCellID;
    int ReOrderCount;
}
@end

@implementation List_ReOrderTableViewController

#pragma mark View did Load
/*! @brief When form first loads
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    ReOrderCount = 0;
    
    [self setupGlobalVars];
    [[self myTableView]setDelegate:self];
    [[self myTableView]setDataSource:self];
    [self loadData];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.myTableView addSubview:refreshControl];
    [FormFunctions setBackGroundImage:self.view];
    [FormFunctions setBackGroundImage:self.myTableView];
}

#pragma mark View will reappear
/*! @brief Sub when the form reloads
 */
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void) refreshData
{
    [self.myTableView reloadData];
    [self loadData];
}

#pragma mark Setup Global Variables
/*! @brief  Setup global variables for the List Reorder forms
 */
-(void) setupGlobalVars
{
    BurnSoftDatabase *myPath = [BurnSoftDatabase new];
    dbPathString = [myPath getDatabasePath:@MYDBNAME];
    FormFunctions *myFunctions = [FormFunctions new];
    
    [myFunctions doBuggermeMessage:dbPathString FromSubFunction:@"List_RePrderTableViewController.setupGlobalVars.DatabasePath"];
    myReOrderLists = [NSMutableArray new];
    
    myPath = nil;
    myFunctions = nil;
    
}

#pragma mark Memory Warnings
/*! @brief When a memroy warning occurs
 */
-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
#pragma mark Reload Data
/*! @brief Reload the data as is the form was first visited
 */
- (void) reloadData {
    [self setupGlobalVars];
    [self loadData];
}
#pragma mark Refresh
/*! @brief  refresh the data on the form when swapped down
 */
- (IBAction) refresh:(UIRefreshControl *)sender{
    [self.myTableView reloadData];
    [self loadData];
    [sender endRefreshing];
}

#pragma mark Load Data
/*! @brief  Load the data when the form first loads or when the data is reloaded
 */
- (void) loadData
{
    [myReOrderLists removeAllObjects];

    OilLists *myObj = [OilLists new];
    FormFunctions *myFunctions = [FormFunctions new];
    NSString *errorMsg = [NSString new];
    
    myReOrderLists = [myObj getOilsForReOrder:dbPathString ErrorMessage:&errorMsg];
    [myFunctions checkForError:errorMsg MyTitle:@"LoadData:" ViewController:self];
    
    [[self myTableView] reloadData];

    ReOrderCount = [OilLists listInShopping:dbPathString ErrorMessage:&errorMsg];
    if (ReOrderCount > 0){
        [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%d",ReOrderCount]];
    } else {
        [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
    }
    myObj = nil;
    myFunctions = nil;
}

#pragma mark - Table view data source
/*! @brief  Number of Section in the Table View
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
#pragma mark - Table view Number of Rows
/*! @brief Number of rows in section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [myReOrderLists count];
}

#pragma mark Table View Cell At Path
/*! @brief For each cell in table view
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [FormFunctions setBackGroundImage:cell.contentView];
    
    OilLists *displayCollection = [myReOrderLists objectAtIndex:indexPath.row];
    
    cell.textLabel.text = displayCollection.name;
    cell.detailTextLabel.text = displayCollection.mydescription;
    cell.tag = displayCollection.OID;
    
    return cell;
}

#pragma mark Table View Can Edit Row
/*! @brief  Override to support conditional editing of the table view.
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

#pragma mark Table Edit actions
/*! @brief actions to take when a row has been selected for editing.
 */
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewRowAction *OrderAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Oil is Now In Stock." handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        FormFunctions *myFunctions = [FormFunctions new];
        OilLists *a = [self->myReOrderLists objectAtIndex:indexPath.row];
        NSString *Msg;
        BurnSoftDatabase *myObj = [BurnSoftDatabase new];
        int OID = a.OID;
        NSString *sql = [NSString stringWithFormat:@"UPDATE eo_oil_list_details set reorder=0 where OID=%d",OID];
        if ([myObj runQuery:sql DatabasePath:self->dbPathString MessageHandler:&Msg])
        {
            sql = [NSString stringWithFormat:@"UPDATE eo_oil_list_details set reorder=0 where OID=%d",OID];
            if ([myObj runQuery:sql DatabasePath:self->dbPathString MessageHandler:&Msg])
            {
                [a updateStockStatus:@"1" OilID:[NSString stringWithFormat:@"%d",OID] DatabasePath:self->dbPathString ErrorMessage:&Msg];
                
                [myFunctions sendMessage:[NSString stringWithFormat:@"%@ was removed from shopping cart and marked as In Stock!",a.name] MyTitle:@"Order" ViewController:self];
            }
        } else {
            [myFunctions sendMessage:[NSString stringWithFormat:@"Error while removing from shopping cart! %@",Msg] MyTitle:@"ERROR" ViewController:self];
        }
        [self reloadData];
    }];
    OrderAction.backgroundColor = [UIColor darkGrayColor];

    UITableViewRowAction *DeleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Remove from Cart" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        FormFunctions *myFunctions = [FormFunctions new];
        OilLists *a = [self->myReOrderLists objectAtIndex:indexPath.row];
        NSString *Msg;
        BurnSoftDatabase *myObj = [BurnSoftDatabase new];
        int OID = a.OID;
        NSString *sql = [NSString stringWithFormat:@"UPDATE eo_oil_list_details set reorder=0 where OID=%d",OID];
        if ([myObj runQuery:sql DatabasePath:self->dbPathString MessageHandler:&Msg])
        {
            [myFunctions sendMessage:[NSString stringWithFormat:@"%@ was removed from shopping cart!",a.name] MyTitle:@"Order" ViewController:self];
        } else {
            [myFunctions sendMessage:[NSString stringWithFormat:@"Error while removing from shopping cart! %@",Msg] MyTitle:@"ERROR" ViewController:self];
        }
        [self reloadData];
    }];
    DeleteAction.backgroundColor = [UIColor redColor];
    return  @[DeleteAction,OrderAction];
}

#pragma mark Table Row Selected
/*! @brief actions to take when a row has been selected.
 */
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellTag = [NSString stringWithFormat:@"%ld",(long)cell.tag];
    SelectedCellID = cellTag;
    [self performSegueWithIdentifier:@"segueShoppingViewOil" sender:self];
}


#pragma mark - Navigation
/*! @brief  In a storyboard-based application, you will often want to do a little preparation before navigation
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueShoppingViewOil"]) {
        VIEW_OilDetailsViewController *destViewController = (VIEW_OilDetailsViewController *)segue.destinationViewController;
        destViewController.OID = SelectedCellID;
    }
}

@end
