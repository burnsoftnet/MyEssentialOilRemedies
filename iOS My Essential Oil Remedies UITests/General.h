//
//  NSObject+General.h
//  iOS My Essential Oil Remedies UITests
//
//  Created by burnsoft on 12/25/20.
//  Copyright © 2020 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface General : NSObject
/*!
 @discussion Disect string to software based keyboard
 @brief  pass a string to be taken apart character by character to send to the software based keyboard.
 @param app - iOS app instance
 @param value - the string that you want to take apart to send to keyboard
 */
+(void)sendTextToKeyBoard:(XCUIApplication *) app :(NSString *) value;

#pragma mark Is Numeric
/*! @brief This will return true if the value is a number, false if it isn't
*/
+(BOOL) isNumeric :(NSString *) sValue;

@end

NS_ASSUME_NONNULL_END
