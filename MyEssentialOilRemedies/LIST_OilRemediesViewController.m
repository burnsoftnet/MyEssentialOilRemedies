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
}
@end

@implementation LIST_OilRemediesViewController
#pragma mark For/View Sub and Functions
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGlobalVars];
    [[self myTableView]setDelegate:self];
    [[self myTableView]setDataSource:self];
    [self LoadTableData];
    
    //Create and Add button in the Nav Bar
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addRemedy)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    //Set TableView to delete mode when you swipe left
    self.tableView.allowsSelectionDuringEditing = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void) addRemedy {
    [self performSegueWithIdentifier:@"segueNewRemedy" sender:self];
}
- (IBAction)refresh:(UIRefreshControl *)sender 
{
    [self.myTableView reloadData];
    [self LoadTableData];
    [sender endRefreshing];
}
#pragma mark General Sub and Functions
-(void) reloadCrap
{
    [self setupGlobalVars];
    [self LoadTableData];
}
-(void)setupGlobalVars
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
    myOilCollection = [NSMutableArray new];
}
-(void)LoadTableData
{
    [myOilCollection removeAllObjects];
    FormFunctions *myFunctions = [FormFunctions new];
    NSString *errorMsg = [NSString new];
    OilRemedies *myObj = [OilRemedies new];
    myOilCollection = [myObj getAllRemedies:dbPathString :&errorMsg];
    [myFunctions checkForError:errorMsg MyTitle:@"LoadData" ViewController:self];
    [[self myTableView] reloadData];
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueViewRemedy"]) {
        VIEW_RemedyViewController *destViewController = (VIEW_RemedyViewController *)segue.destinationViewController;
        destViewController.RID = SelectedCellID;
    }
}
#pragma mark Table Functions
-(BOOL)tableView:(UITableView *) tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger)section
{
    return [myOilCollection count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    OilRemedies *displayCollection = [myOilCollection objectAtIndex:indexPath.row];
    cell.textLabel.text = displayCollection.name;
    cell.tag = displayCollection.RID;
    return cell;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellTag = [NSString stringWithFormat:@"%ld",(long)cell.tag];
    SelectedCellID = cellTag;

    [self performSegueWithIdentifier:@"segueViewRemedy" sender:self];
}
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){EDIT_RemedyViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditRemedy_Description_ViewController"];
        
        OilRemedies *a = [myOilCollection objectAtIndex:indexPath.row];
        destViewController.RID = [NSString stringWithFormat:@"%d",a.RID];
        [self.navigationController pushViewController:destViewController animated:YES];
    }];
    editAction.backgroundColor = [UIColor blueColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        OilRemedies *a = [myOilCollection objectAtIndex:indexPath.row];
        OilRemedies *obj = [OilRemedies new];
        FormFunctions *objF = [FormFunctions new];
        NSString *Msg;
        if ([obj deleteRemedyByID:[NSString stringWithFormat:@"%d",a.RID] DatabasePath:dbPathString MessageHandler:&Msg])
        {
            [objF sendMessage:[NSString stringWithFormat:@"%@ was deleted!",a.name] MyTitle:@"Delete" ViewController:self];
            [myOilCollection removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [objF sendMessage:[NSString stringWithFormat:@"Error while deleting! %@",Msg] MyTitle:@"ERROR" ViewController:self];
        }
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return  @[deleteAction,editAction];
}

#pragma mark
@end
