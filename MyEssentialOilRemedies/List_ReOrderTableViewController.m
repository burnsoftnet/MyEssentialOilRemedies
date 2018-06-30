//
//  List_ReOrderTableViewController.m
//  My Essential Oil Remedies
//
//  Created by burnsoft on 6/30/18.
//  Copyright © 2018 burnsoft. All rights reserved.
//

#import "List_ReOrderTableViewController.h"

@interface List_ReOrderTableViewController ()
{
    NSString *dbPathString;
    NSMutableArray *myReOrderLists;
    NSString *SelectedCellID;
    //int inStockCount;
    //int RemedyCount;
    //int OilCount;
    int ReOrderCount;
}
@end

@implementation List_ReOrderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //inStockCount = 0;
    ReOrderCount = 0;
    
    [self setupGlobalVars];
    [[self myTableView]setDelegate:self];
    [[self myTableView]setDataSource:self];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

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
-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
- (void) reloadData {
    [self setupGlobalVars];
    [self loadData];
}
- (IBAction) refresh:(UIRefreshControl *)sender{
    [self.myTableView reloadData];
    [self loadData];
    [sender endRefreshing];
}

- (void) loadData
{
    [myReOrderLists removeAllObjects];
    //BurnSoftDatabase *myObjDB = [BurnSoftDatabase new];
    OilLists *myObj = [OilLists new];
    FormFunctions *myFunctions = [FormFunctions new];
    NSString *errorMsg = [NSString new];
    
    myReOrderLists = [myObj getOilsForReOrder:dbPathString ErrorMessage:&errorMsg];
    [myFunctions checkForError:errorMsg MyTitle:@"LoadData:" ViewController:self];
    
    [[self myTableView] reloadData];
    //inStockCount = [myObj getInStockCountByDatabase:dbPathString ErrorMessage:&errorMsg];
    myObj = nil;
    //myObjDB = nil;
    myFunctions = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    //return 0;
    return [myReOrderLists count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    OilLists *displayCollection = [myReOrderLists objectAtIndex:indexPath.row];
    
    cell.textLabel.text = displayCollection.name;
    cell.detailTextLabel.text = displayCollection.mydescription;
    cell.tag = displayCollection.OID;
    
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
