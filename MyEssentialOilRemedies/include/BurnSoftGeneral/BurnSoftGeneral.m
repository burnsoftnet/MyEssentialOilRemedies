//
//  BurnSoftGeneral.m
//  BurnSoftGeneral
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "BurnSoftGeneral.h"

@implementation BurnSoftGeneral
{
    
}

#pragma mark Fluff Content String
/*! @briefThis will Fluff/Prep the string for inserting value into a database
 It will mostly take out things that can conflict, such as the single qoute
 */
-(NSString *) FCString: (NSString *) sValue {
    NSString *sAns = [NSString new];
    sAns = [sValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    sAns = [sAns stringByReplacingOccurrencesOfString:@"`" withString:@"''"];
    sAns = [sAns stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return sAns;
}

#pragma mark Fluff Content String for XML
/*! @briefThis will Fluff/Prep the string for inserting value into a database and XML File
 It will mostly take out things that can conflict, such as the single qoute
 */
+(NSString *) FCStringXML: (NSString *) sValue {
    NSString *sAns = [NSString new];
    sAns = [sValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    sAns = [sAns stringByReplacingOccurrencesOfString:@"`" withString:@"''"];
    sAns = [sAns stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    sAns = [sAns stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return sAns;
}

#pragma mark Fluff Content String to Long
/*! @brief This will convert a string into a long value
 */
-(unsigned long) FCLong:(NSString *) sValue;{
    NSUInteger uAns = [sValue length];
    unsigned long iAns = uAns;
    return iAns;
}

#pragma mark Get Value from Long String
/*! @brief This will get the value that is store in a long string
 Pass the string, the common seperater, and the ares it should be located at
 @code
 sValue = @"brown,cow,how,two"
 mySeperator = @","
 myIndex = 2
 Result = @"how"
 @endcode
 */
-(NSString *)getValueFromLongString:(NSString *)sValue :(NSString *)mySeparater :(NSInteger) myIndex
{
    NSString *sAns = [NSString new];
    NSArray *myArray = [sValue componentsSeparatedByString:mySeparater];
    sAns = [myArray objectAtIndex:myIndex];
    return sAns;
}

#pragma mark Count Characters
/*! @briefThis will return the number of characters in a string
 */
-(unsigned long) CountCharacters:(NSString *)sValue{
    NSUInteger uAns = [sValue length];
    unsigned long iAns = uAns;
    return iAns;
}

#pragma mark Is Numeric
/*! @brief This will return true if the value is a number, false if it isn't
 */
-(BOOL) isNumeric :(NSString *) sValue
{
    static BOOL bAns = NO;
    NSScanner *scanner = [NSScanner scannerWithString:sValue];
    if ([sValue length] != 0)
    {
        if ([scanner scanInteger:NULL] && [scanner isAtEnd])
        {
            bAns = YES;
        }
    } else {
        bAns = YES;
    }
    scanner = nil;
    return bAns;
}

#pragma mark Format Date
/*! @brief Format date to mm/dd/yyyy
 */
-(NSString *)formatDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"MM'/'dd'/'yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    dateFormatter = nil;
    return formattedDate;
}
-(BOOL) copyFileFrom:(NSString *) sFrom To:(NSString *) sTo ErrorMessage:(NSString **) errorMessage
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *deleteError = [NSString new];
    NSError *error;
    BOOL bAns = NO;
    BOOL FileExistsInTo = [fileManager fileExistsAtPath:sTo];
    BOOL FileExistsInFrom = [fileManager fileExistsAtPath:sFrom];
    BOOL FileClearedInDestination = NO;
    
    if (FileExistsInTo && FileExistsInFrom)
    {
        FileClearedInDestination = [self DeleteFileByPath:sTo ErrorMessage:&deleteError];
    } else if (FileExistsInFrom && !FileExistsInTo) {
        FileClearedInDestination = YES;
    } else if (!FileExistsInFrom && !FileExistsInTo) {
        //In the restore database, this is coming up as file does not exist in either location, even if i see it.
        
        FileClearedInDestination = NO;
        *errorMessage = @"File doesn't exist in source or destination!";
    }
    
    if (FileClearedInDestination)
    {
        if (![fileManager copyItemAtPath:sFrom toPath:sTo error:&error])
        {
            *errorMessage = [NSString stringWithFormat:@"Error copying file: %@",[error localizedDescription]];
        } else {
            *errorMessage = [NSString stringWithFormat:@"Backup Successful!"];
            bAns = YES;
        }
    } else {
        if ([*errorMessage isEqualToString:@""]) {
            *errorMessage = [NSString stringWithFormat:@"Delete Error: %@",deleteError];
        }
    }
    
    fileManager = nil;
    
    return bAns;
}

#pragma mark CopyFile
/*!
 @brief:Simplify the copy and replace method with overwriteoption
 */
+(BOOL) copyFileFromFilePath:(NSString *) fromPath ToNewPath:(NSString *) toPath ErrorMessage:(NSString **) msg
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    NSString *deleteError = [NSString new];
    BOOL success;
    BOOL bAns = NO;
    
    BOOL FileExistsAtDest = [fileManager fileExistsAtPath:toPath];
    BOOL FileExistsAtSource = [fileManager fileExistsAtPath:fromPath];
    BOOL DESTDELETESUCCESSFUL = NO;
    
    if (FileExistsAtSource && FileExistsAtDest) {
        DESTDELETESUCCESSFUL = [self DeleteFileByPath:toPath ErrorMessage:&deleteError];
    } else if (!FileExistsAtDest && FileExistsAtSource) {
        DESTDELETESUCCESSFUL = YES;
    } else if (!FileExistsAtSource && !FileExistsAtDest) {
        DESTDELETESUCCESSFUL = NO;
        *msg = [NSString stringWithFormat:@"File Does not Exist at Source or Destination!"];
    }
    
    if (DESTDELETESUCCESSFUL)
    {
        success = [fileManager copyItemAtPath:fromPath toPath:toPath error:&error];
        if (!success)
        {
            *msg = [NSString stringWithFormat:@"Error coping file: %@",[error localizedDescription]];
        } else {
            *msg = [NSString stringWithFormat:@"Copy Successful!"];
            bAns = YES;
        }
    } else {
        if ([*msg isEqualToString:@""])
        {
            *msg = deleteError;
        }
    }
    
    return bAns;
}
#pragma mark CopyFile 2
/*!
 @brief:Simplify the copy and replace method with overwriteoption
 */
+(BOOL) copyFileFrom:(NSString *) sFrom To:(NSString *) sTo ErrorMessage:(NSString **) errorMessage
{
    BOOL bAns = NO;
    @try {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *deleteError = [NSString new];
        NSError *error;
        
        BOOL FileExistsInTo = [fileManager fileExistsAtPath:sTo];
        BOOL FileExistsInFrom = [fileManager fileExistsAtPath:sFrom];
        BOOL FileClearedInDestination = NO;
        
        if (FileExistsInTo && FileExistsInFrom)
        {
            FileClearedInDestination = [self DeleteFileByPath:sTo ErrorMessage:&deleteError];
        } else if (!FileExistsInFrom && FileExistsInTo) {
            FileClearedInDestination = YES;
        } else if (FileExistsInFrom && !FileExistsInTo) {
            //added this with the error getting from a new backup check
            FileClearedInDestination = YES;
        } else if (!FileExistsInFrom && !FileExistsInTo) {
            FileClearedInDestination = NO;
            *errorMessage = @"File doesn't exist in source or destination!";
        }
        
        if (FileClearedInDestination)
        {
            if (![fileManager copyItemAtPath:sFrom toPath:sTo error:&error])
            {
                *errorMessage = [NSString stringWithFormat:@"Error copying file: %@",[error localizedDescription]];
            } else {
                *errorMessage = [NSString stringWithFormat:@"Backup Successful!"];
                bAns = YES;
            }
        } else {
            if ([*errorMessage isEqualToString:@""]) {
                *errorMessage = [NSString stringWithFormat:@"Delete Error: %@",deleteError];
            }
        }
    } @catch (NSException *exception) {
        *errorMessage = [NSString stringWithFormat:@"%@",[exception reason]];
    }
    
    return bAns;
}
#pragma mark Delete File byPath
/*!
 @brief:Pass the path and file to delete that file
 */
+(BOOL)DeleteFileByPath:(NSString *) sPath ErrorMessage:(NSString **) msg
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = NO;
    NSError *error;
    BOOL fileExists = [fileManager fileExistsAtPath:sPath];
    if (fileExists)
    {
        success = [fileManager removeItemAtPath:sPath error:&error];
        if (!success)
        {
            *msg = [NSString stringWithFormat:@"Error deleting database: %@",[error localizedDescription]];
        }else {
            *msg = [NSString stringWithFormat:@"Delete Successful!"];
        }
    } else {
        success = YES;
    }
    
    return success;
}
#pragma mark Delete File By Path
/*!
 @brief: Delete file from the path
 */
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
    
    fileManager = nil;
    
    return success;
}
#pragma mark Create Directory if not Exists
/*!
 @brief: Create a directory if it doesn't already exists
 */
-(BOOL)createDirectoryIfNotExists:(NSString *) sPath ErrorMessage:(NSString **) errMsg
{
    BOOL bAns = NO;
    BOOL isDir;
    NSError *error;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:sPath isDirectory:&isDir]) {
        if(![fileManager createDirectoryAtPath:sPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            *errMsg = [NSString stringWithFormat:@"%@",[error localizedDescription]];
        } else {
            bAns = YES;
        }
    } else {
        bAns = YES;
    }
    
    fileManager = nil;
    
    return bAns;
}
#pragma mark Convert Bool to String
/*! @brief  Convert the boolen to a string yes or No
    @return yes or no as string
 */
+(NSString *) convertBOOLtoString:(BOOL) bValue
{
    NSString *sAns = [NSString new];
    if (bValue) {
        sAns = @"Yes";
    } else {
        sAns = @"No";
    }
    return sAns;
}

#pragma mark Get File Exteension From File Path
/*! @brief Get the extension of the file from the full path
 */
+(NSString *) getFileExtensionbyPath:(NSString *) filePath
{
    NSArray *pathArray = [filePath componentsSeparatedByString:@"."];
    NSString *fileExtension = [pathArray lastObject];
    pathArray = nil;
    return fileExtension;
}
 #pragma mark Clea Document InBox
/*!
 @brief: Clear up Document InBox, don't want an old version of the drop to keep from getting a newer version.
 */
+(void) clearDocumentInBox
{
    BurnSoftGeneral *myObj = [BurnSoftGeneral new];
    NSString *msg =@"";
    NSString *deleteFile=@"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingString:@"/Inbox/"];
    
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];

    for (int x = 0; x < [dirFiles count]; x++) {
        deleteFile = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"%@",dirFiles[x]]];
        [myObj DeleteFileByPath:deleteFile ErrorMessage:&msg];
    }
    
    myObj = nil;
    paths = nil;
    dirFiles = nil;
}
#pragma mark New Files Found
/*!
 @brief: Start processing new files that was found in the inbox, normally occurs on an airdrop
 */
+(BOOL) newFilesfoundProcessing
{
    BOOL bAns = NO;
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        documentsDirectory = [documentsDirectory stringByAppendingString:@"/Inbox/"];
        
        NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
        if([dirFiles count] > 0 ) {
            bAns = YES;
        }
        
        paths = nil;
        documentsDirectory = nil;
        dirFiles = nil;
    } @catch (NSException *exception) {
        NSString *errMsg = [exception reason];
        NSLog(@"%@",errMsg);
    }
    return bAns;
}
#pragma mark Convert NSNumber to string
/*! @brief  Convert a string to NSNumber
 */
+(NSNumber *) convertToNSNumberByString:(NSString *) sValue
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *nNumber = [f numberFromString:sValue];
    return nNumber;
}
@end
