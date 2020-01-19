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
#import "FormFunctions.h"

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
-(NSMutableArray *_Nullable) getAllOilsList :(NSString *_Nonnull) dbPath : (NSString *_Nullable*_Nullable) errorMsg;

#pragma mark Delete Oil
-(void) deleteOil :(NSString * _Nullable ) name :(NSString *_Nonnull) oid :(NSString *_Nonnull) dbPath :(NSString *_Nullable*_Nullable) msg;

#pragma mark Update Stock Status
-(void) updateStockStatus :(NSString *_Nonnull) newValue OilID:(NSString *_Nonnull) myOID DatabasePath:(NSString *_Nullable) dbPath ErrorMessage:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark Get Remedies that Contain Oil
-(NSMutableArray *_Nullable) getRemediesRelatedToOilID :(NSString *_Nonnull) oilID DatabasePath:(NSString *_Nonnull) dbPath ErrorMessage:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark Oil Exists By Name
-(BOOL) oilExistsByName:(NSString *_Nullable) oilname DatabasePath:(NSString *_Nonnull) dbPath ErrorMessage:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark Get Oil Name by ID
-(NSString *_Nullable) getOilNameByID:(int) oid DatabasePath:dbPathString ErrorMessage:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark Get InStock Count from Database
-(int) getInStockCountByDatabase :(NSString *_Nonnull) dbPath ErrorMessage:(NSString *_Nullable*_Nullable) errorMsg;
+(int) getInStockCountByArray:(NSMutableArray *_Nonnull) myList ErrorMessage:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark List In Stock
+(int) listInStock:(NSString *_Nonnull) dbPath ErrorMessage:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark List Things to Order Array
+(int) listInShoppingByArray:(NSMutableArray *_Nonnull) myList ErrorMessage:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark Get Oil ID by Name
+(NSNumber *_Nullable) getOilIDByName:(NSString *_Nonnull) name InStock:(int) iStock DatabasePath:(NSString *_Nullable) dbPathString ErrorMessage:(NSString *_Nullable*_Nullable) msg;

#pragma mark Insert Oil Details
+(BOOL) insertOilDetailsByOID:(NSNumber *_Nonnull) MYOID Description:(NSString *_Nullable) description BotanicalName:(NSString *_Nullable) BotName Ingredients:(NSString *_Nullable) ingredients SafetyNotes:(NSString *_Nullable) safetyNotes Color:(NSString *_Nullable) color Viscosity:(NSString *_Nullable) viscosity CommonName:(NSString *_Nullable) commonName Vendor:(NSString *_Nullable) vendor WebSite:(NSString *_Nullable) website Blended:(NSString *_Nullable) isBlend DatabasePath:(NSString *_Nullable) dbPathString ErrorMessage:(NSString *_Nullable*_Nullable) msg;

#pragma mark Update Oil Details
+(BOOL) updateOilDetailsByOID:(NSNumber *_Nullable) MYOID Description:(NSString *_Nullable) description BotanicalName:(NSString *_Nullable) BotName Ingredients:(NSString *_Nullable) ingredients SafetyNotes:(NSString *_Nullable) safetyNotes Color:(NSString *_Nullable) color Viscosity:(NSString *_Nullable) viscosity CommonName:(NSString *_Nullable) commonName Vendor:(NSString *_Nullable) vendor WebSite:(NSString *_Nullable) website IsBlend:(NSString *_Nullable) isblend DatabasePath:(NSString *_Nullable) dbPathString ErrorMessage:(NSString *_Nullable*_Nullable) msg;
#pragma mark Get Oils for Re-Order
- (NSMutableArray *_Nullable) getOilsForReOrder: (NSString *_Nullable) dbPath ErrorMessage:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark Count all the items marked to reorder
+(int) listInShopping:(NSString *_Nullable) dbPath ErrorMessage:(NSString *_Nullable*_Nullable) errorMsg;

#pragma mark UPdate Blend Status
+(void) updateBlendStatusWithNewValue:(NSString *_Nullable) newValue OilID:(NSString *_Nullable) myOID DatabasePath:(NSString *_Nullable) dbPath ErrorMessage:(NSString *_Nullable*_Nullable) errorMsg;
@end
