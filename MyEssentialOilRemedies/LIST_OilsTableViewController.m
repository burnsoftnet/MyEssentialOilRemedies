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
    NSMutableArray *oilSections; //Related to issue #63
    int inStockCount; // Mark if it is instock or not or the badge count
    int RemedyCount; //Added for Lite Version tracking
    int OilCount; //Added for Lite Version tracking
    int ReOrderCount;
    NSMutableDictionary *oilDictionary;
}
@end

@implementation LIST_OilsTableViewController

#pragma mark Controller Load
/*! @brief Actions to take when the Controller Loads
 */
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
    [FormFunctions setBackGroundImage:self.view];
    [FormFunctions setBackGroundImage: self.myTableView];
}

#pragma mark Add Navigation Button
/*! @brief  Add new navigation button called add to add more oils
 */
-(void) addNavButton
{
    //Create an Add Button in Nav Bat
    if (ISLITE)
    {
        if (OilCount <= ((int)LITE_LIMIT -1 ))
        {
            UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addMoreOils)];
            addButton.tintColor = UIColor.blackColor;
            self.navigationItem.rightBarButtonItem = addButton;
        } else {
            self.navigationItem.rightBarButtonItem = nil;
             [FormFunctions AlertonLimitForViewController:self];
        }
    } else {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addMoreOils)];
        addButton.tintColor = UIColor.blackColor;
        self.navigationItem.rightBarButtonItem = addButton;
    }
}

#pragma mark View will reappear
/*! @brief Sub when the form reloads
 */
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

#pragma mark View Did Disappear
/*! @brief Action to take when the view disappears, more of cleanup
 */
-(void) viewDidDisappear:(BOOL)animated
{
     [self closeObjects];
}

#pragma mark View Will Disappear
/*! @brief when the view will disappear
 */
-(void) viewWillDisappear:(BOOL)animated
{
    [self closeObjects];
}
#pragma mark Close all objects
/*!
    @brief  Close all objects that are being used globally on the form, this is ran when the view will and did dissapear functions.  This was being repeated and was moved to it's own function to simply 7 unify the closing process.
 */
-(void) closeObjects
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    myOilCollection = nil;
    inStockCount = 0;
    SelectedCellID = nil;
    dbPathString = nil;
    ReOrderCount = 0;
}
#pragma mark Did Recieve Memory Warning
/*! @brief  Dispose of any resources that can be recreated.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Refresh Table Data
/*! @brief  when you swipe down on the table, it will reload the data
 */
- (IBAction)refresh:(UIRefreshControl *)sender {
    [self.myTableView reloadData];
        [self loadData];
    [sender endRefreshing];
    [self addNavButton];
}

#pragma mark Reload Data
/*! @brief  Reload the data as is the for first appeared
 */
-(void) reloadData {
    [self setupGlobalVars];
    [self loadData];
     [self addNavButton];
}

#pragma mark Setup Global Variables
/*! @brief Setup the global variablies like the database path
 */
-(void) setupGlobalVars
{
    dbPathString = [BurnSoftDatabase getDatabasePath:@MYDBNAME];
    
    [FormFunctions doBuggermeMessage:dbPathString FromSubFunction:@"LIST_OilsTableViewController.setupGlobalVars.DatabasePath"];
    myOilCollection = [NSMutableArray new];
}

#pragma mark Load Data
/*! @brief  Load the data from the database into the local array
 */
- (void) loadData
{
    [myOilCollection removeAllObjects];
    
    BurnSoftDatabase *myObjDB = [BurnSoftDatabase new];
    OilLists *myObj  = [OilLists new];
    FormFunctions *myFunctions = [FormFunctions new];
    NSString *errorMsg = [NSString new];
    myOilCollection = [myObj getAllOilsList:dbPathString :&errorMsg];
    [myFunctions checkForError:errorMsg MyTitle:@"LoadData:" ViewController:self];

    if (USESECTIONS_OIL)
    {
        oilSections = [NSMutableArray new];
        
        for (OilLists *j in myOilCollection)
        {
            NSString *newObject = j.section;
            if (![oilSections containsObject:newObject])
            {
                [oilSections addObject:newObject];
            }
        }
        [self setupDictionary];
    }
    
    [[self myTableView] reloadData];

    inStockCount = [OilLists getInStockCountByArray:myOilCollection ErrorMessage:&errorMsg];
    
    if (inStockCount == 0) {
        [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)[myOilCollection count]];
    } else {
        [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%i/%lu",inStockCount,(unsigned long)[myOilCollection count]];
    }
    //Added for Lite Version tracking
    OilCount = (int)[myOilCollection count];
    RemedyCount = [myObjDB getTotalNumberofRowsInTable:@"eo_remedy_list" DatabasePath:dbPathString ErrorMessage:nil];
    
    [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%d",RemedyCount]];
    
    ReOrderCount = [OilLists listInShoppingByArray:myOilCollection ErrorMessage:&errorMsg];
    
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
#pragma mark Setup Dictionary
/*!
 @brief  Sets up the Dictionary to sort the database information into sections to be used in the table grouping display
 */
-(void)setupDictionary
{
    @try {
        oilDictionary = [NSMutableDictionary dictionary]; //related to issue #63

        [oilDictionary removeAllObjects];

        for (int x = 0; x < [oilSections count]; x++) {
            NSString *currentSectionName = [oilSections objectAtIndex:x];
            [oilDictionary setObject:[self getAllOilsFromArray:myOilCollection SectionLetter:currentSectionName ErrorMessage:nil] forKey:currentSectionName];
        }
    } @catch (NSException *exception) {
        NSLog(@"ERROR: %@",exception);
    }
}
#pragma mark Get All Oils From Array
/*!
 @brief  Combines the section letter into the oil list array
 @param Oil List from database that was loaded into a NSMutableArray
 @param Section Letters that we are targeting
 @param Error Message if any errors occur
 @return returns NSMutableArray of oil details from the database also the section that they are in
 */
-(NSMutableArray *) getAllOilsFromArray:(NSMutableArray *) mylist SectionLetter:(NSString *) section ErrorMessage:(NSString **) errMsg
{
    NSMutableArray *myArray = [NSMutableArray new];
    @try {
        for (OilLists *j in mylist)
        {
            NSString *newObject = j.section;
            if (newObject == section)
            {
                OilLists *myOils = [OilLists new];
                [myOils setName:j.name];
                [myOils setSection:j.section];
                [myOils setOID:j.OID];
                [myOils setRID:j.RID];
                [myOils setMydescription:j.mydescription];
                [myOils setIsBlend:j.isBlend];
                [myOils setInStock:j.InStock];
                
                [myArray addObject:myOils];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"ERROR: %@",exception);
    }
    return myArray;
}

#pragma mark Table set Edit Mode
/*! @brief  Set if you can edit the table by swiping left to view options.
 */
-(BOOL)tableView:(UITableView *) tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark Table Set Sections
/*! @brief set the sections in the table
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (USESECTIONS_OIL)
    {
        return [oilSections count];
    } else {
        return 1;
    }
}

//Related to issue #63
#pragma mark Table Section Header for Index
/*!
    @brief Table Section Header used for the Index on the table.
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (USESECTIONS_OIL)
    {
        return [oilSections objectAtIndex:section];
    } else {
        return nil;
    }
}


#pragma mark Table Set Number of Rows
/*! @brief set the number of rows int he table
 */
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (USESECTIONS_OIL)
    {
        NSString *sectionTitle = [oilSections objectAtIndex:section];
        NSArray *sectionLetter = [oilDictionary objectForKey:sectionTitle];
        return [sectionLetter count];
    } else {
        return [myOilCollection count];
    }
    
}

#pragma mark Table Set Cell Data
 /*! @brief set the cell data by use of an array
  */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16];

    if (USESECTIONS_OIL)
    {
        NSInteger indexSection = indexPath.section;
        NSInteger indexRow = indexPath.row;
        
        NSString *sectionTitle = [oilSections objectAtIndex:indexSection];
        NSArray *sectionOils = [oilDictionary objectForKey:sectionTitle];
        
        OilLists *displayCollection = [sectionOils objectAtIndex:indexRow];
        
        cell.textLabel.text = displayCollection.name;
        cell.detailTextLabel.text = displayCollection.mydescription;
        cell.tag = displayCollection.OID;
        //Adjusts the color of the header
        tableView.backgroundColor = [UIColor brownColor];

        //Adjust the color of the Index bar
        tableView.sectionIndexColor = [FormFunctions setTextColor];
        tableView.sectionIndexBackgroundColor = [FormFunctions setDefaultBackground];
        
        NSString *instock = displayCollection.InStock;
        if ([instock intValue] == 1)
        {
            cell.contentView.backgroundColor = [FormFunctions setHighlightColor];
        } else {
            [FormFunctions setBackGroundImage:cell.contentView];
        }
        NSString *isBlend = displayCollection.isBlend;
        
        if ([isBlend intValue] == 1)
        {
            cell.textLabel.font = [UIFont boldSystemFontOfSize:19.0];
        }
        
    } else {
        OilLists *displayCollection = [myOilCollection objectAtIndex:indexPath.row];
        cell.textLabel.text = displayCollection.name;
        cell.detailTextLabel.text = displayCollection.mydescription;
        cell.tag = displayCollection.OID;
        
        NSString *instock = displayCollection.InStock;
        if ([instock intValue] == 1)
        {
            cell.contentView.backgroundColor = [FormFunctions setHighlightColor];
        } else {
            [FormFunctions setBackGroundImage:cell.contentView];
        }
        NSString *isBlend = displayCollection.isBlend;
        
        if ([isBlend intValue] == 1)
        {
            cell.textLabel.font = [UIFont boldSystemFontOfSize:19.0];
        }
    }
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
    [self performSegueWithIdentifier:@"OilSelected" sender:self];
}

#pragma mark Table Edit actions
/*! @brief actions to take when a row has been selected for editing.
 */
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    FormFunctions *myFunctions = [FormFunctions new];
    OilLists *obj = [OilLists new];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellTag = [NSString stringWithFormat:@"%ld",(long)cell.tag];
    int OID = [cellTag intValue];
    NSString *OIDString = cellTag;
    NSString *OilName = [obj getOilNameByID:OID DatabasePath:dbPathString ErrorMessage:nil];
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){EDIT_OilDetailViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditOils"];

        destViewController.OID = OIDString;
        [self.navigationController pushViewController:destViewController animated:YES];
    }];
    editAction.backgroundColor = [UIColor blueColor];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){

        NSString *Msg;
        BurnSoftDatabase *myObj = [BurnSoftDatabase new];
        NSString *sql = [NSString stringWithFormat:@"Delete from eo_oil_list_details where OID=%d",OID];
        if ([myObj runQuery:sql DatabasePath:self->dbPathString MessageHandler:&Msg])
        {
            sql = [NSString stringWithFormat:@"DELETE from eo_oil_list where ID=%d",OID];
            if ([myObj runQuery:sql DatabasePath:self->dbPathString MessageHandler:&Msg])
            {
                [myFunctions sendMessage:[NSString stringWithFormat:@"%@ was deleted!",OilName] MyTitle:@"Delete" ViewController:self];
                [self->myOilCollection removeObjectAtIndex:indexPath.row];
                [self reloadData];
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
        BurnSoftDatabase *myObj = [BurnSoftDatabase new];
        NSString *sql = [NSString stringWithFormat:@"UPDATE eo_oil_list_details set reorder=1 where OID=%d",OID];
        if ([myObj runQuery:sql DatabasePath:self->dbPathString MessageHandler:&Msg])
        {
            [a updateStockStatus:@"0" OilID:[NSString stringWithFormat:@"%d",OID] DatabasePath:self->dbPathString ErrorMessage:&Msg];
            [myFunctions sendMessage:[NSString stringWithFormat:@"%@ was put in the shopping cart!",OilName] MyTitle:@"Order" ViewController:self];
        } else {
            [myFunctions sendMessage:[NSString stringWithFormat:@"Error while adding to shopping cart! %@",Msg] MyTitle:@"ERROR" ViewController:self];
        }

        [self reloadData];
    }];
    reOrderAction.backgroundColor = [UIColor darkGrayColor];
    return  @[deleteAction,editAction,reOrderAction];
}

#pragma mark Prepare for Segue
/*! @brief Actions to take before switching to the next window
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"OilSelected"]) {
        VIEW_OilDetailsViewController *destViewController = (VIEW_OilDetailsViewController *)segue.destinationViewController;
        destViewController.OID = SelectedCellID;
    }
}
#pragma mark Add More Oils
/*! @brief  Sub to add more Oils.
 */
-(void) addMoreOils {
    [self performSegueWithIdentifier:@"NewOil" sender:self];
}

#pragma mark Side Index Display for the Table
//Related to issue #63
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (USESECTIONS_OIL)
    {
        return oilSections;
    } else {
        return nil;
    }
    
}
//Related to issue #63
#pragma mark Side Index Display when Clicked
/*!
    @brief When the side bar is clicked on the letter
*/
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

@end
