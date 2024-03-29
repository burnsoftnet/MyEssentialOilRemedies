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
    NSMutableArray *myRemedyCollection;
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
    
    inStockCount = 0;
    ReOrderCount = 0;
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
#pragma mark Add Navigation Button
/*! @brief  When the Add button on the navigation is clicked
 */
-(void) addNavButton
{
    //Create an Add Button in Nav Bat
    if ([MYSettings IsLiteVersion])
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
    myRemedyCollection = [NSMutableArray new];
}

#pragma mark Load Table Data
-(void)LoadTableData
{
    [myRemedyCollection removeAllObjects];
    FormFunctions *myFunctions = [FormFunctions new];
    BurnSoftDatabase *myObjDB = [BurnSoftDatabase new];
    NSString *errorMsg = [NSString new];
    OilRemedies *myObj = [OilRemedies new];
    myRemedyCollection = [myObj getAllRemedies:dbPathString :&errorMsg];
    [myFunctions checkForError:errorMsg MyTitle:@"LoadData" ViewController:self];
    
    //related to issue #79
    if (USESECTIONS_REMEDIES)
    {
        remedySections = [NSMutableArray new];
        
        for (OilRemedies *j in myRemedyCollection)
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
    ReOrderCount = [OilLists listInShopping:dbPathString ErrorMessage:&errorMsg];
    if (ReOrderCount > 0){
        [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%d",ReOrderCount]];
    } else {
        [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
    }
    RemedyCount = (int)[myRemedyCollection count];
    
    [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)[myRemedyCollection count]];
    
    myFunctions = nil;
    myObjDB = nil;
    myObj = nil;
    
}
#pragma mark Setup Dictionary
/*!
 @brief  Setup the remedy dictionary for sections
 */
-(void)setupDictionary
{
    @try {
        remedyDictonary = [NSMutableDictionary dictionary];
        [remedyDictonary removeAllObjects];
        
        for (int x = 0; x < [remedySections count]; x++)
        {
            NSString *currentSectionName = [remedySections objectAtIndex:x];
            [remedyDictonary setObject:[self getAllRemediesFromArray:myRemedyCollection SectionLetter:currentSectionName ErrorMessage:nil] forKey:currentSectionName];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"ERROR: %@",exception);
    }
}

#pragma mark Get All Remedies From Array
/*!
 @brief  Combines the section letter into the remedies list array
 @param Remedy List from database that was loaded into a NSMutableArray
 @param Section Letters that we are targeting
 @param Error Message if any errors occur
 @return returns NSMutableArray of Remedy details from the database also the section that they are in
 */
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
    if (USESECTIONS_REMEDIES)
    {
        return [remedySections count];
    } else {
        return 1;
    }
}
#pragma mark Table Header
/*!
 @brief  Setup the table Header information
 */
-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (USESECTIONS_REMEDIES)
    {
        return [remedySections objectAtIndex:section];
    }else {
        return nil;
    }
}
#pragma mark Table Number of Rows in Section
/*! @brief Count of all the rows
 */
-(NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger)section
{
    if (USESECTIONS_REMEDIES)
    {
        NSString *sectionTitle = [remedySections objectAtIndex:section];
        NSArray *sectionLetter = [remedyDictonary objectForKey:sectionTitle];
        return [sectionLetter count];
    } else {
        return [myRemedyCollection count];
    }
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
    
    if (USESECTIONS_REMEDIES)
    {
        NSInteger indexSection = indexPath.section;
        NSInteger indexRow = indexPath.row;
        
        NSString *sectionTitle =[remedySections objectAtIndex:indexSection];
        NSArray *sectionRemedy = [remedyDictonary objectForKey:sectionTitle];
        
        OilRemedies *displayCollection = [sectionRemedy objectAtIndex:indexRow];
        cell.textLabel.text = displayCollection.name;
        cell.tag = displayCollection.RID;
        
        //tableView.backgroundColor = [UIColor brownColor];
        tableView.backgroundColor = [FormFunctions setDefaultBackgroundColor];
        
        //Adjust the color of the Index bar
        tableView.sectionIndexColor = [FormFunctions setTextColor];
        tableView.sectionIndexBackgroundColor = [FormFunctions setDefaultBackground];
        
    } else {
        OilRemedies *displayCollection = [myRemedyCollection objectAtIndex:indexPath.row];
        cell.textLabel.text = displayCollection.name;
        cell.tag = displayCollection.RID;
    }
    
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
    
    UIContextualAction *editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Edit" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        EDIT_RemedyViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditRemedy_Description_ViewController"];
        
        OilRemedies *a = [self->myRemedyCollection objectAtIndex:indexPath.row];
        destViewController.RID = [NSString stringWithFormat:@"%d",a.RID];
        [self.navigationController pushViewController:destViewController animated:YES];
    }];
    
    editAction.backgroundColor = [UIColor blueColor];
    
     UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
         OilRemedies *a = [self->myRemedyCollection objectAtIndex:indexPath.row];
         OilRemedies *obj = [OilRemedies new];
         FormFunctions *objF = [FormFunctions new];
         NSString *Msg;
         if ([obj deleteRemedyByID:[NSString stringWithFormat:@"%d",a.RID] DatabasePath:self->dbPathString MessageHandler:&Msg])
         {
             [objF sendMessage:[NSString stringWithFormat:@"%@ was deleted!",a.name] MyTitle:@"Delete" ViewController:self];
             [self->myRemedyCollection removeObjectAtIndex:indexPath.row];
             [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
         } else {
             [objF sendMessage:[NSString stringWithFormat:@"Error while deleting! %@",Msg] MyTitle:@"ERROR" ViewController:self];
         }
         [self reloadCrap];
     }];
     
     deleteAction.backgroundColor = [FormFunctions setDeleteColor];
     
     UISwipeActionsConfiguration *swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction, editAction]];
        swipeActions.performsFirstActionWithFullSwipe = NO;
        return swipeActions;
}

#pragma mark Side Index Display for the Table
/*!
 @brief Section index titles for Table View
 */
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (USESECTIONS_REMEDIES)
    {
        return remedySections;
    } else {
        return nil;
    }
}

#pragma mark Side Index Display when Clicked
/*!
 @brief When the side bar is clicked on the letter
 */
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

#pragma mark Table View For Header in Section
/*!
 @discussion This is the section that you will need to update for the Dark and light mode, or just use the cusomt coloring and keep it all the same
 @brief  This is the section that you want to change for the color and font size and or color of the index for the table view
 @return return UIView for the table header
 */
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, [FormFunctions setTableHeaderHeight])];
    [headerView setBackgroundColor:[FormFunctions setDefaultBackground]];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, [FormFunctions setHeaderTextHeight])];
    [label setFont:[FormFunctions setHeaderTextFontSize]];
    
    NSString *labelText = [NSString stringWithFormat:@"     %@",[remedySections objectAtIndex:section]];
    [label setText:labelText];
    [headerView addSubview:label];
    return headerView;
}
@end
