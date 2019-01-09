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
@property (nonatomic,strong) NSString *isBlend;
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
@property (nonatomic,strong) NSString *IsReOrder;
@property (nonatomic,strong) NSString *Vendor;
@property (nonatomic,strong) NSString *VendorWebSite;
@property (assign) int RID;
@property (nonatomic,strong) NSString *section;

#pragma mark Get List of Oils
-(NSMutableArray *) getAllOilsList :(NSString *) dbPath : (NSString **) errorMsg;

#pragma mark Delete Oil
-(void) deleteOil :(NSString * ) name :(NSString *) oid :(NSString *) dbPath :(NSString **) msg;

#pragma mark Update Stock Status
-(void) updateStockStatus :(NSString *) newValue OilID:(NSString *) myOID DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;

#pragma mark Get Remedies that Contain Oil
-(NSMutableArray *) getRemediesRelatedToOilID :(NSString *) oilID DatabasePath: (NSString *) dbPath ErrorMessage:(NSString **) errorMsg;

#pragma mark "Oil Exists By Name
-(BOOL) oilExistsByName:(NSString *) oilname DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;

-(NSString *) getOilNameByID:(int) oid DatabasePath:dbPathString ErrorMessage:(NSString *_Nullable*) errorMsg;
#pragma mark Get InStock Count from Database
-(int) getInStockCountByDatabase :(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
+(int) getInStockCountByArray:(NSMutableArray *) myList ErrorMessage:(NSString **) errorMsg;

#pragma mark List In Stock
+(int) listInStock:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
+(int) listInShoppingByArray:(NSMutableArray *) myList ErrorMessage:(NSString **) errorMsg;

#pragma mark Get Oil ID by Name
+(NSNumber *) getOilIDByName:(NSString *) name InStock:(int) iStock DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg;

#pragma mark Insert Oil Details
+(BOOL) insertOilDetailsByOID:(NSNumber *) MYOID Description:(NSString *) description BotanicalName:(NSString *) BotName Ingredients:(NSString *) ingredients SafetyNotes:(NSString *) safetyNotes Color:(NSString *) color Viscosity:(NSString *) viscosity CommonName:(NSString *) commonName Vendor:(NSString *) vendor WebSite:(NSString *) website Blended:(NSString *) isBlend DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString *_Nullable*) msg;

#pragma mark Update Oil Details
+(BOOL) updateOilDetailsByOID:(NSNumber *) MYOID Description:(NSString *) description BotanicalName:(NSString *) BotName Ingredients:(NSString *) ingredients SafetyNotes:(NSString *) safetyNotes Color:(NSString *) color Viscosity:(NSString *) viscosity CommonName:(NSString *) commonName Vendor:(NSString *) vendor WebSite:(NSString *) website IsBlend:(NSString *) isblend DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString *_Nullable*) msg;
#pragma mark Get Oils for Re-Order
- (NSMutableArray *) getOilsForReOrder: (NSString *) dbPath ErrorMessage:(NSString **) errorMsg;

#pragma mark Count all the items marked to reorder
+(int) listInShopping:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;

#pragma mark UPdate Blend Status
+(void) updateBlendStatusWithNewValue:(NSString *) newValue OilID:(NSString *) myOID DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
@end
