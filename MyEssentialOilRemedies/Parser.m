//
//  Parser.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 4/28/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import "Parser.h"

@implementation Parser
#pragma mark Initizlie Oils with XML File
//intialize the Oils with a pre set File and Path
//Mostly used for testing, but you can also set the Directory/InBox to the path to use for production
-initOils {
    if(self == [super init]) {
        
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [path objectAtIndex:0];
        NSString *fullDocPath = [docPath stringByAppendingPathComponent:@"OilDetails.meo"];
        //NSString *fullDocPath = [docPath stringByAppendingPathComponent:@"/InBox/OilDetails.meo"];
        
        //sqlResults = @"";
        NSURL *dataFile = [NSURL fileURLWithPath:fullDocPath];
        parser = [[NSXMLParser alloc] initWithContentsOfURL:dataFile];
        [parser setDelegate:self];
        [parser parse];
    }      
    return self;
}

#pragma mark Initizlie Remedy with XML File
//intialize the Remedy with a pre set File and Path
//Mostly used for testing, but you can also set the Directory/InBox to the path to use for production
-initRemedy {
    if(self == [super init]) {
        
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [path objectAtIndex:0];
        NSString *fullDocPath = [docPath stringByAppendingPathComponent:@"RemedyDetails.meor"];
        //NSString *fullDocPath = [docPath stringByAppendingPathComponent:@"/InBox/RemedyDetails.meor"];
        
        //sqlResults = @"";
        NSURL *dataFile = [NSURL fileURLWithPath:fullDocPath];
        parser = [[NSXMLParser alloc] initWithContentsOfURL:dataFile];
        [parser setDelegate:self];
        [parser parse];
    }
    return self;
}


#pragma mark Initizlies with XML File
//Pass the Path of the file to process to intialize the class
-initWithXMLFile:(NSString *) docPath
{
    NSURL *dataFile = [NSURL fileURLWithPath:docPath];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:dataFile];
    _Remedy_Oils = [NSMutableArray new];
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
        self.dataType = @"remedy";
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
    
    if (_isREMEDY) {
        [self setRemedySQLDetailsByColumn:elementName MyValue:element];
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

#pragma mark Set the Class Varable related to Remedies
//Set the Class Global Variables to the values that is in the XML dataset to be used outside of this class
//This is a Private Sub
-(void) setRemedySQLDetailsByColumn:(NSString *) colName MyValue:(NSString *) myValue
{
    if([colName isEqualToString:@"RemedyName"]){
        _Remedy_Name = myValue;
    }
    
    if([colName isEqualToString:@"description"]){
        _Remedy_Description = myValue;
    }
    
    if([colName isEqualToString:@"uses"]){
        _Remedy_Uses = myValue;
    }
    
    if([colName isEqualToString:@"OilName"]){
        [_Remedy_Oils addObject:myValue];
    }
}

#pragma mark Set the Class Varable related to oils
//Set the Class Global Variables to the values that is in the XML dataset to be used outside of this class
//This is a Private Sub
-(void) setOilSQLDetailsbyColumn:(NSString *) colName MyValue:(NSString *) myValue
{
    
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
//A simple Private class to help format the XML Elements as needed for XML Files.
//You are able to pass the ablity to create a new line for the format or not by setting the newline variable
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
//Format the values passed to this function to be put into XML Format for Oils
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

#pragma mark Format Data from Remedies to XML
//Format the values passed to this function to be put into XML Format for Remedies
+(NSString *) RemedyDetailsToXMLforInsertByName:(NSString *) remedyName Description:(NSString *) description HowToUse:(NSString *) uses Oils:(NSArray *) oils
{
    NSString *sOutput = [NSString new];
    BOOL doNewLine = NO;
    sOutput = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    sOutput = [sOutput stringByAppendingString:@"<remedy>\n"];
    
    sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"RemedyName" WithValue:remedyName UseNewLine:doNewLine]];
    sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"description" WithValue:description UseNewLine:doNewLine]];
    sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"uses" WithValue:uses UseNewLine:doNewLine]];
    
    sOutput = [sOutput stringByAppendingString:@"<oilList>\n"];
    for (int x = 0; x < [oils count]; x++) {
        sOutput = [sOutput stringByAppendingString:[self returnXMLTypeBySingleElement:@"OilName" WithValue:oils[x] UseNewLine:doNewLine]];
    }
    sOutput = [sOutput stringByAppendingString:@"</oilList>\n"];
    
    sOutput = [sOutput stringByAppendingString:@"</remedy>\n"];
    return sOutput;
}

@end
