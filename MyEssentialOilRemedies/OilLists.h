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

-(NSMutableArray *) getOilNameOnly :(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
-(NSMutableArray *) getAllOilsList :(NSString *) dbPath : (NSString **) errorMsg;
-(NSMutableArray *) getInStockOilsList :(NSString *) dbPath : (NSString **) errorMsg;
-(NSMutableArray *) getOutOfStockOilsList :(NSString *) dbPath : (NSString **) errorMsg;
-(void) deleteOil :(NSString * ) name :(NSString *) oid :(NSString *) dbPath :(NSString **) msg;
-(void) updateStockStatus :(NSString *) newValue OilID:(NSString *) myOID DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;

@end
