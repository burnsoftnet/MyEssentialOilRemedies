//
//  Parser.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 4/28/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import "Parser.h"

@implementation Parser

-init {
    if(self == [super init]) {
        
        //This Path is great for testing, but when you send it via airdrop, it will put in the the Docuents Directory/InBox
        
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [path objectAtIndex:0];
        NSString *sAns = [docPath stringByAppendingPathComponent:@"OilDetails.meo"];
        
        sqlResults = @"";
        NSURL *dataFile = [NSURL fileURLWithPath:sAns];
        //parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"OilDetails" ofType: @"oil"]]];
        parser = [[NSXMLParser alloc] initWithContentsOfURL:dataFile];
        [parser setDelegate:self];
        [parser parse];
    }      
    return self;
}

#pragma mark Initizlies with XML File
-initWithXMLFile:(NSString *) docPath
{
    NSURL *dataFile = [NSURL fileURLWithPath:docPath];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:dataFile];
    [parser setDelegate:self];
    [parser parse];
    return  self;

}
#pragma mark Paser Did Start
//Get the Elemenents from the XML Data source
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
{
    //TODO: Get rid of log or put in debug mode
    NSLog(@"Started Element %@", elementName);
    
    element = [NSMutableString string];
    
    if ([elementName isEqualToString:@"oils"]) {
        _isOIL = YES;
        _isREMEDY = NO;
        self.dataType = @"oil";
    } else if([elementName isEqualToString:@"remedy"]){
       _isREMEDY  = YES;
        _isOIL = NO;
        self.dataType = @"oil";
    }
}

#pragma mark Parser Did End
//find the end of the elemenent and display the value of that element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //Currently processing information and will need to use this information to make the insert details
     //TODO: Get rid of log or put in debug mode
    NSLog(@"Found an element named: %@ with a value of: %@", elementName, element);
    if ( _isOIL) {
        [self setOilSQLDetailsbyColumn:elementName MyValue:element];
    }
}

#pragma mark Parser Found Characters
//Append to string when a value was found
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(element == nil) {

        element = [[NSMutableString alloc] init];

        [element appendString:string];
    } else {
        [element appendString:string];
    }
}

-(void) setOilSQLDetailsbyColumn:(NSString *) colName MyValue:(NSString *) myValue
{
    //YOU ARE GOING TO HAVE TO Pass everythin Back through strings, since you need to alert if the oil already exists or not.

    
    if ([colName isEqualToString:@"Name"]) {
        _Oil_Name = myValue;
    }
    
    if([colName isEqualToString:@"commonName"]){
        _Oil_CommonName = myValue;
    }
    if([colName isEqualToString:@"BotanicalName"]){
        _Oil_BotanicalName = myValue;
    }
    if([colName isEqualToString:@"ingredients"]){
        _Oil_Ingredients = myValue;
    }
    if([colName isEqualToString:@"safetyNotes"]){
        _Oil_SafetyNotes = myValue;
    }
    if([colName isEqualToString:@"color"]){
        _Oil_Color = myValue;
    }
    if([colName isEqualToString:@"viscosity"]){
        _Oil_Viscosity = myValue;
    }
    if([colName isEqualToString:@"instock"]){
        _Oil_InStock = myValue;
    }
    if([colName isEqualToString:@"vendor"]){
        _Oil_vendor = myValue;
    }
    if([colName isEqualToString:@"website"]){
        _Oil_website= myValue;
    }
    if([colName isEqualToString:@"description"]){
        _Oil_description = myValue;
    }
    
    //if([colName isEqualToString:@""]){
    //
    //}
}

#pragma mark Return XML Type Single Element
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

#pragma mark Format Data for Oils to XML
+(NSString *) OilDetailsToXMLForInsertByName:(NSString *) OilName CommonName:(NSString *) commonName BotanicalName:(NSString *) botName Ingredients:(NSString *) ingredients SafetyNotes:(NSString *) safetyNotes Color:(NSString *) color Viscosity:(NSString *) viscosity InStock:(NSString *) instock Vendor:(NSString *) vendor WebSite:(NSString *)website Description:(NSString *) description
{
    NSString *sOutput = [NSString new];
    BOOL doNewLine = NO;
    sOutput = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    sOutput = [sOutput stringByAppendingString:@"<oils>\n"];
    
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
    
    sOutput = [sOutput stringByAppendingString:@"</oils>\n"];
    return sOutput;
    
}


@end
