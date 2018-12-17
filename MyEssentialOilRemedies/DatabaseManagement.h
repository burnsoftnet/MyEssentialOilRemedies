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

/*!
    @brief Backup Database Extensions that will be stored in the cloud
 */
static NSString *BACKUPEXTENSION = @"zip";
/*!
 @brief Database Extensions that will be stored locally
 */
static NSString *DATABASEEXTENSION = @"db";
/*!
 @brief Name of the database in both backup location and local
 */
static NSString *DATABASENAME = @"MEO";
/*!
 @brief Database name that is set in the MySettings.h
 */
static NSString *MAINDBNAME = @MYDBNAME;

@interface DatabaseManagement : NSObject
@property (strong, readonly) NSManagedObjectContext *managedObjectContext;

- (id)initWithCallback:(InitCallbackBlock)callback;
-(BOOL) backupDatabaseToiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg;
-(BOOL) restoreDatabaseFromiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg;
-(void) removeConflictVersionsiniCloudbyURL:(NSURL *) urlNewDBName;
-(NSString *) getiCloudDatabaseBackupByDBName:(NSString *) DBNAME replaceExtentionTo:(NSString *) newExt;
-(NSURL *) getiCloudDatabaseBackupURLByDBName:(NSString *) DBNAME replaceExtentionTo:(NSString *) newExt;
+(void) startiCloudSync;

@end
