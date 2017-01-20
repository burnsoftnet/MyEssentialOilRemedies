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

-(NSString *) FCString: (NSString *) sValue {
    NSString *sAns = [NSString new];
    sAns = [sValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    sAns = [sAns stringByReplacingOccurrencesOfString:@"`" withString:@"''"];
    return sAns;
}
-(unsigned long) FCLong:(NSString *) sValue;{
    NSUInteger uAns = [sValue length];
    unsigned long iAns = uAns;
    return iAns;
}
-(NSString *)getValueFromLongString:(NSString *)sValue :(NSString *)mySeparater :(NSInteger) myIndex
{
    NSString *sAns = [NSString new];
    NSArray *myArray = [sValue componentsSeparatedByString:mySeparater];
    sAns = [myArray objectAtIndex:myIndex];
    return sAns;
}
-(unsigned long) CountCharacters:(NSString *)sValue{
    NSUInteger uAns = [sValue length];
    unsigned long iAns = uAns;
    return iAns;
}

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
-(NSString *)formatDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"MM'/'dd'/'yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return formattedDate;
}
-(void) getPathDetails
{
    //More diagnostic then needed, mostly to find the path details of the app while in ios
    //NSBundle* bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MyGunCollection" ofType:@"bundle"]];
    //NSLog(@"bundle: %@", bundle);
    //NSString* test = [bundle pathForResource:@"mgc" ofType:@"db"];
    //NSLog(@"sqlitedb: %@", test);
    //NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"info" ofType:@"plist"]];
    //NSLog(@"plist: %@", dict);
    //NSString *mydefaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mgc.db"];
    //NSLog(@"mydefaultDBPath: %@", mydefaultDBPath);
}
@end
