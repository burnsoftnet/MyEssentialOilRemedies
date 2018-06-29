//
//  Parser.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 4/28/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormFunctions.h"

@interface Parser : NSObject <NSXMLParserDelegate>
{
    NSXMLParser *parser;
    NSMutableString *element;
}

@property (strong, nonatomic) NSString *databasePath;
@property (strong, nonatomic) NSString *appPath;
@property (assign) BOOL isOIL;
@property (assign) BOOL isREMEDY;
@property (strong, nonatomic) NSString *dataType;

//Oil Global Varabiles
@property (strong, nonatomic) NSString *Oil_Name;
@property (nonatomic,strong) NSString *Oil_InStock;
@property (nonatomic,strong) NSString *Oil_isBlend;
@property (nonatomic,strong) NSString *Oil_description;
@property (nonatomic,strong) NSString *Oil_BotanicalName;
@property (nonatomic,strong) NSString *Oil_Ingredients;
@property (nonatomic,strong) NSString *Oil_SafetyNotes;
@property (nonatomic,strong) NSString *Oil_Color;
@property (nonatomic,strong) NSString *Oil_Viscosity;
@property (nonatomic,strong) NSString *Oil_CommonName;
@property (nonatomic,strong) NSString *Oil_vendor;
@property (nonatomic,strong) NSString *Oil_website;

//Remedy Global Varables
@property (strong, nonatomic) NSString *Remedy_Name;
@property (strong, nonatomic) NSString *Remedy_Description;
@property (strong, nonatomic) NSString *Remedy_Uses;
@property (strong, nonatomic) NSMutableArray *Remedy_Oils;


#pragma mark Paser Did Start
//Get the Elemenents from the XML Data source
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;

#pragma mark Parser Did End
//find the end of the elemenent and display the value of that element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

#pragma mark Parser Found Characters
//Append to string when a value was found
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

#pragma mark Initizlies with XML File
-initWithXMLFile:(NSString *) docPath;

#pragma mark Format Data for Oils to XML
+(NSString *) OilDetailsToXMLForInsertByName:(NSString *) OilName CommonName:(NSString *) commonName BotanicalName:(NSString *) botName Ingredients:(NSString *) ingredients SafetyNotes:(NSString *) safetyNotes Color:(NSString *) color Viscosity:(NSString *) viscosity InStock:(NSString *) instock Vendor:(NSString *) vendor WebSite:(NSString *)website Description:(NSString *) description IsBlend:(NSString *) isblend;

#pragma mark Format Data from Remedies to XML
+(NSString *) RemedyDetailsToXMLforInsertByName:(NSString *) remedyName Description:(NSString *) description HowToUse:(NSString *) uses Oils:(NSArray *) oils;

#pragma mark Release all the objects from Memory
-(void) releaseObjects;
@end
