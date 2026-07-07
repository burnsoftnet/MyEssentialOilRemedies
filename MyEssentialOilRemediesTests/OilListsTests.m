//
//  OilListsTests.m
//  My Essential Oil Remedies Tests
//
//  Unit tests for the OilLists class, run against a temporary copy of the
//  factory MEO.db (9 oils, 2 in stock, 2 flagged for re-order).
//

#import <XCTest/XCTest.h>
#import "OilLists.h"
#import "MEOTestHelpers.h"

@interface OilListsTests : XCTestCase
@end

@implementation OilListsTests
{
    NSString *dbPath;
    OilLists *oilLists;
}

- (void)setUp
{
    [super setUp];
    dbPath = MEOCopyFactoryDatabaseToTemp();
    XCTAssertNotNil(dbPath, @"Could not copy the factory MEO.db out of the host app bundle");
    oilLists = [OilLists new];
}

- (void)tearDown
{
    if (dbPath != nil) {
        [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
    }
    [super tearDown];
}

#pragma mark Get List of Oils
- (void)testGetAllOilsListReturnsFactoryOilsSortedByName
{
    NSString *errorMsg = @"";
    NSMutableArray *oils = [oilLists getAllOilsList:dbPath :&errorMsg];

    XCTAssertEqual(oils.count, (NSUInteger)9, @"Factory database ships with 9 oils. Error: %@", errorMsg);
    OilLists *first = oils.firstObject;
    XCTAssertEqualObjects(first.name, @"Ginger", @"List should be sorted by name");
    XCTAssertTrue(first.OID > 0);
}

#pragma mark Oil Exists By Name
- (void)testOilExistsByNameIsCaseInsensitive
{
    NSString *errorMsg = @"";
    XCTAssertTrue([oilLists oilExistsByName:@"Lavender" DatabasePath:dbPath ErrorMessage:&errorMsg]);
    XCTAssertTrue([oilLists oilExistsByName:@"lavender" DatabasePath:dbPath ErrorMessage:&errorMsg]);
    XCTAssertFalse([oilLists oilExistsByName:@"No Such Oil" DatabasePath:dbPath ErrorMessage:&errorMsg]);
}

#pragma mark Oil Name/ID Lookups
- (void)testGetOilNameByIDReturnsLavender
{
    NSString *errorMsg = @"";
    NSString *name = [oilLists getOilNameByID:130 DatabasePath:dbPath ErrorMessage:&errorMsg];
    XCTAssertEqualObjects(name, @"Lavender");
}

- (void)testGetOilIDByNameReturnsExistingID
{
    NSString *errorMsg = @"";
    NSNumber *oid = [OilLists getOilIDByName:@"Lavender" InStock:1 DatabasePath:dbPath ErrorMessage:&errorMsg];
    XCTAssertEqual([oid intValue], 130);
}

- (void)testGetOilIDByNameInsertsNewOilWhenMissing
{
    NSString *errorMsg = @"";
    NSNumber *oid = [OilLists getOilIDByName:@"Unit Test Oil" InStock:0 DatabasePath:dbPath ErrorMessage:&errorMsg];

    XCTAssertTrue([oid intValue] > 0, @"A new oil should get a database ID");
    XCTAssertTrue([oilLists oilExistsByName:@"Unit Test Oil" DatabasePath:dbPath ErrorMessage:&errorMsg]);
}

#pragma mark In Stock Counts
- (void)testInStockCountsMatchFactoryData
{
    NSString *errorMsg = @"";
    XCTAssertEqual([oilLists getInStockCountByDatabase:dbPath ErrorMessage:&errorMsg], 2);

    NSMutableArray *oils = [oilLists getAllOilsList:dbPath :&errorMsg];
    XCTAssertEqual([OilLists getInStockCountByArray:oils ErrorMessage:&errorMsg], 2);
}

- (void)testUpdateStockStatusChangesInStockCount
{
    NSString *errorMsg = @"";
    // Oil 131 (Ginger) is out of stock in the factory database.
    [oilLists updateStockStatus:@"1" OilID:@"131" DatabasePath:dbPath ErrorMessage:&errorMsg];
    XCTAssertEqual([oilLists getInStockCountByDatabase:dbPath ErrorMessage:&errorMsg], 3);

    [oilLists updateStockStatus:@"0" OilID:@"131" DatabasePath:dbPath ErrorMessage:&errorMsg];
    XCTAssertEqual([oilLists getInStockCountByDatabase:dbPath ErrorMessage:&errorMsg], 2);
}

#pragma mark Re-Order List
- (void)testReOrderCountsMatchFactoryData
{
    NSString *errorMsg = @"";
    XCTAssertEqual([OilLists listInShopping:dbPath ErrorMessage:&errorMsg], 2);

    NSMutableArray *reorderOils = [oilLists getOilsForReOrder:dbPath ErrorMessage:&errorMsg];
    XCTAssertEqual(reorderOils.count, (NSUInteger)2);

    NSMutableArray *allOils = [oilLists getAllOilsList:dbPath :&errorMsg];
    XCTAssertEqual([OilLists listInShoppingByArray:allOils ErrorMessage:&errorMsg], 2);
}

#pragma mark Remedies Related to an Oil
- (void)testGetRemediesRelatedToOilID
{
    NSString *errorMsg = @"";
    // Oil 137 is linked to the Detox remedy in the factory database.
    NSMutableArray *remedies = [oilLists getRemediesRelatedToOilID:@"137" DatabasePath:dbPath ErrorMessage:&errorMsg];

    XCTAssertEqual(remedies.count, (NSUInteger)1);
    OilLists *related = remedies.firstObject;
    XCTAssertEqual(related.RID, 51);
    XCTAssertEqualObjects(related.RemedyName, @"Detox");
}

@end
