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

- (id)initWithCallback:(InitCallbackBlock)callback;
{
    if (!(self = [super init])) return nil;
    
    [self setInitCallback:callback];
    //[self initializeCoreData];
    
    return self;
}
/*
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL  {
    if (&NSURLIsExcludedFromBackupKey == nil) { // iOS <= 5.0.1
        const char* filePath = [[URL path] fileSystemRepresentation];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    } else { // iOS >= 5.1
        NSError *error = nil;
        [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        return error == nil;
    }
}
*/
+ (void)copyDatabaseIfNeeded:(NSString *) getDBPath DBName:(NSString *) databaseName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *toPath = getDBPath;
    BOOL success = [fileManager fileExistsAtPath:toPath];
    
    if(!success) {
        NSString *fromPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
        
        NSURL *toURL = [NSURL fileURLWithPath:toPath];
        NSURL *fromURL = [NSURL fileURLWithPath:fromPath];
        success = [fileManager copyItemAtURL:fromURL toURL:toURL error:&error];
        
        if (success) {
            //[self addSkipBackupAttributeToItemAtURL:toURL];
        } else {
            NSLog(@"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
    }   
}
-(BOOL) backupDatabaseToiCloudByDBName_crap:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg
{
    //This is from the Existing Application secon from the book
    bool bAns = NO;
    
    dispatch_queue_t queue;
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        [options setValue:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
        [options setValue:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *docURL = nil;
        docURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = nil;
        NSError *error = nil;
        NSPersistentStoreCoordinator * coordinator = nil;
        coordinator = [[self managedObjectContext] persistentStoreCoordinator];
        NSPersistentStore *store = nil;
        
        NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];
        
        if (!cloudURL) {
            storeURL = [docURL URLByAppendingPathComponent:@"MEO.db"];
            store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
            if (!store) {
                *msg = [NSString stringWithFormat:@"Error adding persistent store to coordinator %@\n%@",[error localizedDescription],[error userInfo]];
            }
            //self initblock
            if (![self initCallback]) return;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self initCallback]();
            });
        }
        });
        return bAns;
    }
    //return bAns;
//}
-(BOOL) backupDatabaseToiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg
{
    NSString *newExt = @"zip";
    NSString *deleteError = [NSString new];
    NSString *copyError = [NSString new];
    NSError *error = [NSError new];
    BOOL bAns = NO;
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSString *cloudURL = [baseURL path];
    NSString *newDBName = [NSString stringWithFormat:@"%@/Documents/%@",cloudURL,[DBNAME stringByReplacingOccurrencesOfString:@"db" withString:newExt]];
    NSString *backupfile = [dbPathString stringByReplacingOccurrencesOfString:@"db" withString:newExt];
    //backupfile = [backupfile stringByReplacingOccurrencesOfString:@"/Documents/" withString:@"/Documents/"];
    NSLog(@"%@",backupfile);
    NSLog(@"%@",newDBName);
    NSLog(@"%@",dbPathString);
    
    [NSFileVersion removeOtherVersionsOfItemAtURL:[NSURL fileURLWithPath:newDBName] error:&error];
    
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
    return bAns;
}
-(BOOL) backupDatabaseToiCloudByDBName_Old:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg
{
    //NSError *error;
    NSString *deleteError = [NSString new];
    NSString *copyError = [NSString new];
    //BOOL success;
    BOOL bAns = NO;
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    //NSLog(@"%@",[baseURL path]);
    NSString *cloudURL = [baseURL path];
    //baseURL = [baseURL URLByAppendingPathExtension:[NSString stringWithFormat:@"/%@",[DBNAME stringByReplacingOccurrencesOfString:@"db" withString:@"zip"]]];
    NSString *newDBName = [NSString stringWithFormat:@"%@/Documents/%@",cloudURL,[DBNAME stringByReplacingOccurrencesOfString:@"db" withString:@"zip"]];
    //NSString *newDBName = [NSString stringWithFormat:@"%@/%@",cloudURL,[DBNAME stringByReplacingOccurrencesOfString:@"db" withString:@"zip"]];
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *backupfile = [dbPathString stringByReplacingOccurrencesOfString:@"db" withString:@"zip"];
    
    
    //BOOL fakecopy = [fileManager copyItemAtPath:dbPathString toPath:backupfile error:&error];
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
    /*
    BOOL FileExistsiniCloud = [fileManager fileExistsAtPath:newDBName];
    BOOL FileExistsinLocal = [fileManager fileExistsAtPath:dbPathString];
    BOOL ICLOUDDELETESUCCESSFUL = NO;
    
    if (FileExistsinLocal && FileExistsiniCloud)
    {
        ICLOUDDELETESUCCESSFUL = [self DeleteFileByPath:newDBName ErrorMessage:&deleteError];
    } else if (!FileExistsiniCloud && FileExistsinLocal) {
        ICLOUDDELETESUCCESSFUL = YES;
    } else if (!FileExistsinLocal && !FileExistsiniCloud) {
        ICLOUDDELETESUCCESSFUL = NO;
        *msg = [NSString stringWithFormat:@"%@ File doesn't exist in local or iCloud!",DBNAME];
    }
    
    if (ICLOUDDELETESUCCESSFUL)
    {
        //New Section from http://stackoverflow.com/questions/13282729/move-copy-a-file-to-icloud
        
        NSURL *fromURL = [[NSURL alloc] initFileURLWithPath:backupfile];
        NSURL *toURL = [[NSURL alloc] initFileURLWithPath:newDBName];
        //toURL = [toURL URLByAppendingPathExtension:newDBName];
        //NSURL *toURL = baseURL;
        [[[NSFileManager alloc] init]setUbiquitous:NO itemAtURL:fromURL destinationURL:toURL error:&error];
        NSLog(@"%@",[error localizedDescription]);
        //End New Section
        
        success = [fileManager copyItemAtPath:backupfile toPath:newDBName error:&error];
        //success = [fileManager copyItemAtPath:dbPathString toPath:newDBName error:&error];
        if (!success)
        {
            *msg = [NSString stringWithFormat:@"Error backuping database: %@",[error localizedDescription]];
        } else {
            *msg = [NSString stringWithFormat:@"Backup Successful!"];
            bAns = YES;
        }
    } else {
        if ([*msg isEqualToString:@""]) {
            *msg = deleteError;
        }
    }
     */
    return bAns;
}

-(BOOL) restoreDatabaseFromiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg
{
    NSString *newExt = @"zip";
    NSString *deleteError = [NSString new];
    BOOL bAns = NO;
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSString *cloudURL = [baseURL path];
    NSString *newDBName = [NSString stringWithFormat:@"%@/Documents/%@",cloudURL,[DBNAME stringByReplacingOccurrencesOfString:@"db" withString:newExt]];
    NSString *copyError = [NSString new];
    NSString *backupfile = [dbPathString stringByReplacingOccurrencesOfString:@"db" withString:newExt];
    BurnSoftGeneral *myObjG = [BurnSoftGeneral new];
    NSLog(@"newDBName= %@",newDBName);
    NSLog(@"version= %@",[NSFileVersion otherVersionsOfItemAtURL:[NSURL fileURLWithPath:newDBName]]);
    NSLog(@"backupfile= %@",backupfile);
    NSLog(@"%@",[NSFileVersion currentVersionOfItemAtURL:[NSURL fileURLWithPath:backupfile]]);
    //NSLog(@"%@",dbPathString);
    //NSLog(@"%@",[NSFileVersion currentVersionOfItemAtURL:[NSURL fileURLWithPath:dbPathString]]);
    
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
    return bAns;
}
@end
