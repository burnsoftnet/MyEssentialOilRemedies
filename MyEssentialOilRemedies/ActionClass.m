//
//  ActionClass.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 4/4/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import "ActionClass.h"

@implementation ActionClass
{
    sqlite3 *OilDB;
}
+(void) sendToActionSheetViewController:(UIViewController *) MyViewController FileToSend:(NSString *) actionFile
{
    //NSString *actionFile = @"ActionFile.txt";
    NSURL *url = [NSURL URLWithString:actionFile];
    NSArray *objectsToShare = @[url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    // Exclude all activities except AirDrop.
    //UIActivityTypeMessage, UIActivityTypeMail,
    //UIActivityTypePrint,
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;
    
    // Present the controller
    [MyViewController presentViewController:controller animated:YES completion:nil];
  
}
+(NSString *) appendToOuput:(NSString *) sOutput forField:(NSString *) fieldName Value:(NSString *) value
{
    return [sOutput stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n",fieldName, value]];
}
+(NSString *) writeOilDetailsToFileToSendByName:(NSString *) OilName CommonName:(NSString *) commonName BotanicalName:(NSString *) botName Ingredients:(NSString *) ingredients SafetyNotes:(NSString *) safetyNotes Color:(NSString *) color Viscosity:(NSString *) viscosity InStock:(NSString *) instock Vendor:(NSString *) vendor WebSite:(NSString *)website Description:(NSString *) description
{
    NSString *sAns = @"OilDetails.txt";
    NSString *sOutput = [NSString new];
    sOutput = [NSString stringWithFormat:@"Oil Name: %@\n",OilName];
    sOutput = [self appendToOuput:sOutput forField:@"Common Name" Value:commonName];
    sOutput = [self appendToOuput:sOutput forField:@"Botanical Name" Value:botName];
    sOutput = [self appendToOuput:sOutput forField:@"Ingredients" Value:ingredients];
    sOutput = [self appendToOuput:sOutput forField:@"Safety Notes" Value:safetyNotes];
    sOutput = [self appendToOuput:sOutput forField:@"Color" Value:color];
    sOutput = [self appendToOuput:sOutput forField:@"Viscosity" Value:viscosity];
    sOutput = [self appendToOuput:sOutput forField:@"In-Stock" Value:instock];
    sOutput = [self appendToOuput:sOutput forField:@"Vendor" Value:vendor];
    sOutput = [self appendToOuput:sOutput forField:@"WebSite" Value:website];
    sOutput = [self appendToOuput:sOutput forField:@"Description" Value:description];
    NSLog(@"%@",sOutput);
    [sOutput writeToFile:sAns atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return sAns;
}

@end
