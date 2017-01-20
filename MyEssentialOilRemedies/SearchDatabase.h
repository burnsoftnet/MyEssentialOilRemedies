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
#import "MySettings.h"
#import "FormFunctions.h"

@interface SearchDatabase : NSObject
@property (nonatomic,strong) NSString *SearchName;
@property (nonatomic,strong) NSString *SearchType;
@property (assign) int SearchID;
@property (nonatomic,strong) NSString *SearchContent;


-(NSMutableArray *) getAllSearchData:(NSString *) dbPath ErrorMessage:(NSString *) errorMsg;
-(NSMutableArray *) getAllSearchDataSimple:(NSString *) dbPath ErrorMessage:(NSString *) errorMsg;
-(NSInteger) isOilbyName:(NSString *) sValue databasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
-(NSInteger) isRemedybyName:(NSString *) sValue databasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
@end
