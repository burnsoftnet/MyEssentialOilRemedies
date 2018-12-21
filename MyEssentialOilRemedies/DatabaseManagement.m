//
//  DatabaseManagement.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 1/30/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//  Version 3.0
//

#import "DatabaseManagement.h"

@interface DatabaseManagement()

@property (strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (copy) InitCallbackBlock initCallback;

@end

@implementation DatabaseManagement
{
    NSMutableArray * _entries;
}

#pragma mark Initiate Call Back
/*!
    @brief initialize with Call Back for iCloud Sync
 */
- (id)initWithCallback:(InitCallbackBlock)callback;
{
    if (!(self = [super init])) return nil;
    
    [self setInitCallback:callback];
    
    return self;
}

#pragma mark Print Debugger
/*!
    @brief  Private function to Send Debugger message to FormFunction doBuggermeMessage sub to be printed out via NSLog
 */
-(void) BugMe:(NSString *) message FromSub:(NSString *) location
{
    [FormFunctions doBuggermeMessage:message FromSubFunction:[NSString stringWithFormat:@"DatabaseManagement.%@", location]];
}

#pragma mark  Remove iCloud Conflicts
/*!
    @brief Every device that backups the database to the iCloud container is given a version status which will cause conflicts when attempting to restore the database on another device.  This function will remove any of the conflict version allowing the latest greatest version to exist for restore.
 */
-(void) removeConflictVersionsiniCloudbyURL:(NSURL *) urlNewDBName
{
    NSError *error;
    [self loadFileListings];
    
    [self BugMe:[NSString stringWithFormat:@"%@",urlNewDBName] FromSub:@"removeConflictVersionsiniCloudbyURL"];
    
    if ([NSFileVersion removeOtherVersionsOfItemAtURL:urlNewDBName error:&error])
    {
        [self BugMe:@"older versions were removed!" FromSub:@"removeConflictVersionsiniCloudbyURL"];
    } else {
        [self BugMe:@"Problems removing older versions!" FromSub:@"removeConflictVersionsiniCloudbyURL"];
        [self BugMe:[NSString stringWithFormat:@"%@",[error localizedDescription]] FromSub:@"removeConflictVersionsiniCloudbyURL"];
    }
    
    NSArray *conflictVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:urlNewDBName];
    for (NSFileVersion *fileVersion in conflictVersions) {
        fileVersion.resolved = YES;
        NSLog(@"REMOVED! %@", fileVersion.localizedName);
    }
    conflictVersions = nil;
}

#pragma mark Load File Listtings
/*!
 @brief PRIVATE - list all the extra files version in the iCloud container to delete
 */
-(void) loadFileListings
{
    NSArray *filePathsArray = [NSArray new];
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSString *documentsDirectory = [baseURL path];
    documentsDirectory = [NSString stringWithFormat:@"%@/Documents",documentsDirectory];
    NSString *deleteError = [NSString new];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    filePathsArray = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self ENDSWITH '.%@'", BACKUPEXTENSION]]];
    
    for (NSString *fileName in filePathsArray)
    {
        [self BugMe:[NSString stringWithFormat:@"%@",fileName]  FromSub:@"loadFileListings"];
        if (![fileName isEqualToString:[NSString stringWithFormat:@"%@.%@",DATABASENAME,BACKUPEXTENSION]]){
            [BurnSoftGeneral DeleteFileByPath:[NSString stringWithFormat:@"%@/%@",documentsDirectory,fileName] ErrorMessage:&deleteError];
        }
    }
    //myObjFF = nil;
    filePathsArray = nil;
    dirFiles = nil;
}

#pragma mark Get iCloud Backup Name in String format
/*!
 @brief Get the iCloud backup file name and path
 */
-(NSString *) getiCloudDatabaseBackupByDBName:(NSString *) DBNAME replaceExtentionTo:(NSString *) newExt
{
    NSString *sAns = [NSString new];
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSString *cloudURL = [baseURL path];
    sAns = [NSString stringWithFormat:@"%@/Documents/%@",cloudURL,[DBNAME stringByReplacingOccurrencesOfString:DATABASEEXTENSION withString:newExt]];
    return sAns;
}

#pragma mark Get iCloud Backup Name in NSURL format
/*!
 @brief Get the iCloud backup file name and path
 */
-(NSURL *) getiCloudDatabaseBackupURLByDBName:(NSString *) DBNAME replaceExtentionTo:(NSString *) newExt
{
    NSURL *uAns = [NSURL new];
    uAns = [NSURL fileURLWithPath:[self getiCloudDatabaseBackupByDBName:DBNAME replaceExtentionTo:newExt]];
    [self BugMe:[NSString stringWithFormat:@"%@",uAns] FromSub:@"getiCloudDatabaseBackupURLByDBName"];
    return uAns;
}

#pragma mark Backup Database to iCloud
/*!
 @brief Backup the database to the iCloud container
 */
-(BOOL) backupDatabaseToiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg
{
    BOOL bAns = NO;
    
    @try {
        NSString *deleteError = [NSString new];
        NSString *copyError = [NSString new];
        NSString *backupfile = [dbPathString stringByReplacingOccurrencesOfString:DATABASEEXTENSION withString:BACKUPEXTENSION];
        NSString *newDBName = [self getiCloudDatabaseBackupByDBName:DBNAME replaceExtentionTo:BACKUPEXTENSION];
        NSURL *urlNewDBName = [NSURL fileURLWithPath:newDBName];

        bAns = [self performCopyFunctionsFromTarget:dbPathString Destination:backupfile FinalDestination:newDBName ErrorMessage:&copyError];
        if (!bAns) {
            *msg = [NSString stringWithFormat:@"Error backuping database: %@",copyError];
        } //else {
          //  *msg = [NSString stringWithFormat:@"Backup Successful!"];
        //}
        [self removeConflictVersionsiniCloudbyURL:urlNewDBName];
        [BurnSoftGeneral DeleteFileByPath:backupfile ErrorMessage:&deleteError];
    } @catch (NSException *exception) {
       *msg = [NSString stringWithFormat:@"%@",[exception reason]];
    }
    return bAns;
}

#pragma mark Restore Database from iCloud
/*!
 @brief Restore the database from the iCloud Drive
 */
-(BOOL) restoreDatabaseFromiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg
{
    BOOL bAns = NO;
    @try {
        NSString *newExt = BACKUPEXTENSION;
        NSString *deleteError = [NSString new];
        NSString *newDBName = [self getiCloudDatabaseBackupByDBName:DBNAME replaceExtentionTo:newExt];
        NSString *copyError = [NSString new];
        NSString *backupfile = [dbPathString stringByReplacingOccurrencesOfString:DATABASEEXTENSION withString:newExt];
        //NSString *backupfile1 = [dbPathString stringByReplacingOccurrencesOfString:DATABASEEXTENSION withString:@"db-shm"];
        //NSString *backupfile2 = [dbPathString stringByReplacingOccurrencesOfString:DATABASEEXTENSION withString:@"db-wal"];
        NSURL *URLnewDBName = [NSURL fileURLWithPath:newDBName];
        
        [self removeConflictVersionsiniCloudbyURL:URLnewDBName];
        /*
        if (![BurnSoftGeneral DeleteFileByPath:backupfile ErrorMessage:&deleteError])
        {
            [NSException raise:@"Delete Error" format:@"Error deleting %@ database: %@",backupfile, deleteError];
        }
        if (![BurnSoftGeneral DeleteFileByPath:backupfile1 ErrorMessage:&deleteError])
        {
            [NSException raise:@"Delete Error" format:@"Error deleting %@ database: %@",backupfile, deleteError];
        }
        if (![BurnSoftGeneral DeleteFileByPath:backupfile2 ErrorMessage:&deleteError])
        {
            [NSException raise:@"Delete Error" format:@"Error deleting %@ database: %@",backupfile, deleteError];
        }
         */
        [BurnSoftDatabase resetDBDirectory];
        bAns = [self performCopyFunctionsFromTarget:newDBName Destination:backupfile FinalDestination:dbPathString ErrorMessage:&copyError];
        if (!bAns){
            [NSException raise:@"Restore Error" format:@"Error restoring database: %@", copyError];
        } //else {
         //   *msg = [NSString stringWithFormat:@"Restore Successful!"];
        //}
        if (![BurnSoftGeneral DeleteFileByPath:backupfile ErrorMessage:&deleteError])
        {
            [NSException raise:@"Delete Error" format:@"Error deleting %@ database: %@",backupfile, deleteError];
        }
    } @catch (NSException *exception) {
        *msg = [NSString stringWithFormat:@"%@",[exception reason]];
    }
    return bAns;
}

/*!
    @brief PRIVATE - Perform the copy functions for the iCloud copy, This will copy the database to the same location with a different extenstion then copy the new file name over to the iCloud Path.
    @return YES if no errors occured, NO if an error was thrown.
 */
-(bool) performCopyFunctionsFromTarget:(NSString *) target1 Destination:(NSString *) target2 FinalDestination:(NSString *) target3 ErrorMessage:(NSString **) errMsg
{
    BOOL bAns = NO;
    NSString *copyError = [NSString new];
    @try {
        [self BugMe:[NSString stringWithFormat:@"Target 1 Value: %@", target1] FromSub:@"performCopyFunctionsFromTarget"];
        [self BugMe:[NSString stringWithFormat:@"Target 2 Value: %@", target2] FromSub:@"performCopyFunctionsFromTarget"];
        [self BugMe:[NSString stringWithFormat:@"Target 3 Value: %@", target3] FromSub:@"performCopyFunctionsFromTarget"];
        
        if ([BurnSoftGeneral copyFileFrom:target1 To:target2 ErrorMessage:&copyError]) {
            if (![BurnSoftGeneral copyFileFrom:target2 To:target3 ErrorMessage:&copyError]) {
                [NSException raise:@"Copy Error" format:@"Error coping the database %@", copyError];
            } else {
                bAns = YES;
            }
        } else {
            @throw copyError;
        }
    } @catch (NSException *exception) {
        *errMsg = [NSString stringWithFormat:@"%@",[exception reason]];
    }
    return bAns;
}
#pragma mark Start iCloud sync
/*!
 @brief Start the sync process from the iCloud container. This needs to be ran from the application at start and before the restore is going to be initiated to make sure the latest version is download from the cloud.
 */
+(void) startiCloudSync
{
    @try {
        //BurnSoftDatabase *myObj = [BurnSoftDatabase new];
        //NSString *dbPathString = [NSString new];
        
        //dbPathString = [myObj getDatabasePath:MAINDBNAME];
        
        //Remove any conflicting versions and maybe initialize icloud sync
        DatabaseManagement *myObjDM = [DatabaseManagement new];
        [myObjDM removeConflictVersionsiniCloudbyURL:[myObjDM getiCloudDatabaseBackupURLByDBName:MAINDBNAME replaceExtentionTo:BACKUPEXTENSION]];
        
        NSFileManager *objFM = [NSFileManager new];
        NSError *errMsg;
        if (![objFM startDownloadingUbiquitousItemAtURL:[myObjDM getiCloudDatabaseBackupURLByDBName:MAINDBNAME replaceExtentionTo:BACKUPEXTENSION] error:&errMsg]) {
            [NSException raise:@"SYNC FAILED!" format:@"Error with iCloud sync: %@", errMsg];
            //[myObjDM BugMe:@"sync started!"  FromSub:@"StartiCloudSync"];
        } //else {
          //  [myObjDM BugMe:@"sync FAILED!"  FromSub:@"StartiCloudSync"];
          //  [NSException raise:@"SYNC FAILED!" format:@"Error with iCloud sync: %@", errMsg];
        //}
        [myObjDM BugMe:@"sync started!"  FromSub:@"StartiCloudSync"];
        //myObj = nil;
        myObjDM = nil;
        objFM = nil;
    } @catch (NSException *exception) {
        NSLog(@"ERROR - %@",[NSString stringWithFormat:@"%@",[exception reason]]);
    }
}
@end
