//
//  OilRemediesTests.m
//  My Essential Oil Remedies Tests
//
//  Unit tests for the OilRemedies class, run against a temporary copy of the
//  factory MEO.db (3 remedies; Detox has 2 linked oils).
//

#import <XCTest/XCTest.h>
#import "OilRemedies.h"
#import "OilLists.h"
#import "MEOTestHelpers.h"

@interface OilRemediesTests : XCTestCase
@end

@implementation OilRemediesTests
{
    NSString *dbPath;
    OilRemedies *remedies;
}

- (void)setUp
{
    [super setUp];
    dbPath = MEOCopyFactoryDatabaseToTemp();
    XCTAssertNotNil(dbPath, @"Could not copy the factory MEO.db out of the host app bundle");
    remedies = [OilRemedies new];
}

- (void)tearDown
{
    if (dbPath != nil) {
        [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
    }
    [super tearDown];
}

#pragma mark Get a List of all Remedies
- (void)testGetAllRemediesReturnsFactoryRemediesSortedByName
{
    NSString *errorMsg = @"";
    NSMutableArray *allRemedies = [remedies getAllRemedies:dbPath :&errorMsg];

    XCTAssertEqual(allRemedies.count, (NSUInteger)3, @"Factory database ships with 3 remedies. Error: %@", errorMsg);
    OilRemedies *first = allRemedies.firstObject;
    XCTAssertEqualObjects(first.name, @"Allergy Migraines", @"List should be sorted by name");
    XCTAssertEqualObjects(first.section, @"A", @"Section should be the first letter of the name");
    XCTAssertTrue(first.RID > 0);
}

#pragma mark Remedy Exists By Name
- (void)testRemedyExistsByName
{
    NSString *errorMsg = @"";
    XCTAssertTrue([remedies RemedyExistsByName:@"Detox" DatabasePath:dbPath ErrorMessage:&errorMsg]);
    XCTAssertTrue([remedies RemedyExistsByName:@"detox" DatabasePath:dbPath ErrorMessage:&errorMsg], @"Lookup should be case-insensitive");
    XCTAssertFalse([remedies RemedyExistsByName:@"No Such Remedy" DatabasePath:dbPath ErrorMessage:&errorMsg]);
}

#pragma mark Get Remedy ID By Name
- (void)testGetRemedyIDByNameFindsDetox
{
    NSString *errorMsg = @"";
    NSNumber *rid = [OilRemedies getRemedyIDByName:@"Detox" DatabasePath:dbPath ErrorMessage:&errorMsg];
    XCTAssertEqual([rid intValue], 51);
}

#pragma mark Get all Oils for Remedy
- (void)testGetAllOilsForRemedyByRID
{
    NSString *errorMsg = @"";
    NSMutableArray *names = [remedies getAllOilfForremedyByRIDNameOnly:@"51" DatabasePath:dbPath ErrorMessage:&errorMsg];
    XCTAssertEqual(names.count, (NSUInteger)2, @"The Detox remedy is linked to 2 oils. Error: %@", errorMsg);
}

#pragma mark Add Oil to Database
- (void)testAddOilNameCreatesOilOnceAndReusesID
{
    NSString *errorMsg = @"";
    NSString *firstID = [remedies AddOilName:@"Unit Test Oil" DatabasePath:dbPath ERRORMESSAGE:&errorMsg];
    XCTAssertTrue([firstID intValue] > 0);
    XCTAssertTrue([remedies oilNameExists:@"Unit Test Oil" DatabasePath:dbPath ERRORMESSAGE:&errorMsg]);

    NSString *secondID = [remedies AddOilName:@"Unit Test Oil" DatabasePath:dbPath ERRORMESSAGE:&errorMsg];
    XCTAssertEqualObjects(firstID, secondID, @"Adding the same oil twice should return the same ID");
}

#pragma mark Add/Update/Delete Remedy Lifecycle
- (void)testAddUpdateDeleteRemedyLifecycle
{
    NSString *errorMsg = @"";

    NSString *newRID = [remedies AddRemedyDetailsByName:@"Unit Test Remedy"
                                            Description:@"Test description"
                                                   Uses:@"Test uses"
                                           DatabasePath:dbPath
                                           ERRORMESSAGE:&errorMsg];
    XCTAssertTrue([newRID intValue] > 0, @"Adding a remedy should return its new ID. Error: %@", errorMsg);
    XCTAssertTrue([remedies RemedyExistsByName:@"Unit Test Remedy" DatabasePath:dbPath ErrorMessage:&errorMsg]);

    XCTAssertTrue([remedies updateRemedyDetailsByRID:newRID
                                                 Name:@"Renamed Test Remedy"
                                          Description:@"New description"
                                                 Uses:@"New uses"
                                         DatabasePath:dbPath
                                         ERRORMESSAGE:&errorMsg]);
    NSNumber *foundRID = [OilRemedies getRemedyIDByName:@"Renamed Test Remedy" DatabasePath:dbPath ErrorMessage:&errorMsg];
    XCTAssertEqual([foundRID intValue], [newRID intValue]);

    XCTAssertTrue([remedies deleteRemedyByID:newRID DatabasePath:dbPath MessageHandler:&errorMsg]);
    XCTAssertFalse([remedies RemedyExistsByName:@"Renamed Test Remedy" DatabasePath:dbPath ErrorMessage:&errorMsg]);
}

#pragma mark Add Oils to Remedy
- (void)testAddOilsToRemedyLinksOilsToRemedy
{
    NSString *errorMsg = @"";

    NSString *newRID = [remedies AddRemedyDetailsByName:@"Oil Link Test Remedy"
                                            Description:@"desc"
                                                   Uses:@"uses"
                                           DatabasePath:dbPath
                                           ERRORMESSAGE:&errorMsg];
    XCTAssertTrue([newRID intValue] > 0);

    // One existing oil plus one that has to be created on the fly.
    [remedies addOilsToRemedyByRemedyID:newRID
                              OilsArray:@[@"Lavender", @"Brand New Test Oil"]
                           DatabasePath:dbPath
                           ErrorMessage:&errorMsg];

    NSMutableArray *linked = [remedies getAllOilfForremedyByRIDNameOnly:newRID DatabasePath:dbPath ErrorMessage:&errorMsg];
    XCTAssertEqual(linked.count, (NSUInteger)2, @"Both oils should be linked to the remedy. Error: %@", errorMsg);

    OilLists *oilLists = [OilLists new];
    XCTAssertTrue([oilLists oilExistsByName:@"Brand New Test Oil" DatabasePath:dbPath ErrorMessage:&errorMsg], @"The unknown oil should have been added to the oil list");

    // Clean up the links so the remedy delete leaves no orphans.
    XCTAssertTrue([remedies ClearOilsPerRemedyByRID:newRID DatabasePath:dbPath MessageHandler:&errorMsg]);
    XCTAssertTrue([remedies deleteRemedyByID:newRID DatabasePath:dbPath MessageHandler:&errorMsg]);
}

@end
