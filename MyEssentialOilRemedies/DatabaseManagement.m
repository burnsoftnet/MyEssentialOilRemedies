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
    
    return self;
}

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

}

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
}

-(NSString *) getiCloudDatabaseBackupByDBName:(NSString *) DBNAME replaceExtentionTo:(NSString *) newExt
{
    NSString *sAns = [NSString new];
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSString *cloudURL = [baseURL path];
    sAns = [NSString stringWithFormat:@"%@/Documents/%@",cloudURL,[DBNAME stringByReplacingOccurrencesOfString:@"db" withString:newExt]];
    return sAns;
}

-(NSURL *) getiCloudDatabaseBackupURLByDBName:(NSString *) DBNAME replaceExtentionTo:(NSString *) newExt
{
    NSURL *uAns = [NSURL new];
    uAns = [NSURL fileURLWithPath:[self getiCloudDatabaseBackupByDBName:DBNAME replaceExtentionTo:newExt]];
    return uAns;
}



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
    
    return bAns;
}


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
    return bAns;
}
@end
