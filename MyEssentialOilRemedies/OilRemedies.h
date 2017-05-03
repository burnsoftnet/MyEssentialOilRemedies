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

#pragma mark Remedy Exists By Name
// Look up the Remedy by name to see if it already exists in the database, if it doesn't return NO, else yes
-(BOOL) RemedyExistsByName:(NSString *) oilname DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;
#pragma mark Get all Oils for Remedy
//NOTE: Array to get all the oils needed that have been tagged for a remedy based on the Remedy ID.
//USEDFOR: View Remedies, Edit Remedies
-(NSMutableArray *) getAllOilfForremedyByRID:(NSString *) RID DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **)errorMsg;

#pragma mark Get all Oils for Remedy Name Only
//NOTE: Array to get all the oils needed that have been tagged for a remedy based on the Remedy ID.
//USEDFOR: View Edit Remedies
-(NSMutableArray *) getAllOilfForremedyByRIDNameOnly:(NSString *) RID DatabasePath:(NSString *) dbPathString ErrorMessage:(NSString **)errorMsg;

#pragma mark Get a List of all Remedies Name Only
//NOTE: Array to get all the Remedies.
//USEDFOR: List, Edit remedy
-(NSMutableArray *) getAllRemedies :(NSString *) dbPathString : (NSString **) errorMsg;
-(BOOL) oilNameExists:(NSString *) lookforoilname DatabasePath:(NSString *)dbPathString ERRORMESSAGE:(NSString **)errorMsg;

#pragma mark Add Oil to Database
//NOTE:This will add the Oil to the Database, but it will check first to see if the oil is already in the database before adding, if it does exist, then it will get the oil ID to add to the remediy oil relations table.
//USEDFOR:  Add New Remedy, or Edit Remedy
-(NSString *)AddOilName :(NSString *) myoilname DatabasePath:(NSString *)dbPathString ERRORMESSAGE:(NSString **) errorMsg;

#pragma mark Add Oil to remedy Oil List
//NOTE: This works with AddOilName by the ID that is returned to add to the Remedy oil List relations table.
//USEDFOR:  Add New Remedy, or Edit Remedy
-(void) addOilToremedyOilList:(NSString *) oilID RID:(NSString *) RemedyID DatabasePath:(NSString *) dbPathString ERRORMESSAGE:(NSString **) errorMsg;

#pragma mark Add Remedy to Database
//NOTE:  This will add the remedy to the database and Returnt he Remedy ID
//USEDBY: tbSave Action in Remedy Edit and Add
-(NSString *)AddRemedyDetailsByName:(NSString *) RemedyName Description:(NSString *) myDescription Uses:(NSString *) myUses DatabasePath:(NSString *) dbPathString ERRORMESSAGE:(NSString **) errorMsg;

#pragma mark Delete Remedy
//NOTE: Delete the Remedy and the oils that are tagged to it without deleting the oils themselfs.
//USEDBY: List Remedy Details.
-(BOOL) deleteRemedyByID:(NSString *)RID DatabasePath:(NSString *) dbPathString MessageHandler:(NSString **) errorMsg;

#pragma mark Delete Related Links of Oils by Remedy ID
//NOTE:  This will delete all the oils that are int eh remedy oil list table that are tied to the RID:
//USEDBY: deleteRemedyByID
-(BOOL) ClearOilsPerRemedyByRID:(NSString *) RID DatabasePath:(NSString *) dbPathString MessageHandler:(NSString **) errorMsg;

#pragma mark Update Remedy Details by RID
//NOTE: This will update the remedy details
//USEDBY: Edit Remedy
-(BOOL) updateRemedyDetailsByRID:(NSString *) RID Name:(NSString *) RemedyName Description:(NSString *) myDescription Uses:(NSString *) myUses DatabasePath:(NSString *) dbPathString ERRORMESSAGE:(NSString **) errorMsg;

#pragma mark Get Remedy ID By Name
// Look up the Remedy by name to get the ID in the database, if it doesn't return 0, else ID
+(NSNumber *) getRemedyIDByName:(NSString *) Remedyname DatabasePath:(NSString *) dbPath ErrorMessage:(NSString **) errorMsg;

#pragma mark Add Oils to Remedy
// Sub to add the oils in the table to the database
-(void) addOilsToRemedyByRemedyID:(NSString *) RID OilsArray:(NSArray *) oilList DatabasePath:(NSString *) dbpath ErrorMessage:(NSString **) ErrMsg;

@end
