//
//  OilLists.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "BurnSoftDatabase.h"
#import "BurnSoftGeneral.h"

@interface OilLists : NSObject
@property (assign) int OID;
@property (nonatomic,strong) NSString *InStock;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *mydescription;
@property (nonatomic,strong) NSString *DetailsID;
@property (nonatomic,strong) NSString *BotanicalName;
@property (nonatomic,strong) NSString *Ingredients;
@property (nonatomic,strong) NSString *SafetyNotes;
@property (nonatomic,strong) NSString *Color;
@property (nonatomic,strong) NSString *Viscosity;
@property (nonatomic,strong) NSString *CommonName;
@property (nonatomic,strong) NSString *RemedyName;
@property (assign) int RID;

-(NSMutableArray *) getOilNameOnly :(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
-(NSMutableArray *) getAllOilsList :(NSString *) dbPath : (NSString **) errorMsg;
-(NSMutableArray *) getInStockOilsList :(NSString *) dbPath : (NSString **) errorMsg;
-(NSMutableArray *) getOutOfStockOilsList :(NSString *) dbPath : (NSString **) errorMsg;
-(void) deleteOil :(NSString * ) name :(NSString *) oid :(NSString *) dbPath :(NSString **) msg;
-(void) updateStockStatus :(NSString *) newValue OilID:(NSString *) myOID DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
-(NSMutableArray *) getRemediesRelatedToOilID :(NSString *) oilID DatabasePath: (NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
-(BOOL) oilExistsByName:(NSString *) oilname DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
-(int) getInStockCountByDatabase :(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
+(int) listInStock:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
#pragma mark Get Oil ID by Name
//Get the Oil ID by name, if it will check to see if it exists, if not, it will attempt to insert it and return the ID of that name.
+(NSNumber *) getOilIDByName:(NSString *) name InStock:(int) iStock DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg;
#pragma mark Insert Oil Details
//Insert the Oil Details if sucessful then it will return true, else false if there was a problem with the insert
+(BOOL) insertOilDetailsByOID:(NSNumber *) MYOID Description:(NSString *) description BotanicalName:(NSString *) BotName Ingredients:(NSString *) ingredients SafetyNotes:(NSString *) safetyNotes Color:(NSString *) color Viscosity:(NSString *) viscosity CommonName:(NSString *) commonName Vendor:(NSString *) vendor WebSite:(NSString *) website DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg;
#pragma mark Update Oil Details
//Update the Oil Details if sucessful then it will return true, else false if there was a problem with the insert
+(BOOL) updateOilDetailsByOID:(NSNumber *) MYOID Description:(NSString *) description BotanicalName:(NSString *) BotName Ingredients:(NSString *) ingredients SafetyNotes:(NSString *) safetyNotes Color:(NSString *) color Viscosity:(NSString *) viscosity CommonName:(NSString *) commonName Vendor:(NSString *) vendor WebSite:(NSString *) website DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg;

@end
