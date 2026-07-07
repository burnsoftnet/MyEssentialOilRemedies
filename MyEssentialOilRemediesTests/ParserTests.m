//
//  ParserTests.m
//  My Essential Oil Remedies Tests
//
//  Unit tests for the Parser class: XML generation for AirDrop sharing
//  and parsing the generated XML back into oil/remedy values.
//

#import <XCTest/XCTest.h>
#import "Parser.h"

@interface ParserTests : XCTestCase
@end

@implementation ParserTests
{
    NSMutableArray<NSString *> *tempFiles;
}

- (void)setUp
{
    [super setUp];
    tempFiles = [NSMutableArray new];
}

- (void)tearDown
{
    for (NSString *path in tempFiles) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    [super tearDown];
}

#pragma mark Helpers
- (NSString *)writeXMLToTempFile:(NSString *)xml withExtension:(NSString *)ext
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"ParserTests-%@.%@", [[NSUUID UUID] UUIDString], ext]];
    NSError *error = nil;
    BOOL ok = [xml writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    XCTAssertTrue(ok, @"Failed to write test XML file: %@", error);
    [tempFiles addObject:path];
    return path;
}

- (NSString *)lavenderOilXML
{
    return [Parser OilDetailsToXMLForInsertByName:@"Lavender"
                                       CommonName:@"True Lavender"
                                    BotanicalName:@"Lavandula angustifolia"
                                      Ingredients:@"100 percent lavender"
                                      SafetyNotes:@"Dilute before use"
                                            Color:@"Clear"
                                        Viscosity:@"Thin"
                                          InStock:@"1"
                                           Vendor:@"BurnSoft"
                                          WebSite:@"www.burnsoft.net"
                                      Description:@"Calming oil"
                                          IsBlend:@"0"];
}

#pragma mark XML Generation
- (void)testOilDetailsToXMLContainsAllElements
{
    NSString *xml = [self lavenderOilXML];

    XCTAssertTrue([xml containsString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"]);
    XCTAssertTrue([xml containsString:@"<oils>"]);
    XCTAssertTrue([xml containsString:@"</oils>"]);
    XCTAssertTrue([xml containsString:@"<Name>Lavender</Name>"]);
    XCTAssertTrue([xml containsString:@"<commonName>True Lavender</commonName>"]);
    XCTAssertTrue([xml containsString:@"<BotanicalName>Lavandula angustifolia</BotanicalName>"]);
    XCTAssertTrue([xml containsString:@"<ingredients>100 percent lavender</ingredients>"]);
    XCTAssertTrue([xml containsString:@"<safetyNotes>Dilute before use</safetyNotes>"]);
    XCTAssertTrue([xml containsString:@"<color>Clear</color>"]);
    XCTAssertTrue([xml containsString:@"<viscosity>Thin</viscosity>"]);
    XCTAssertTrue([xml containsString:@"<instock>1</instock>"]);
    XCTAssertTrue([xml containsString:@"<vendor>BurnSoft</vendor>"]);
    XCTAssertTrue([xml containsString:@"<website>www.burnsoft.net</website>"]);
    XCTAssertTrue([xml containsString:@"<description>Calming oil</description>"]);
    XCTAssertTrue([xml containsString:@"<isblend>0</isblend>"]);
}

- (void)testRemedyDetailsToXMLListsAllOils
{
    NSArray *oils = @[@"Lavender", @"Peppermint"];
    NSString *xml = [Parser RemedyDetailsToXMLforInsertByName:@"Sleep Aid"
                                                  Description:@"Helps with sleep"
                                                     HowToUse:@"Diffuse at night"
                                                         Oils:oils];

    XCTAssertTrue([xml containsString:@"<remedy>"]);
    XCTAssertTrue([xml containsString:@"</remedy>"]);
    XCTAssertTrue([xml containsString:@"<RemedyName>Sleep Aid</RemedyName>"]);
    XCTAssertTrue([xml containsString:@"<description>Helps with sleep</description>"]);
    XCTAssertTrue([xml containsString:@"<uses>Diffuse at night</uses>"]);
    XCTAssertTrue([xml containsString:@"<oilList>"]);
    XCTAssertTrue([xml containsString:@"<OilName>Lavender</OilName>"]);
    XCTAssertTrue([xml containsString:@"<OilName>Peppermint</OilName>"]);
    XCTAssertTrue([xml containsString:@"</oilList>"]);
}

#pragma mark Parsing Round Trip
- (void)testParsingOilXMLPopulatesOilProperties
{
    NSString *path = [self writeXMLToTempFile:[self lavenderOilXML] withExtension:@"meo"];

    Parser *parser = [[Parser alloc] initWithXMLFile:path];

    XCTAssertTrue(parser.isOIL);
    XCTAssertFalse(parser.isREMEDY);
    XCTAssertEqualObjects(parser.dataType, @"oil");
    XCTAssertEqualObjects(parser.Oil_Name, @"Lavender");
    XCTAssertEqualObjects(parser.Oil_CommonName, @"True Lavender");
    XCTAssertEqualObjects(parser.Oil_BotanicalName, @"Lavandula angustifolia");
    XCTAssertEqualObjects(parser.Oil_Ingredients, @"100 percent lavender");
    XCTAssertEqualObjects(parser.Oil_SafetyNotes, @"Dilute before use");
    XCTAssertEqualObjects(parser.Oil_Color, @"Clear");
    XCTAssertEqualObjects(parser.Oil_Viscosity, @"Thin");
    XCTAssertEqualObjects(parser.Oil_InStock, @"1");
    XCTAssertEqualObjects(parser.Oil_vendor, @"BurnSoft");
    XCTAssertEqualObjects(parser.Oil_website, @"www.burnsoft.net");
    XCTAssertEqualObjects(parser.Oil_description, @"Calming oil");
}

- (void)testParsingRemedyXMLPopulatesRemedyProperties
{
    NSString *xml = [Parser RemedyDetailsToXMLforInsertByName:@"Sleep Aid"
                                                  Description:@"Helps with sleep"
                                                     HowToUse:@"Diffuse at night"
                                                         Oils:@[@"Lavender", @"Peppermint"]];
    NSString *path = [self writeXMLToTempFile:xml withExtension:@"meor"];

    Parser *parser = [[Parser alloc] initWithXMLFile:path];

    XCTAssertTrue(parser.isREMEDY);
    XCTAssertFalse(parser.isOIL);
    XCTAssertEqualObjects(parser.dataType, @"remedy");
    XCTAssertEqualObjects(parser.Remedy_Name, @"Sleep Aid");
    XCTAssertEqualObjects(parser.Remedy_Description, @"Helps with sleep");
    XCTAssertEqualObjects(parser.Remedy_Uses, @"Diffuse at night");
    XCTAssertEqual(parser.Remedy_Oils.count, (NSUInteger)2);
    XCTAssertEqualObjects(parser.Remedy_Oils[0], @"Lavender");
    XCTAssertEqualObjects(parser.Remedy_Oils[1], @"Peppermint");
}

- (void)testReleaseObjectsClearsParsedValues
{
    NSString *path = [self writeXMLToTempFile:[self lavenderOilXML] withExtension:@"meo"];
    Parser *parser = [[Parser alloc] initWithXMLFile:path];
    XCTAssertNotNil(parser.Oil_Name);

    [parser releaseObjects];

    XCTAssertNil(parser.Oil_Name);
    XCTAssertNil(parser.dataType);
    XCTAssertNil(parser.Remedy_Oils);
}

@end
