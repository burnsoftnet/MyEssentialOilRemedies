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
-(NSMutableArray *) getAllSearchData:(NSString *) dbPath ErrorMessage:(NSString *) errorMsg;

#pragma mark Get All Search Data Simple
-(NSMutableArray *) getAllSearchDataSimple:(NSString *) dbPath ErrorMessage:(NSString *) errorMsg;

#pragma mark Get Oil ID by Name
-(NSInteger) isOilbyName:(NSString *) sValue databasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;

#pragma mark Get Remedy ID by Name
-(NSInteger) isRemedybyName:(NSString *) sValue databasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
@end
