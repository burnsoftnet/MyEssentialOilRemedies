//
//  XMLParser.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 4/18/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import "XMLClass.h"

@implementation XMLClass
{
    
}
@synthesize marrXMLData;
@synthesize mstrXMLString;
@synthesize mdictXMLPart;

- (XMLClass *) initXMLParser {
    //[super init];
    // init array of user objects
    //users = [[NSMutableArray alloc] init];
    return self;
}

+(NSString *) returnXMLTypeBySingleElement:(NSString *) element WithValue:(NSString *) value UseNewLine:(BOOL) newline
{
    NSString *sAns = [ NSString new];
    if (newline) {
        sAns = [NSString stringWithFormat:@"<%@>%@</%@>\n",element,value,element];
    } else {
        sAns = [NSString stringWithFormat:@"<%@>%@</%@>",element,value,element];
    }
    return sAns;
}

+(NSString *) OilDetailsToXMLForInsertByName:(NSString *) OilName CommonName:(NSString *) commonName BotanicalName:(NSString *) botName Ingredients:(NSString *) ingredients SafetyNotes:(NSString *) safetyNotes Color:(NSString *) color Viscosity:(NSString *) viscosity InStock:(NSString *) instock Vendor:(NSString *) vendor WebSite:(NSString *)website Description:(NSString *) description
{
    NSString *sOutput = [NSString new];
    BOOL doNewLine = YES;
    sOutput = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    //sOutput = [sOutput stringByAppendingString:@"<!DOCTYPE addresses SYSTEM \"oils.dtd\">\n"];
    sOutput = [sOutput stringByAppendingString:@"<oils>\n"];
    //sOutput = [sOutput stringByAppendingString:@"<Details>\n"];
    sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"Name" WithValue:OilName UseNewLine:doNewLine]];
    sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"commonName" WithValue:commonName UseNewLine:doNewLine]];
    sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"BotanicalName" WithValue:botName UseNewLine:doNewLine]];
    sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"ingredients" WithValue:ingredients UseNewLine:doNewLine]];
    sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"safetyNotes" WithValue:safetyNotes UseNewLine:doNewLine]];
    sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"color" WithValue:color UseNewLine:doNewLine]];
    sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"viscosity" WithValue:viscosity UseNewLine:doNewLine]];
    sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"instock" WithValue:instock UseNewLine:doNewLine]];
    sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"vendor" WithValue:vendor UseNewLine:doNewLine]];
    sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"website" WithValue:website UseNewLine:doNewLine]];
    sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"description" WithValue:description UseNewLine:doNewLine]];
    
    //sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"" WithValue: UseNewLine:doNewLine]];
    //sOutput = [sOutput stringByAppendingString:[NSString stringWithFormat:@"    <Name>%@</Name>\n",OilName]];
    //sOutput = [sOutput stringByAppendingString:[NSString stringWithFormat:@"    <commonName>%@</commonName>\n",commonName]];
    //sOutput = [sOutput stringByAppendingString:@"</Details>\n"];
    sOutput = [sOutput stringByAppendingString:@"</oils>\n"];
    return sOutput;
    
}

+(void) OpenFileFromAirDropbyPath:(NSString *) filePath
{
    //NSData *xmlDATA = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:filePath]];
    //NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:xmlDATA];
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *sAns = [docPath stringByAppendingPathComponent:@"OilDetails.meo"];
    
    //Parser *parser = [[Parser alloc] init];
    Parser *parser = [[Parser alloc] initWithDatabasePath:filePath AirDopPath:sAns];
    
    NSLog(@"NEW SHIT %@",parser.OilName);
    
     /*  Before the Use of the Parser.h class
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:filePath]];
    */
    //XMLClass *parser = [[XMLClass alloc] initXMLParser];
    //NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:filePath]];
    
    /*  Before the Use of the Parser.h class
    [xmlparser setDelegate:XMLClass.self];
    [xmlparser setDelegate:parser];
    BOOL success = [xmlparser parse];
    
    if (success) {
        NSLog(@"No errors");
        // get array of users here
        //  NSMutableArray *users = [parser users];
    } else {
        NSLog(@"Error parsing document!");
    }
     */
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    
    if ([elementName isEqualToString:@"rss"]) {
        marrXMLData = [[NSMutableArray alloc] init];
    }
    if ([elementName isEqualToString:@"item"]) {
        mdictXMLPart = [[NSMutableDictionary alloc] init];
    }
    
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
    
    if (!mstrXMLString) {
        mstrXMLString = [[NSMutableString alloc] initWithString:string];
    }
    else {
        [mstrXMLString appendString:string];
    }
    
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    if ([elementName isEqualToString:@"title"]
        || [elementName isEqualToString:@"pubDate"]) {
        [mdictXMLPart setObject:mstrXMLString forKey:elementName];
    }
    if ([elementName isEqualToString:@"item"]) {
        [marrXMLData addObject:mdictXMLPart];
    }
    mstrXMLString = nil;
}

@end
