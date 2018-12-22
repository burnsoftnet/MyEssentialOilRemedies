//
//  SettingsiTunesBackupRestoreViewController.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 1/31/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import "SettingsiTunesBackupRestoreViewController.h"

@interface SettingsiTunesBackupRestoreViewController ()

@end

@implementation SettingsiTunesBackupRestoreViewController
{
    NSString *dbPathString;
    sqlite3 *OilDB;
    NSArray *filePathsArray;
}

#pragma mark On Form Load
/*! @brief When form first loads
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self LoadSettings];
    [self loadFileListings];
    
    //Read backup files
    [[self myTableView]setDelegate:self];
    [[self myTableView]setDataSource:self];
    
    [FormFunctions setBackGroundImage:self.view];
    [FormFunctions setBackGroundImage:self.mainView];
    [FormFunctions setBackGroundImage:self.myTableView];
}

#pragma mark Reload Data
/*! @brief Reload the Data when executed from another function
 */
-(void) reloadData
{
    [self LoadSettings];
    [self loadFileListings];
    [self.myTableView reloadData];
}

#pragma mark Load File Data
/*! @brief Load the contents of the docs directory
 */
-(void) loadFileListings
{
    filePathsArray = [NSArray new];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    filePathsArray = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.bak'"]];
}

#pragma mark Load Settings
/*! @brief Load the Database Path
 */
-(void) LoadSettings;
{
    //BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    //dbPathString = [myObj getDatabasePath:@MYDBNAME];
    dbPathString = [BurnSoftDatabase getDatabasePath:@MYDBNAME];
}

#pragma mark Backup Database for iTunes
/*! @briefThis will make a copy of the database for iTunes to to retrived or in case you need to restore.
    This will make a backup file meo_datetime.bak
 */
- (IBAction)btnBackUpDatabaseForiTunes:(id)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    FormFunctions *myObjFF = [FormFunctions new];
    
    NSDateFormatter *dateFormatter=[NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH_mm_ss"];
    
    NSString *newDBName = [NSString new];
    newDBName = [NSString stringWithFormat:@"meo_backup_%@.bak",[dateFormatter stringFromDate:[NSDate date]]];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    newDBName = [docPath stringByAppendingPathComponent:newDBName];
    
    [myObjFF doBuggermeMessage:[NSString stringWithFormat:@"DatabasePath: %@",dbPathString] FromSubFunction:@"SettingsiTunesBackupRestoreViewController.btnBackUpDatabaseForiTunes"];
    [myObjFF doBuggermeMessage:[NSString stringWithFormat:@"New Database Name: %@",newDBName] FromSubFunction:@"SettingsiTunesBackupRestoreViewController.btnBackUpDatabaseForiTunes"];
    
    NSError *error;
    BOOL success;
    NSString *msg;
    
    success = [fileManager copyItemAtPath:dbPathString toPath:newDBName error:&error];
    if (!success)
    {
        msg = [NSString stringWithFormat:@"Error backuping database: %@",[error localizedDescription]];
        [myObjFF sendMessage:msg MyTitle:@"Backup Error" ViewController:self];
    } else {
        msg = [NSString stringWithFormat:@"Backup Successful!"];
        [myObjFF sendMessage:msg MyTitle:@"Success!" ViewController:self];
    }
    [self reloadData];
}

#pragma mark Delete File by Name
/*! @brief Delete the a file in the local documents for the app.
 */
-(BOOL)DeleteFileByName:(NSString *) sFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *deleteFile = [docPath stringByAppendingString:[NSString stringWithFormat:@"/%@",sFile]];
    
    NSError *error;
    BOOL success;
    NSString *msg;
    
    success = [fileManager removeItemAtPath:deleteFile error:&error];
    if (!success)
    {
        msg = [NSString stringWithFormat:@"Error deleting database: %@",[error localizedDescription]];
    }else {
        msg = [NSString stringWithFormat:@"Delete Successful!"];
    }
    return success;
}

#pragma mark Restore Database for iTunes by File Name
/*! @brief Restore selected database and rename it to the main database name.
 */
-(void)RestoreDatabaseforiTunesbyFileName:(NSString *) sFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    FormFunctions * myObjFF = [FormFunctions new];
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *restoreFile = [docPath stringByAppendingString:[NSString stringWithFormat:@"/%@",sFile]];
    
    NSError *error;
    BOOL success;
    NSString *msg = [NSString new];
    
    success = [fileManager copyItemAtPath:restoreFile toPath:dbPathString error:&error];
    if (!success)
    {
        msg = [NSString stringWithFormat:@"Error restoring database: %@",[error localizedDescription]];
        [myObjFF sendMessage:msg MyTitle:@"Restore Error" ViewController:self];
    }else {
        msg = [NSString stringWithFormat:@"Restore Successful!"];
        [myObjFF sendMessage:msg MyTitle:@"Success!" ViewController:self];
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
/*! @brief Display the number of sections in the row
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
    return [filePathsArray count];
}

#pragma mark Populate Table
/*! @brief populate the table with data from the array
 */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [filePathsArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark Table Row Selected
/*! @brief actions to take when a row has been selected.
 */
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    //Currently does nothing, but is required by the UITableView
}

#pragma mark Table Edit actions
/*! @brief actions to take when a row has been selected for editing.
 */
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellTag = [NSString stringWithFormat:@"%@",cell.textLabel.text];
    FormFunctions * myObjFF = [FormFunctions new];
    
    UITableViewRowAction *RestoreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Restore" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //if ([self DeleteFileByName:@MYDBNAME])
        if ([BurnSoftDatabase resetDBDirectory])
        {
            [self RestoreDatabaseforiTunesbyFileName:cellTag];
        } else {
            [myObjFF sendMessage:@"Unable to delete Main Database before copy" MyTitle:@"Restore Error" ViewController:self];
        }
        [self reloadData];
    }];
    RestoreAction.backgroundColor = [UIColor blueColor];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        if ([self DeleteFileByName:cellTag])
        {
            [myObjFF sendMessage:[NSString stringWithFormat:@"%@ backup file was deleted!",cellTag] MyTitle:@"Backup Deleted" ViewController:self];
            [self.myTableView reloadData];
        } else {
            [myObjFF sendMessage:[NSString stringWithFormat:@"Unable to delete backup file: %@!",cellTag] MyTitle:@"Backup Deleted Error" ViewController:self];
        }
        [self reloadData];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return  @[deleteAction,RestoreAction];
}
@end
