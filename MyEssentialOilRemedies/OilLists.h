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
@property (nonatomic,strong) NSString * _Nullable InStock;
@property (nonatomic,strong) NSString * _Nullable isBlend;
@property (nonatomic,strong) NSString * _Nullable name;
@property (nonatomic,strong) NSString * _Nullable mydescription;
@property (nonatomic,strong) NSString * _Nullable DetailsID;
@property (nonatomic,strong) NSString * _Nullable BotanicalName;
@property (nonatomic,strong) NSString * _Nullable Ingredients;
@property (nonatomic,strong) NSString * _Nullable SafetyNotes;
@property (nonatomic,strong) NSString * _Nullable Color;
@property (nonatomic,strong) NSString * _Nullable Viscosity;
@property (nonatomic,strong) NSString * _Nullable CommonName;
@property (nonatomic,strong) NSString * _Nullable RemedyName;
@property (nonatomic,strong) NSString * _Nullable IsReOrder;
@property (nonatomic,strong) NSString * _Nullable Vendor;
@property (nonatomic,strong) NSString * _Nullable VendorWebSite;
@property (assign) int RID;
@property (nonatomic,strong) NSString * _Nullable section;

#pragma mark Get List of Oils
-(NSMutableArray *_Nullable) getAllOilsList :(NSString *_Nonnull) dbPath : (NSString *_Nullable*) errorMsg;

#pragma mark Delete Oil
-(void) deleteOil :(NSString * _Nullable ) name :(NSString *_Nonnull) oid :(NSString *_Nonnull) dbPath :(NSString *_Nullable*) msg;

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
