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
//This will Fluff/Prep the string for inserting value into a database
//It will mostly take out things that can conflict, such as the single qoute
-(NSString *) FCString: (NSString *) sValue {
    NSString *sAns = [NSString new];
    sAns = [sValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    sAns = [sAns stringByReplacingOccurrencesOfString:@"`" withString:@"''"];
    sAns = [sAns stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return sAns;
}

#pragma mark Fluff Content String for XML
//This will Fluff/Prep the string for inserting value into a database and XML File
//It will mostly take out things that can conflict, such as the single qoute
+(NSString *) FCStringXML: (NSString *) sValue {
    NSString *sAns = [NSString new];
    sAns = [sValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    sAns = [sAns stringByReplacingOccurrencesOfString:@"`" withString:@"''"];
    sAns = [sAns stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    sAns = [sAns stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return sAns;
}

#pragma mark Fluff Content String to Long
//This will convert a string into a long value
-(unsigned long) FCLong:(NSString *) sValue;{
    NSUInteger uAns = [sValue length];
    unsigned long iAns = uAns;
    return iAns;
}

#pragma mark Get Value from Long String
//This will get the value that is store in a long string
//Pass the string, the common seperater, and the ares it should be located at
//EXAMPE:
//sValue = @"brown,cow,how,two"
//mySeperator = @","
//myIndex = 2
//Result = @"how"
-(NSString *)getValueFromLongString:(NSString *)sValue :(NSString *)mySeparater :(NSInteger) myIndex
{
    NSString *sAns = [NSString new];
    NSArray *myArray = [sValue componentsSeparatedByString:mySeparater];
    sAns = [myArray objectAtIndex:myIndex];
    return sAns;
}

#pragma mark Count Characters
//This will return the number of characters in a string
-(unsigned long) CountCharacters:(NSString *)sValue{
    NSUInteger uAns = [sValue length];
    unsigned long iAns = uAns;
    return iAns;
}

#pragma mark Is Numeric
//This will return true if the value is a number, false if it isn't
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
//Format date to mm/dd/yyyy
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
// Get the extension of the file from the full path
+(NSString *) getFileExtensionbyPath:(NSString *) filePath
{
    NSArray *pathArray = [filePath componentsSeparatedByString:@"."];
    NSString *fileExtension = [pathArray lastObject];
    pathArray = nil;
    return fileExtension;
}

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
        NSLog(@"%@",dirFiles[x]);
        deleteFile = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"%@",dirFiles[x]]];
        [myObj DeleteFileByPath:deleteFile ErrorMessage:&msg];
    }
    
    myObj = nil;
    paths = nil;
    dirFiles = nil;
}

+(BOOL) newFilesfoundProcessing
{
    BOOL bAns = NO;
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
    
    return bAns;
}
@end
