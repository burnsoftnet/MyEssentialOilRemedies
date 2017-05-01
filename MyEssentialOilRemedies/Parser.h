//
//  Parser.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 4/28/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OilLists.h"

@interface Parser : NSObject <NSXMLParserDelegate>
{
    NSXMLParser *parser;
    NSMutableString *element;
    NSString *sqlResults;
}

@property (strong, nonatomic) NSString *databasePath;
@property (strong, nonatomic) NSString *appPath;
@property (strong, nonatomic) NSString *OilName;
@property (strong, nonatomic) NSString *RemedyName;
@property (strong, nonatomic) NSString *dataType;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

-initWithDatabasePath:(NSString *) dbPath AirDopPath:(NSString *) docPath;

@end
