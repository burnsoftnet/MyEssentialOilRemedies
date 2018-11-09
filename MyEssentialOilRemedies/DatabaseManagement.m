//
//  DatabaseManagement.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 1/30/17.
//  Copyright © 2017 burnsoft. All rights reserved.
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
//  Initialize with Call Back
- (id)initWithCallback:(InitCallbackBlock)callback;
{
    if (!(self = [super init])) return nil;
    
    [self setInitCallback:callback];
    
    return self;
}

#pragma mark  Remove iCloud Conflicts
// Every device that backups the database to the iCloud container is given a version status which will cause conflicts when attempting to restore the database on another device.  This function will remove any of the conflict version allowing the latest greatest version to exist for restore.
-(void) removeConflictVersionsiniCloudbyURL:(NSURL *) urlNewDBName
{
    NSError *error;
    FormFunctions *myObjFF = [FormFunctions new];
    
   [self loadFileListings];
    
    if ([NSFileVersion removeOtherVersionsOfItemAtURL:urlNewDBName error:&error])
    {
        [myObjFF doBuggermeMessage:@"older versions were removed!" FromSubFunction:@"DatabaseManagement.removeConflictVersionsiniCloudbyURL"];
    } else {
        [myObjFF doBuggermeMessage:@"Problems removing older versions!" FromSubFunction:@"DatabaseManagement.removeConflictVersionsiniCloudbyURL"];
        [myObjFF doBuggermeMessage:[NSString stringWithFormat:@"%@",[error localizedDescription]] FromSubFunction:@"DatabaseManagement.removeConflictVersionsiniCloudbyURL"];
    }
    
    
    NSArray *conflictVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:urlNewDBName];
    for (NSFileVersion *fileVersion in conflictVersions) {
        fileVersion.resolved = YES;
    }
    
    myObjFF = nil;
    conflictVersions = nil;
}
#pragma mark Load File Listtings
// PRIVATE - list all the extra files version in the iCloud container to delete
-(void) loadFileListings
{
    FormFunctions *myObjFF = [FormFunctions new];
    BurnSoftGeneral *myObjG = [BurnSoftGeneral new];
    NSArray *filePathsArray = [NSArray new];
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSString *documentsDirectory = [baseURL path];
    documentsDirectory = [NSString stringWithFormat:@"%@/Documents",documentsDirectory];
    NSString *deleteError = [NSString new];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    filePathsArray = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.zip'"]];
    
    for (NSString *fileName in filePathsArray)
    {
        [myObjFF doBuggermeMessage:[NSString stringWithFormat:@"%@",fileName] FromSubFunction:@"DatabaseManagement.loadFileListings"];
        
        if (![fileName isEqualToString:@"MEO.zip"]){
            [myObjG DeleteFileByPath:[NSString stringWithFormat:@"%@/%@",documentsDirectory,fileName] ErrorMessage:&deleteError];
        }
    }
    myObjG = nil;
    myObjFF = nil;
    filePathsArray = nil;
    dirFiles = nil;
}

#pragma mark Get iCloud Backup Name in String format
//Get the iCloud backup file name and path
-(NSString *) getiCloudDatabaseBackupByDBName:(NSString *) DBNAME replaceExtentionTo:(NSString *) newExt
{
    NSString *sAns = [NSString new];
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSString *cloudURL = [baseURL path];
    sAns = [NSString stringWithFormat:@"%@/Documents/%@",cloudURL,[DBNAME stringByReplacingOccurrencesOfString:@"db" withString:newExt]];
    return sAns;
}

#pragma mark Get iCloud Backup Name in NSURL format
//Get the iCloud backup file name and path
-(NSURL *) getiCloudDatabaseBackupURLByDBName:(NSString *) DBNAME replaceExtentionTo:(NSString *) newExt
{
    NSURL *uAns = [NSURL new];
    uAns = [NSURL fileURLWithPath:[self getiCloudDatabaseBackupByDBName:DBNAME replaceExtentionTo:newExt]];
    return uAns;
}


#pragma mark Backup Database to iCloud
//Backup the database to the iCloud container
-(BOOL) backupDatabaseToiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg
{
    NSString *newExt = @"zip";
    NSString *deleteError = [NSString new];
    NSString *copyError = [NSString new];
    BOOL bAns = NO;

    NSString *backupfile = [dbPathString stringByReplacingOccurrencesOfString:@"db" withString:newExt];
   
    NSString *newDBName = [self getiCloudDatabaseBackupByDBName:DBNAME replaceExtentionTo:newExt];
    
    NSURL *urlNewDBName = [NSURL fileURLWithPath:newDBName];
    
    BurnSoftGeneral *myObjG = [BurnSoftGeneral new];
    
    if ([myObjG copyFileFrom:dbPathString To:backupfile ErrorMessage:&deleteError]) {
        if (![myObjG copyFileFrom:backupfile To:newDBName ErrorMessage:&copyError]) {
            *msg = [NSString stringWithFormat:@"Error backuping database: %@",copyError];
        } else {
            *msg = [NSString stringWithFormat:@"Backup Successful!"];
            bAns = YES;
        }
    } else {
        *msg = deleteError;
    }
    
    [self removeConflictVersionsiniCloudbyURL:urlNewDBName];
    [myObjG DeleteFileByPath:backupfile ErrorMessage:&deleteError];
    
    myObjG = nil;
    return bAns;
}

#pragma mark Restore Database from iCloud 
//Restore the database from the iCloud Drive
-(BOOL) restoreDatabaseFromiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg
{
    NSString *newExt = @"zip";
    NSString *deleteError = [NSString new];
    BOOL bAns = NO;
    
    NSString *newDBName = [self getiCloudDatabaseBackupByDBName:DBNAME replaceExtentionTo:newExt];
    
    NSString *copyError = [NSString new];
    NSString *backupfile = [dbPathString stringByReplacingOccurrencesOfString:@"db" withString:newExt];
    BurnSoftGeneral *myObjG = [BurnSoftGeneral new];
    
    NSURL *URLnewDBName = [NSURL fileURLWithPath:newDBName];

    [self removeConflictVersionsiniCloudbyURL:URLnewDBName];
    
    [myObjG DeleteFileByPath:backupfile ErrorMessage:&deleteError];
    
    if ([myObjG copyFileFrom:newDBName To:backupfile ErrorMessage:&deleteError]) {
        if (![myObjG copyFileFrom:backupfile To:dbPathString ErrorMessage:&copyError]) {
            *msg = [NSString stringWithFormat:@"Error backuping database: %@",copyError];
        } else {
            *msg = [NSString stringWithFormat:@"Backup Successful!"];
            bAns = YES;
        }
    } else {
        *msg = deleteError;
    }
    myObjG = nil;
    
    return bAns;
}

#pragma mark Start iCloud sync
//Start the sync process from the iCloud container. This needs to be ran from the application at start and before the restore is going to be initiated to make sure the latest version is download from the cloud.
+(void) startiCloudSync
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    NSString *dbPathString = [NSString new];
    
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
    
    //Remove any conflicting versions and maybe initialize icloud sync
    DatabaseManagement *myObjDM = [DatabaseManagement new];
    NSURL *fileLocation = [myObjDM getiCloudDatabaseBackupURLByDBName:@MYDBNAME replaceExtentionTo:@"zip"];
    
    [myObjDM removeConflictVersionsiniCloudbyURL:fileLocation];
    NSError *errOut = nil;
    NSFileManager *objFM = [NSFileManager new];
    
    NSNumber *isDownloadedValue = NULL;
    
    BOOL success = [fileLocation getResourceValue:&isDownloadedValue forKey: NSURLUbiquitousItemDownloadingStatusKey  error:&errOut];
    
    if (success)
    {
        if ([objFM startDownloadingUbiquitousItemAtURL:fileLocation error:&errOut]) {
            [FormFunctions doBuggermeMessage:@"sync started!" FromSubFunction:@"DatabaseManagement.StartiCloudSync"];
        } else {
            [FormFunctions doBuggermeMessage:[NSString stringWithFormat:@"iCloud Sync Error on startDownloadingUbiquitousItemAtURL : %@", errOut] FromSubFunction:@"DatabaseManagement.StartiCloudSync"];
        }
    } else {
        [FormFunctions doBuggermeMessage:[NSString stringWithFormat:@"iCloud Sync Error on NSURLUbiquitousItemDownloadingStatusKey : %@", errOut] FromSubFunction:@"DatabaseManagement.StartiCloudSync"];
    }
    
    myObj = nil;
    myObjDM = nil;
    objFM = nil;
}
@end
