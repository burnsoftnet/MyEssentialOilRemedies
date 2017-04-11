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

@property (nonatomic,strong) NSString *name;            //Name of Remedy
@property (nonatomic,strong) NSString *myDescription;   //Remedy Description
@property (nonatomic,strong) NSString *myUses;          //Remedy Uses

@property (nonatomic,strong) NSString *oilName;         //Oil Name
@property (nonatomic,strong) NSString *oilDeescription; //Oilk Description
@property (nonatomic,strong) NSString *oilInStock;      //Do i Have this oil in Stock?

-(BOOL) RemedyExistsByName:(NSString *) oilname DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
-(NSMutableArray *) getAllOilfForremedyByRID:(NSString *) RID DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **)errorMsg;
-(NSMutableArray *) getAllOilfForremedyByRIDNameOnly:(NSString *) RID DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **)errorMsg;
-(NSMutableArray *) getAllRemedies :(NSString *) dbPathString : (NSString **) errorMsg;
-(BOOL) oilNameExists:(NSString *) lookforoilname DatabasePath:(NSString *)dbPathString ERRORMESSAGE:(NSString **)errorMsg;
-(NSString *)AddOilName :(NSString *) myoilname DatabasePath:(NSString *)dbPathString ERRORMESSAGE:(NSString **) errorMsg;
-(void) addOilToremedyOilList:(NSString *) oilID RID:(NSString *) RemedyID DatabasePath:(NSString *) dbPathString ERRORMESSAGE:(NSString **) errorMsg;
-(NSString *)AddRemedyDetailsByName:(NSString *) RemedyName Description:(NSString *) myDescription Uses:(NSString *) myUses DatabasePath:(NSString *) dbPathString ERRORMESSAGE:(NSString **) errorMsg;
-(BOOL) deleteRemedyByID:(NSString *)RID DatabasePath:(NSString *) dbPathString MessageHandler:(NSString **) errorMsg;
-(BOOL) ClearOilsPerRemedyByRID:(NSString *) RID DatabasePath:(NSString *) dbPathString MessageHandler:(NSString **) errorMsg;
-(BOOL) updateRemedyDetailsByRID:(NSString *) RID Name:(NSString *) RemedyName Description:(NSString *) myDescription Uses:(NSString *) myUses DatabasePath:(NSString *) dbPathString ERRORMESSAGE:(NSString **) errorMsg;
@end
