//
//  MYSettingsTests.m
//  My Essential Oil Remedies Tests
//
//  Unit tests for the MYSettings class and its application constants.
//

#import <XCTest/XCTest.h>
#import "MYSettings.h"

@interface MYSettingsTests : XCTestCase
@end

@implementation MYSettingsTests

#pragma mark Lite/Full Version Check
- (void)testIsLiteVersionIsNoForFullVersionHost
{
    // The tests are hosted inside the full version app, whose
    // CFBundleDisplayName matches FULLVERSIONNAME.
    XCTAssertFalse([MYSettings IsLiteVersion], @"The test host is the full version so IsLiteVersion should be NO");
}

#pragma mark Application Constants
- (void)testExpectedDatabaseVersion
{
    XCTAssertEqualWithAccuracy(MYDBVERSION, 1.4, 0.0001, @"Expected database version changed; make sure DBUpgrade handles the new version");
}

- (void)testDatabaseNameConstant
{
    XCTAssertEqualObjects(@MYDBNAME, @"MEO.db");
}

- (void)testLiteVersionEntryLimit
{
    XCTAssertEqual(LITE_LIMIT, 15);
}

@end
