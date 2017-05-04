//
//  ActionClass.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 4/4/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "BurnSoftDatabase.h"
#import "BurnSoftGeneral.h"

@interface ActionClass : UIViewController <UIActionSheetDelegate,NSXMLParserDelegate>


#pragma mark Create an Action Sheet for iPhone and iPad to send data to another device
+(void) sendToActionSheetViewController:(UIViewController *) MyViewController ActionSheetObjects:(NSArray *) ActionObjects eMailSubject:(NSString *) emailSubject;

#pragma mark Format Oil Details to one String
// Appened all the Oil Detail Fields to one formated string for output to send via Airdrop, message, email, notes, etc.
+(NSString *) OilDetailsToStringByName:(NSString *) OilName CommonName:(NSString *) commonName BotanicalName:(NSString *) botName Ingredients:(NSString *) ingredients SafetyNotes:(NSString *) safetyNotes Color:(NSString *) color Viscosity:(NSString *) viscosity InStock:(NSString *) instock Vendor:(NSString *) vendor WebSite:(NSString *)website Description:(NSString *) description;

#pragma mark Write the oil Details to a file
//Write the XML contents from sOutput to File
+(NSString *) writeOilDetailsToFileToSendByName:(NSString *) sOutPut;

#pragma mark Write the oil Details to a file based by Name
//Write the XML contents from sOutput to File based on the Oil Name
+(NSString *) writeOilDetailsToFileToSendOutput:(NSString *) sOutPut WithName:(NSString *) OilName;

#pragma mark Write the Remedy Details to a file
//Write the XML contents from sOutput to File
+(NSString *) writeRemedyDetailsToFileToSendByName:(NSString *) sOutPut;

#pragma mark Write the Remedy Details to a file based by Name
//Write the XML contents from sOutput to File based on the remedy Name
+(NSString *) writeRemedyDetailsToFileToSendOutput:(NSString *) sOutPut WithName:(NSString *) RemedyName;

#pragma mark Format Remedy Details to one String
//  Append all the Remedy Details fields to one format string for output to send via Airdrop, message, noets etc.
+(NSString *) RemedyDetailsToStringByName:(NSString *) remedyName Description:(NSString *) description OilsArray:(NSString *) oilsArray HowToUse:(NSString *) howTouse;

#pragma mark Append to the Output of an Existing String
+(NSString *) appendToOuput:(NSString *) sOutput forField:(NSString *) fieldName Value:(NSString *) value;

@end
