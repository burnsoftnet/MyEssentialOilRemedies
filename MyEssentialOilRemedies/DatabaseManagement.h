//
//  DatabaseManagement.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 1/30/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudHelper.h"
#import <CoreData/CoreData.h>
#import "BurnSoftGeneral.h"

typedef void (^InitCallbackBlock)(void);

@interface DatabaseManagement : NSObject
@property (strong, readonly) NSManagedObjectContext *managedObjectContext;

- (id)initWithCallback:(InitCallbackBlock)callback;

-(BOOL) backupDatabaseToiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg;
-(BOOL) restoreDatabaseFromiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg;
@end
