//
//  SearchDatabase.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 9/23/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "BurnSoftDatabase.h"
#import "MYSettings.h"
#import "FormFunctions.h"
#import "OilLists.h"

@interface SearchDatabase : NSObject
@property (nonatomic,strong) NSString *SearchName;
@property (nonatomic,strong) NSString *SearchDescription;
@property (nonatomic,strong) NSString *SearchType;
@property (assign) int SearchID;
@property (nonatomic,strong) NSString *SearchContent;

#pragma mark Get All Search Data
//Public Function that will combine the searchAllOilsAllData and searchAllRemediesAllData Private function into one array.
-(NSMutableArray *) getAllSearchData:(NSString *) dbPath ErrorMessage:(NSString *) errorMsg;

#pragma mark Get All Search Data Simple
//Public Function that will combine the searchAllOilsListSimple and the SearchAllRemediesSimple Private functions into one array.
-(NSMutableArray *) getAllSearchDataSimple:(NSString *) dbPath ErrorMessage:(NSString *) errorMsg;

#pragma mark Get Oil ID by Name
/*
 Public Function that will return the ID of the oil in the database if it is found in the database.
 This is mostly used in the search function since the display is not based on Object ID but by name so
 we need to figure out if it is an oil or a remedy since both the results are combined.
 If 0 if returned then it is something that is not in the Oil Database by that name.
 */
-(NSInteger) isOilbyName:(NSString *) sValue databasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;

#pragma mark Get Remedy ID by Name
/*
 Public Function that will return the ID of the Remedy in the database if it is found in the database.
 This is mostly used in the search function since the display is not based on Object ID but by name so
 we need to figure out if it is an oil or a remedy since both the results are combined.
 If 0 is returned then it is something that is not in the Remedy Database by that name.
 */
-(NSInteger) isRemedybyName:(NSString *) sValue databasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
@end
