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

- (id)initWithCallback:(InitCallbackBlock)callback;
{
    if (!(self = [super init])) return nil;
    
    [self setInitCallback:callback];
    //[self initializeCoreData];
    
    return self;
}
//Might be able to delete
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

-(BOOL) backupDatabaseToiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg
{
    NSString *newExt = @"zip";
    NSString *deleteError = [NSString new];
    NSString *copyError = [NSString new];
    //NSError *error = [NSError new];
    BOOL bAns = NO;
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSString *cloudURL = [baseURL path];
    NSString *newDBName = [NSString stringWithFormat:@"%@/Documents/%@",cloudURL,[DBNAME stringByReplacingOccurrencesOfString:@"db" withString:newExt]];
    NSString *backupfile = [dbPathString stringByReplacingOccurrencesOfString:@"db" withString:newExt];
    
    NSURL *urlNewDBName = [NSURL fileURLWithPath:newDBName];
    //NSURL *urlBackupFile = [NSURL fileURLWithPath:backupfile];
    //NSURL *urldbPathString = [NSURL fileURLWithPath:dbPathString];
    
    NSError *error;
    
    
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
    
    NSArray *conflictVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:urlNewDBName];
    for (NSFileVersion *fileVersion in conflictVersions) {
        fileVersion.resolved = YES;
    }
    
    [NSFileVersion removeOtherVersionsOfItemAtURL:urlNewDBName error:&error];
    [myObjG DeleteFileByPath:backupfile ErrorMessage:&deleteError];
    
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
    return bAns;
}
@end
