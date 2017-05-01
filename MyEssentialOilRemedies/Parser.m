//
//  Parser.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 4/28/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import "Parser.h"

@implementation Parser
{
    BOOL isOil;
    BOOL isRemedy;
    NSString *sqlColumns;
    NSString *sqlValues;
}
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


-initWithDatabasePath:(NSString *) dbPath AirDopPath:(NSString *) docPath
{
    self.databasePath = dbPath;
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
        isOil = YES;
        isRemedy = NO;
        self.dataType = @"oil";
    } else if([elementName isEqualToString:@"remedy"]){
        isRemedy = YES;
        isOil = NO;
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
    if (isOil) {
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
    NSString *errMsg = [NSString new];
    
    //YOU ARE GOING TO HAVE TO Pass everythin Back through strings, since you need to alert if the oil already exists or not.
    
    
    if ([colName isEqualToString:@"Name"]) {
        _OilName = myValue;
        //OilLists *myObj = [OilLists new];
        //if ([myObj oilExistsByName:myValue DatabasePath:_databasePath ErrorMessage:&errMsg]){
        //    NSLog(@"Oil Exists!");
        //} else {
         //   NSLog(@"Oil Does not Exist!");
        //}
    }
}

@end
