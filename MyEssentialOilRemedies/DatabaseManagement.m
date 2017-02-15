//
//  DatabaseManagement.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 1/30/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import "DatabaseManagement.h"

@interface DatabaseManagement()
@property (nonatomic,copy) void(^initBlock)(void);
-(void)initializeCodeDataStack;
@end

@implementation DatabaseManagement

-(BOOL) backupDatabaseToiCloudByDBName_new:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg
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

-(BOOL) backupDatabaseToiCloudByDBName:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg
{
    BOOL bAns = NO;
    [self manageDocument];
    return bAns;
}
-(BOOL) backupDatabaseToiCloudByDBName_newish:(NSString *) DBNAME LocalDatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg
{
    /*
    
    NSString* docs = [NSSearchPathForDirectoriesInDomains(
                                                          NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager* fm = [NSFileManager new];
    NSError* err = nil;
    NSURL* docsurl =
    [fm URLForDirectory:NSDocumentDirectory
               inDomain:NSUserDomainMask appropriateForURL:nil
                 create:YES error:&err];
    // error-checking omitted
    NSURL* suppurl =
    [fm URLForDirectory:NSApplicationSupportDirectory
               inDomain:NSUserDomainMask appropriateForURL:nil
                 create:YES error:&err];
    
    NSURL* myfolder = [docsurl URLByAppendingPathComponent:@"MyFolder"];
    //NSError* err = nil;
    BOOL ok =
    [fm createDirectoryAtURL:myfolder
 withIntermediateDirectories:YES attributes:nil error:nil];
    // ... error-checking omitted
    
    NSArray* arr =
    [fm contentsOfDirectoryAtURL:docsurl
      includingPropertiesForKeys:nil options:0 error:&err];
    // ... error-checking omitted
    NSLog(@"%@", [arr valueForKey:@"lastPathComponent"]);

    
    NSDirectoryEnumerator* dir =
    [fm enumeratorAtURL:docsurl
includingPropertiesForKeys:nil options:0 errorHandler:nil];
    for (NSURL* f in dir)
        if ([[f pathExtension] isEqualToString: @"txt"])
            NSLog(@"%@", [f lastPathComponent]);

    //NSError* err = nil;
    BOOL ok2 =
    [@"howdy" writeToURL:[myfolder URLByAppendingPathComponent:@"file1.txt"]
              atomically:YES encoding:NSUTF8StringEncoding error:&err];
    // error-checking omitted
*/
    
    
    NSURL *ubiq = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier:nil];
    if (ubiq) {
        NSLog(@"iCloud access at %@", ubiq);
        // TODO: Load document...
    } else {
        NSLog(@"No iCloud access");
    }
    // First Version
    NSError *error;
    BOOL bAns = NO;
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];

    baseURL = [baseURL URLByAppendingPathExtension:[NSString stringWithFormat:@"/%@",[DBNAME stringByReplacingOccurrencesOfString:@"db" withString:@"zip"]]];

    ///NSString *backupfile = [dbPathString stringByReplacingOccurrencesOfString:@"db" withString:@"zip"];

    
        //New Section from http://stackoverflow.com/questions/13282729/move-copy-a-file-to-icloud
        
        //NSURL *fromURL = [[NSURL alloc] initFileURLWithPath:backupfile];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *docPath = [path objectAtIndex:0];
    NSURL *docPath = [[NSURL alloc] initFileURLWithPath:[path objectAtIndex:0]];
    
    NSURL *fromURL = [NSURL URLWithString:[NSString stringWithFormat:@"/%@",DBNAME] relativeToURL:docPath];
    
    //fromURL = [fromURL URLByAppendingPathExtension:[NSString stringWithFormat:@"/%@",DBNAME]];
    
    NSURL *toURL = [NSURL URLWithString:[NSString stringWithFormat:@"Documents/%@",[DBNAME stringByReplacingOccurrencesOfString:@"db" withString:@"zip"]] relativeToURL:baseURL ];
    
    
    //test docui
    void (^saveFile) (BOOL) = ^(BOOL success) {
        if (success) {
            NSLog(@"save good!");
        } else {
            NSLog(@"save bad!!");
        }
    };
    
    //Possible Bad fromURL string, need to do init path then append documents and then db name like you did with the toURL string
    
    UIDocument *doc = [[UIDocument alloc] initWithFileURL:fromURL];
    
    [doc saveToURL:toURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:saveFile];
    
    // end test
        [[[NSFileManager alloc] init]setUbiquitous:NO itemAtURL:fromURL destinationURL:toURL error:&error];
        NSLog(@"%@",[error localizedDescription]);
    if (![[error localizedDescription] isEqualToString:@""])
    {
        *msg = [error localizedDescription];
    } else {
        bAns = YES;
        *msg = @"Backup Good!";
    }
    return bAns;
}

-(void) manageDocument
{
    dispatch_queue_t queue;
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *storeURL = nil;
        
        storeURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];
        NSDictionary *options = [[NSMutableDictionary alloc] init];
        
        [options setValue:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
        [options setValue:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
        
        if (cloudURL) {
            cloudURL = [cloudURL URLByAppendingPathComponent:@"Documents"];
            cloudURL = [cloudURL URLByAppendingPathComponent:@"MEO.db"];
            [options setValue:[[NSBundle mainBundle] bundleIdentifier] forKey:NSPersistentStoreUbiquitousContentNameKey];
            [options setValue:cloudURL forKey:NSPersistentStoreUbiquitousContentURLKey];
        }
        
        storeURL = [storeURL URLByAppendingPathComponent:@"MEO.db"];
        UIManagedDocument *document = nil;
        document = [[UIManagedDocument alloc] initWithFileURL:storeURL];
        [document setPersistentStoreOptions:options];
        
        NSLog(@"storeURL:  %@",[storeURL path]);
        NSLog(@"cloudURL: %@",[cloudURL path]);
        
        NSMergePolicy *policy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType];
        [[document managedObjectContext] setMergePolicy:policy];
        
        void(^completion)(BOOL) = ^(BOOL success) {
            if (!success) {
                NSLog(@"Error saving %@\n%@",storeURL,[document debugDescription]);
                return;
            }
            
            if ([self initBlock]) {
                dispatch_sync(dispatch_get_main_queue(), ^{[self initBlock]();
                });
            }
        };
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[cloudURL path]]) {
            [document openWithCompletionHandler:completion];
        }
        
        [document saveToURL:cloudURL forSaveOperation:UIDocumentSaveForCreating completionHandler:completion];
    
    });
    
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
