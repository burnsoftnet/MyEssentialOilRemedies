//
//  SearchDatabaseTests.m
//  My Essential Oil Remedies Tests
//
//  Unit tests for the SearchDatabase class, run against a temporary copy of
//  the factory MEO.db (9 oils + 3 remedies).
//

#import <XCTest/XCTest.h>
#import "SearchDatabase.h"
#import "MEOTestHelpers.h"

@interface SearchDatabaseTests : XCTestCase
@end

@implementation SearchDatabaseTests
{
    NSString *dbPath;
    SearchDatabase *search;
}

- (void)setUp
{
    [super setUp];
    dbPath = MEOCopyFactoryDatabaseToTemp();
    XCTAssertNotNil(dbPath, @"Could not copy the factory MEO.db out of the host app bundle");
    search = [SearchDatabase new];
}

- (void)tearDown
{
    if (dbPath != nil) {
        [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
    }
    [super tearDown];
}

#pragma mark Get All Search Data Simple
- (void)testGetAllSearchDataSimpleCombinesOilsAndRemedies
{
    NSMutableArray *results = [search getAllSearchDataSimple:dbPath ErrorMessage:@""];

    XCTAssertEqual(results.count, (NSUInteger)12, @"Should return the 9 oils plus the 3 remedies");
    XCTAssertTrue([results containsObject:@"Lavender"]);
    XCTAssertTrue([results containsObject:@"Detox"]);
}

#pragma mark Get Oil ID by Name
- (void)testIsOilByNameReturnsIDForOilsAndZeroOtherwise
{
    NSString *errorMsg = @"";
    XCTAssertEqual([search isOilbyName:@"Lavender" databasePath:dbPath ErrorMessage:&errorMsg], (NSInteger)130);
    XCTAssertEqual([search isOilbyName:@"Detox" databasePath:dbPath ErrorMessage:&errorMsg], (NSInteger)0, @"A remedy name is not an oil");
    XCTAssertEqual([search isOilbyName:@"No Such Entry" databasePath:dbPath ErrorMessage:&errorMsg], (NSInteger)0);
}

#pragma mark Get Remedy ID by Name
- (void)testIsRemedyByNameReturnsIDForRemediesAndZeroOtherwise
{
    NSString *errorMsg = @"";
    XCTAssertEqual([search isRemedybyName:@"Detox" databasePath:dbPath ErrorMessage:&errorMsg], (NSInteger)51);
    XCTAssertEqual([search isRemedybyName:@"Lavender" databasePath:dbPath ErrorMessage:&errorMsg], (NSInteger)0, @"An oil name is not a remedy");
    XCTAssertEqual([search isRemedybyName:@"No Such Entry" databasePath:dbPath ErrorMessage:&errorMsg], (NSInteger)0);
}

@end
