//
//  OilRemedies.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "BurnSoftDatabase.h"
#import "BurnSoftGeneral.h"

@interface OilRemedies : NSObject
@property (assign) int OID;     //Oil ID
@property (assign) int RID;     //Remedy ID
@property (assign) int ORID;    //Oil to Remedy ID
@property (nonatomic, strong) NSString * _Nullable section;

@property (nonatomic,strong) NSString * _Nullable name;            //Name of Remedy
@property (nonatomic,strong) NSString * _Nullable myDescription;   //Remedy Description
@property (nonatomic,strong) NSString * _Nullable myUses;          //Remedy Uses

@property (nonatomic,strong) NSString * _Nullable oilName;         //Oil Name
@property (nonatomic,strong) NSString * _Nullable oilDeescription; //Oilk Description
@property (nonatomic,strong) NSString * _Nullable oilInStock;      //Do i Have this oil in Stock?

#pragma mark Remedy Exists By Name
-(BOOL) RemedyExistsByName:(NSString *) oilname DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
#pragma mark Get all Oils for Remedy
-(NSMutableArray *) getAllOilfForremedyByRID:(NSString *) RID DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **)errorMsg;

#pragma mark Get all Oils for Remedy Name Only
-(NSMutableArray *) getAllOilfForremedyByRIDNameOnly:(NSString *) RID DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **)errorMsg;

#pragma mark Get a List of all Remedies Name Only
-(NSMutableArray *) getAllRemedies :(NSString *) dbPathString : (NSString **) errorMsg;

-(BOOL) oilNameExists:(NSString *) lookforoilname DatabasePath:(NSString *)dbPathString ERRORMESSAGE:(NSString **)errorMsg;

#pragma mark Add Oil to Database
-(NSString *)AddOilName :(NSString *) myoilname DatabasePath:(NSString *)dbPathString ERRORMESSAGE:(NSString **) errorMsg;

#pragma mark Add Oil to remedy Oil List
-(void) addOilToremedyOilList:(NSString *) oilID RID:(NSString *) RemedyID DatabasePath:(NSString *) dbPathString ERRORMESSAGE:(NSString **) errorMsg;

#pragma mark Add Remedy to Database
-(NSString *)AddRemedyDetailsByName:(NSString *) RemedyName Description:(NSString *) myDescription Uses:(NSString *) myUses DatabasePath:(NSString *) dbPathString ERRORMESSAGE:(NSString **) errorMsg;

#pragma mark Delete Remedy
-(BOOL) deleteRemedyByID:(NSString *)RID DatabasePath:(NSString *) dbPathString MessageHandler:(NSString **) errorMsg;

#pragma mark Delete Related Links of Oils by Remedy ID
-(BOOL) ClearOilsPerRemedyByRID:(NSString *) RID DatabasePath:(NSString *) dbPathString MessageHandler:(NSString **) errorMsg;

#pragma mark Update Remedy Details by RID
-(BOOL) updateRemedyDetailsByRID:(NSString *) RID Name:(NSString *) RemedyName Description:(NSString *) myDescription Uses:(NSString *) myUses DatabasePath:(NSString *) dbPathString ERRORMESSAGE:(NSString **) errorMsg;

#pragma mark Get Remedy ID By Name
+(NSNumber *) getRemedyIDByName:(NSString *) Remedyname DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;

#pragma mark Add Oils to Remedy
-(void) addOilsToRemedyByRemedyID:(NSString *) RID OilsArray:(NSArray *) oilList DatabasePath:(NSString *) dbpath ErrorMessage:(NSString **) ErrMsg;

@end
