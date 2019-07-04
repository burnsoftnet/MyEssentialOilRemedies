//
//  LIST_OilRemediesViewController.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//
//  StoryboardiD: RemedyListController

#import "LIST_OilRemediesViewController.h"

@interface LIST_OilRemediesViewController ()
{
    NSString *dbPathString;
    NSMutableArray *myOilCollection;
    NSString *SelectedCellID;
    NSMutableArray *remedySections; //related to issue #79
    int RemedyCount; //Added for Lite Version tracking
    int OilCount; //Added for Lite Version tracking
    int inStockCount;
    int ReOrderCount;
    NSMutableDictionary *remedyDictonary;
}
@end

@implementation LIST_OilRemediesViewController

#pragma mark Controller Load
/*! @brief Actions to take when the Controller Loads
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupGlobalVars];
    [[self myTableView]setDelegate:self];
    [[self myTableView]setDataSource:self];
    [self LoadTableData];
    [FormFunctions setBackGroundImage:self.view];
    [FormFunctions setBackGroundImage:self.myTableView];
    
    //Create and Add button in the Nav Bar
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addRemedy)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    //Set TableView to delete mode when you swipe left
    self.tableView.allowsSelectionDuringEditing = NO;
}
/*! @brief  When the Add button on the navigation is clicked
 */
-(void) addNavButton
{
    //Create an Add Button in Nav Bat
    if (ISLITE)
    {
        if (RemedyCount <= ((int)LITE_LIMIT -1))
        {
            UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addRemedy)];
            self.navigationItem.rightBarButtonItem = addButton;
        } else {
            self.navigationItem.rightBarButtonItem = nil;

            [FormFunctions AlertonLimitForViewController:self];
        }
    } else {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addRemedy)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
    
}
#pragma mark View Will Appear
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadCrap];
}

#pragma mark Did Recieve Memory Warning
/*! @brief  Dispose of any resources that can be recreated.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark View Did Disappear
/*! @brief Action to take when the view disappears, more of cleanup
 */
-(void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

#pragma mark Add Remedy
- (void) addRemedy {
    [self performSegueWithIdentifier:@"segueNewRemedy" sender:self];
}

#pragma mark Refresh Table View
/*! @brief Perform Refresh when table view is swapped down
 */
- (IBAction)refresh:(UIRefreshControl *)sender 
{
    [self.myTableView reloadData];
    [self LoadTableData];
    [sender endRefreshing];
    [self addNavButton];
}

#pragma mark General Sub and Functions
-(void) reloadCrap
{
    [self setupGlobalVars];
    [self LoadTableData];
    [self addNavButton];
}

#pragma mark Setup Global Variables
-(void)setupGlobalVars
{
    dbPathString = [BurnSoftDatabase getDatabasePath:@MYDBNAME];
    myOilCollection = [NSMutableArray new];
}

#pragma mark Load Table Data
-(void)LoadTableData
{
    [myOilCollection removeAllObjects];
    FormFunctions *myFunctions = [FormFunctions new];
    BurnSoftDatabase *myObjDB = [BurnSoftDatabase new];
    NSString *errorMsg = [NSString new];
    OilRemedies *myObj = [OilRemedies new];
    myOilCollection = [myObj getAllRemedies:dbPathString :&errorMsg];
    [myFunctions checkForError:errorMsg MyTitle:@"LoadData" ViewController:self];
    
    //related to issue #79
    if (USESECTIONS_REMEDIES)
    {
        remedySections = [NSMutableArray new];
        
        for (OilRemedies *j in myOilCollection)
        {
            NSString *newObject = j.section;
            if (![remedySections containsObject:newObject])
            {
                [remedySections addObject:newObject];
            }
        }
        [self setupDictionary];
    }
    
    [[self myTableView] reloadData];
    
    int InStockCount = [OilLists listInStock:dbPathString ErrorMessage:&errorMsg];

    OilCount = [myObjDB getTotalNumberofRowsInTable:@"eo_oil_list" DatabasePath:dbPathString ErrorMessage:nil];

    if (InStockCount == 0) {
        [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%d",OilCount]];
    } else {
        [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%i/%d",InStockCount,OilCount]];

    }
    
    RemedyCount = (int)[myOilCollection count];
    
    [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)[myOilCollection count]];
    
    myFunctions = nil;
    myObjDB = nil;
    myObj = nil;
    
}

-(void)setupDictionary
{
    @try {
        remedyDictonary = [NSMutableDictionary dictionary];
        [remedyDictonary removeAllObjects];
        
        for (int x = 0; x < [remedyDictonary count]; x++)
        {
            NSString *currentSectionName = [remedySections objectAtIndex:x];
            [remedyDictonary setObject:[self getAllRemediesFromArray:myOilCollection SectionLetter:currentSectionName ErrorMessage:nil] forKey:currentSectionName];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"ERROR: %@",exception);
    }
}

-(NSMutableArray *) getAllRemediesFromArray:(NSMutableArray *) mylist SectionLetter:(NSString *) section ErrorMessage:(NSString **) errMsg
{
    NSMutableArray *myArray = [NSMutableArray new];
    @try {
        for (OilRemedies *j in mylist)
        {
            NSString *newObject = j.section;
            if (newObject ==section)
            {
                OilRemedies *myRemedy = [OilRemedies new];
                [myRemedy setName:j.name];
                [myRemedy setOID:j.OID];
                [myRemedy setRID:j.RID];
                [myArray addObject:myRemedy];
            }
        }
    } @catch (NSException *exception){
        NSLog(@"ERROR: %@",exception);
    }
    return myArray;
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueViewRemedy"]) {
        VIEW_RemedyViewController *destViewController = (VIEW_RemedyViewController *)segue.destinationViewController;
        destViewController.RID = SelectedCellID;
    }
}
#pragma mark Can Edit Table Row
/*! @brief Set the ability to swipe left to edit or delete
 */
-(BOOL)tableView:(UITableView *) tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return YES;
}
#pragma mark Number of Sections in Row
/*! @brief  Display the number of sections in the row
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
#pragma mark Table Number of Rows in Section
/*! @brief Count of all the rows
 */
-(NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger)section
{
    return [myOilCollection count];
}
#pragma mark Populate Table
/*! @brief  populate the table with data from the array
 */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [FormFunctions setBackGroundImage:cell.contentView];
    OilRemedies *displayCollection = [myOilCollection objectAtIndex:indexPath.row];
    cell.textLabel.text = displayCollection.name;
    cell.tag = displayCollection.RID;
    return cell;
}

#pragma mark Table Did Select Row At index Path
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellTag = [NSString stringWithFormat:@"%ld",(long)cell.tag];
    SelectedCellID = cellTag;

    [self performSegueWithIdentifier:@"segueViewRemedy" sender:self];
}

#pragma mark Table Edit Action was selected
/*! @brief When the row is swiped to the left to give options to edit or delete, etc.
 */
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){EDIT_RemedyViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditRemedy_Description_ViewController"];
        
        OilRemedies *a = [self->myOilCollection objectAtIndex:indexPath.row];
        destViewController.RID = [NSString stringWithFormat:@"%d",a.RID];
        [self.navigationController pushViewController:destViewController animated:YES];
    }];
    editAction.backgroundColor = [UIColor blueColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        OilRemedies *a = [self->myOilCollection objectAtIndex:indexPath.row];
        OilRemedies *obj = [OilRemedies new];
        FormFunctions *objF = [FormFunctions new];
        NSString *Msg;
        if ([obj deleteRemedyByID:[NSString stringWithFormat:@"%d",a.RID] DatabasePath:self->dbPathString MessageHandler:&Msg])
        {
            [objF sendMessage:[NSString stringWithFormat:@"%@ was deleted!",a.name] MyTitle:@"Delete" ViewController:self];
            [self->myOilCollection removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [objF sendMessage:[NSString stringWithFormat:@"Error while deleting! %@",Msg] MyTitle:@"ERROR" ViewController:self];
        }
        [self reloadCrap];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return  @[deleteAction,editAction];
}

@end
