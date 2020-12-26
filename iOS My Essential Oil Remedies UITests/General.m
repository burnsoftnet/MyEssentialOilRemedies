//
//  NSObject+General.m
//  iOS My Essential Oil Remedies UITests
//
//  Created by burnsoft on 12/25/20.
//  Copyright © 2020 burnsoft. All rights reserved.
//

#import "General.h"

@implementation General : NSObject
/*!
 @discussion Disect string to software based keyboard
 @brief  pass a string to be taken apart character by character to send to the software based keyboard.
 @param app - iOS app instance
 @param value - the string that you want to take apart to send to keyboard
 */
+(void)sendTextToKeyBoard:(XCUIApplication *) app :(NSString *) value
{
    //Start code section for string diesect and send
    NSUInteger len = [value length];
    unichar buffer[len+1];

    [value getCharacters:buffer range:NSMakeRange(0, len)];

    NSLog(@"getCharacters:range: with unichar buffer");
    BOOL wasNumeric = NO;
    for(int i = 0; i < len; i++) {
        NSString *newValue = [NSString stringWithFormat:@"%C", buffer[i]];

        if ([newValue length] > 0)
        {
            if ([newValue isEqual:@" "])
            {
                newValue = @"space";
            }else if ([General isNumeric:newValue])
            {
                wasNumeric = YES;
                [app.keys[@"more"] tap];
            }
            [app.keys[newValue] tap];
            if (wasNumeric)
            {
                [app.keys[@"more"] tap];
                wasNumeric = NO;
            }
        }
    }
}

#pragma mark Is Numeric
/*! @brief This will return true if the value is a number, false if it isn't
*/
+(BOOL) isNumeric :(NSString *) sValue
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
@end
