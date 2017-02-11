//
//  DatabaseManagement.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 1/30/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import "DatabaseManagement.h"

@implementation DatabaseManagement


-(NSString *)grabCloudPath
{
    //Might be able to delete
    NSString *container = [CloudHelper containerize:@"net.burnsoft.MyEssentialOilRemedies"];
    NSURL *destinationURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier: container];;
    NSString *pathToCloudFile = [[NSString stringWithFormat:@"%@",destinationURL] stringByAppendingPathComponent:@"Documents"];
    NSString *sAns = [pathToCloudFile stringByReplacingOccurrencesOfString:@"file:" withString:@""];
    sAns = [sAns stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    return sAns;
}
-(BOOL) backupDatabaseToiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg
{
    //BOOL TestWorked = [CloudHelper setUbiquitous:NO for:DBNAME forContainer:@"net.burnsoft.MyEssentialOilRemedies"];
    
    ///NSString *cloudURL = [self grabCloudPath];
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
    ///NSError *error;
    NSString *deleteError = [NSString new];
    ///BOOL success;
    BOOL bAns = NO;
    
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    //NSLog(@"%@",[baseURL path]);
    NSString *cloudURL = [baseURL path];
    NSString *newDBName = [NSString stringWithFormat:@"%@/Documents/%@",cloudURL,[DBNAME stringByReplacingOccurrencesOfString:@"db" withString:@"zip"]];
    //New Section
    NSString *copyError = [NSString new];
    NSString *backupfile = [dbPathString stringByReplacingOccurrencesOfString:@"db" withString:@"zip"];
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

    /*
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    BOOL FileExistsiniCloud = [fileManager fileExistsAtPath:newDBName];
    BOOL FileExistsinLocal = [fileManager fileExistsAtPath:dbPathString];
    BOOL ILOCALDELETESUCCESSFUL = NO;
    
    if (FileExistsinLocal && FileExistsiniCloud)
    {
        ILOCALDELETESUCCESSFUL = [self DeleteFileByPath:dbPathString ErrorMessage:&deleteError];
    } else if (!FileExistsiniCloud && FileExistsinLocal) {
        ILOCALDELETESUCCESSFUL = YES;
    } else if (!FileExistsinLocal && !FileExistsiniCloud) {
        ILOCALDELETESUCCESSFUL = NO;
        *msg = [NSString stringWithFormat:@"%@ File doesn't exist in local or iCloud!",DBNAME];
    }

    if (ILOCALDELETESUCCESSFUL)
    {
        //New Section from http://stackoverflow.com/questions/13282729/move-copy-a-file-to-icloud
        
        NSURL *fromURL = [[NSURL alloc] initWithString:newDBName];
        NSURL *toURL = [[NSURL alloc] initWithString:dbPathString];
        [[[NSFileManager alloc] init]setUbiquitous:NO itemAtURL:fromURL destinationURL:toURL error:&error];
        
        //End New Section
        
        success = [fileManager copyItemAtPath:newDBName toPath:dbPathString error:&error];
        if (!success)
        {
            *msg = [NSString stringWithFormat:@"Error restoring database: %@",[error localizedDescription]];
        } else {
            *msg = [NSString stringWithFormat:@"Restore Successful!"];
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

-(BOOL)DeleteFileByPath:(NSString *) sPath ErrorMessage:(NSString **) msg
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = NO;
    NSError *error;
    
    success = [fileManager removeItemAtPath:sPath error:&error];
    if (!success)
    {
        *msg = [NSString stringWithFormat:@"Error deleting database: %@",[error localizedDescription]];
    }else {
        *msg = [NSString stringWithFormat:@"Delete Successful!"];
    }
    return success;
}
@end
