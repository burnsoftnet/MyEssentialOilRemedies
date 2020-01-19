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
#import "FormFunctions.h"

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
-(BOOL) RemedyExistsByName:(NSString *_Nullable) oilname DatabasePath:(NSString *_Nullable) dbPath ErrorMessage:(NSString *_Nullable*_Nullable) errorMsg;
#pragma mark Get all Oils for Remedy
-(NSMutableArray *_Nullable) getAllOilfForremedyByRID:(NSString *_Nullable) RID DatabasePath:(NSString *_Nullable) dbPathString ErrorMessage:(NSString *_Nullable*_Nullable)errorMsg;

#pragma mark Get all Oils for Remedy Name Only
-(NSMutableArray *_Nullable) getAllOilfForremedyByRIDNameOnly:(NSString *_Nullable) RID DatabasePath:(NSString *_Nullable) dbPathString ErrorMessage:(NSString *_Nullable*_Nullable)errorMsg;

#pragma mark Get a List of all Remedies Name Only
-(NSMutableArray *_Nullable) getAllRemedies :(NSString *_Nullable) dbPathString : (NSString *_Nullable*_Nullable) errorMsg;

-(BOOL) oilNameExists:(NSString *_Nullable) lookforoilname DatabasePath:(NSString *_Nullable)dbPathString ERRORMESSAGE:(NSString *_Nullable*_Nullable)errorMsg;

#pragma mark Add Oil to Database
-(NSString *_Nullable)AddOilName :(NSString *_Nullable) myoilname DatabasePath:(NSString *_Nullable)dbPathString ERRORMESSAGE:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark Add Oil to remedy Oil List
-(void) addOilToremedyOilList:(NSString *_Nullable) oilID RID:(NSString *_Nullable) RemedyID DatabasePath:(NSString *_Nullable) dbPathString ERRORMESSAGE:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark Add Remedy to Database
-(NSString *_Nullable)AddRemedyDetailsByName:(NSString *_Nullable) RemedyName Description:(NSString *_Nullable) myDescription Uses:(NSString *_Nullable) myUses DatabasePath:(NSString *_Nullable) dbPathString ERRORMESSAGE:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark Delete Remedy
-(BOOL) deleteRemedyByID:(NSString *_Nullable)RID DatabasePath:(NSString *_Nullable) dbPathString MessageHandler:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark Delete Related Links of Oils by Remedy ID
-(BOOL) ClearOilsPerRemedyByRID:(NSString *_Nullable) RID DatabasePath:(NSString *_Nullable) dbPathString MessageHandler:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark Update Remedy Details by RID
-(BOOL) updateRemedyDetailsByRID:(NSString *_Nullable) RID Name:(NSString *_Nullable) RemedyName Description:(NSString *_Nullable) myDescription Uses:(NSString *_Nullable) myUses DatabasePath:(NSString *_Nullable) dbPathString ERRORMESSAGE:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark Get Remedy ID By Name
+(NSNumber *_Nullable) getRemedyIDByName:(NSString *_Nullable) Remedyname DatabasePath:(NSString *_Nullable) dbPath ErrorMessage:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark Add Oils to Remedy
-(void) addOilsToRemedyByRemedyID:(NSString *_Nullable) RID OilsArray:(NSArray *_Nullable) oilList DatabasePath:(NSString *_Nullable) dbpath ErrorMessage:(NSString *_Nullable*_Nullable) ErrMsg;

@end
