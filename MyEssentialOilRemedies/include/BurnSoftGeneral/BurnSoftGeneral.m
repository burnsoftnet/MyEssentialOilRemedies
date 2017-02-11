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
    } else if (!FileExistsInFrom && FileExistsInTo) {
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
