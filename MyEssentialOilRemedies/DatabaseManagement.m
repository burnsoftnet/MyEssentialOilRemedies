//
//  DatabaseManagement.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 1/30/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import "DatabaseManagement.h"

@implementation DatabaseManagement
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

-(BOOL) backupDatabaseToiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg
{
    NSString *newExt = @"zip";
    NSString *deleteError = [NSString new];
    NSString *copyError = [NSString new];
    BOOL bAns = NO;
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSString *cloudURL = [baseURL path];
    NSString *newDBName = [NSString stringWithFormat:@"%@/Documents/%@",cloudURL,[DBNAME stringByReplacingOccurrencesOfString:@"db" withString:newExt]];
    NSString *backupfile = [dbPathString stringByReplacingOccurrencesOfString:@"db" withString:newExt];
    
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
