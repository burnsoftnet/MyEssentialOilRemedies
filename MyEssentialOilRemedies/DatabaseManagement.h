//
//  DatabaseManagement.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 1/30/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BurnSoftGeneral.h"
#import "FormFunctions.h"
#import "BurnSoftDatabase.h"

typedef void (^InitCallbackBlock)(void);

@interface DatabaseManagement : NSObject
@property (strong, readonly) NSManagedObjectContext *managedObjectContext;

#pragma mark Initiate Call Back
- (id)initWithCallback:(InitCallbackBlock)callback;

#pragma mark Backup Database to iCloud
//Backup the database to the iCloud container
-(BOOL) backupDatabaseToiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg;

#pragma mark Restore Database from iCloud
//Restore the database from the iCloud Drive
-(BOOL) restoreDatabaseFromiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg;

#pragma mark  Remove iCloud Conflicts
// Every device that backups the database to the iCloud container is given a version status which will cause conflicts when attempting to restore the database on another device.  This function will remove any of the conflict version allowing the latest greatest version to exist for restore.
-(void) removeConflictVersionsiniCloudbyURL:(NSURL *) urlNewDBName;

#pragma mark Get iCloud Backup Name in String format
//Get the iCloud backup file name and path
-(NSString *) getiCloudDatabaseBackupByDBName:(NSString *) DBNAME replaceExtentionTo:(NSString *) newExt;

#pragma mark Get iCloud Backup Name in NSURL format
//Get the iCloud backup file name and path
-(NSURL *) getiCloudDatabaseBackupURLByDBName:(NSString *) DBNAME replaceExtentionTo:(NSString *) newExt;

#pragma mark Start iCloud sync
//Start the sync process from the iCloud container. This needs to be ran from the application at start and before the restore is going to be initiated to make sure the latest version is download from the cloud.
+(void) startiCloudSync;

@end
