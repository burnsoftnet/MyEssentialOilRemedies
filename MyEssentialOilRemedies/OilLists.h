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

#pragma mark Get List of Oils
//NOTE: This will Get the List of oils in the table and put them into an Array,
//      This returns the Name, Description, Stock Status, Oil ID and Details ID.
//USEDBY:
-(NSMutableArray *) getAllOilsList :(NSString *) dbPath : (NSString **) errorMsg;

#pragma mark Delete Oil
//NOTE:  This will delete the oil from the database
//USEDBY:  Oil List View
-(void) deleteOil :(NSString * ) name :(NSString *) oid :(NSString *) dbPath :(NSString **) msg;

#pragma mark Update Stock Status
//NOTE: This will update the oil Stock status, pass the new value In-Stock=1, Out-Of-Stock-0
//USEDBY: Oil List View
-(void) updateStockStatus :(NSString *) newValue OilID:(NSString *) myOID DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;

#pragma mark Get Remedies that Contain Oil
//Gets the list of Remedies that have the oil listed in the Oils to remedy table, this does not include anything in the uses and description sections
-(NSMutableArray *) getRemediesRelatedToOilID :(NSString *) oilID DatabasePath: (NSString *) dbPath ErrorMessage:(NSString **) errorMsg;

#pragma mark "Oil Exists By Name
// Look up the oil by name to see if it already exists in the database, if it doesn't return NO, else yes
-(BOOL) oilExistsByName:(NSString *) oilname DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;

#pragma mark Get InStock Count from Database
//Function that will return all the oils marked as instock form the datbase
//USEDBY: listInStock
-(int) getInStockCountByDatabase :(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;

#pragma mark List In Stock
//method version of the get instockcountbydatabase
+(int) listInStock:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;

#pragma mark Get Oil ID by Name
//Get the Oil ID by name, if it will check to see if it exists, if not, it will attempt to insert it and return the ID of that name.
+(NSNumber *) getOilIDByName:(NSString *) name InStock:(int) iStock DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **) msg;

#pragma mark Insert Oil Details
//Insert the Oil Details if sucessful then it will return true, else false if there was a problem with the insert
+(BOOL) insertOilDetailsByOID:(NSNumber *) MYOID Description:(NSString *) description BotanicalName:(NSString *) BotName Ingredients:(NSString *) ingredients SafetyNotes:(NSString *) safetyNotes Color:(NSString *) color Viscosity:(NSString *) viscosity CommonName:(NSString *) commonName Vendor:(NSString *) vendor WebSite:(NSString *) website Blended:(NSString *) isBlend DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString *_Nullable*) msg;

#pragma mark Update Oil Details
//Update the Oil Details if sucessful then it will return true, else false if there was a problem with the insert
+(BOOL) updateOilDetailsByOID:(NSNumber *) MYOID Description:(NSString *) description BotanicalName:(NSString *) BotName Ingredients:(NSString *) ingredients SafetyNotes:(NSString *) safetyNotes Color:(NSString *) color Viscosity:(NSString *) viscosity CommonName:(NSString *) commonName Vendor:(NSString *) vendor WebSite:(NSString *) website IsBlend:(NSString *) isblend DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString *_Nullable*) msg;
#pragma mark Get Oils for Re-Order
// Get the list of oils that are marked for reOrder.
- (NSMutableArray *) getOilsForReOrder: (NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
#pragma mark Count all the items marked to reorder
//  Get a count of all the oils that are marked for order or re-order
+(int) listInShopping:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
@end
