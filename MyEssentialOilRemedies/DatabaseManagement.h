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

static NSString *BACKUPEXTENSION = @"zip";
static NSString *DATABASEEXTENSION = @"db";

@interface DatabaseManagement : NSObject
@property (strong, readonly) NSManagedObjectContext *managedObjectContext;

#pragma mark Initiate Call Back
- (id)initWithCallback:(InitCallbackBlock)callback;

#pragma mark Backup Database to iCloud
-(BOOL) backupDatabaseToiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg;

#pragma mark Restore Database from iCloud
-(BOOL) restoreDatabaseFromiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg;

#pragma mark  Remove iCloud Conflicts
-(void) removeConflictVersionsiniCloudbyURL:(NSURL *) urlNewDBName;

#pragma mark Get iCloud Backup Name in String format
-(NSString *) getiCloudDatabaseBackupByDBName:(NSString *) DBNAME replaceExtentionTo:(NSString *) newExt;

#pragma mark Get iCloud Backup Name in NSURL format
-(NSURL *) getiCloudDatabaseBackupURLByDBName:(NSString *) DBNAME replaceExtentionTo:(NSString *) newExt;

#pragma mark Start iCloud sync
+(void) startiCloudSync;

@end
