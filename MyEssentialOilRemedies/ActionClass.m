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

#pragma mark Create an Action Sheet for iPhone and iPad to send data to another device
/*! @brief  Create an Action Sheet to send data to another apple device using the action sheets
 */
+(void) sendToActionSheetViewController:(UIViewController *) MyViewController ActionSheetObjects:(NSArray *) ActionObjects eMailSubject:(NSString *) emailSubject
{
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:ActionObjects applicationActivities:nil];
    [controller setValue:emailSubject forKey:@"subject"];
    
    //. On iPad, you must present the view controller in a popover. On iPhone and iPod touch, you must present it modally.
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //iPhone, present activity view controller as is.
        [MyViewController presentViewController:controller animated:YES completion:^{}];
    }
    else
    {
        //iPad, present the view controller inside a popover.
        MyViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionRight;
        MyViewController.popoverPresentationController.sourceView = MyViewController.view;

        [MyViewController presentViewController:controller animated:YES completion:^{}];
        UIPopoverPresentationController *popController = [controller popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        controller.popoverPresentationController.sourceView = MyViewController.view;
    }
  
}

#pragma mark Append to the Output of an Existing String
/*! @brief A quick and easy way to format the output information, also if it needs to be changed then a majority
    of the change just needs to be in this section.
 */
+(NSString *) appendToOuput:(NSString *) sOutput forField:(NSString *) fieldName Value:(NSString *) value
{
    return [sOutput stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n",fieldName, value]];
}

#pragma mark Write the oil Details to a file
/*! @brief Write the XML contents from sOutput to File
 */
+(NSString *) writeOilDetailsToFileToSendByName:(NSString *) sOutPut
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *sAns = [docPath stringByAppendingPathComponent:@"OilDetails.meo"];
    [sOutPut writeToFile:sAns atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    path = nil;
    
    return sAns;
}

#pragma mark Write the oil Details to a file based by Name
/*! @brief Write the XML contents from sOutput to File based on the Oil Name
 */
+(NSString *) writeOilDetailsToFileToSendOutput:(NSString *) sOutPut WithName:(NSString *) OilName
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *sAns = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.meo",OilName]];
    
    [sOutPut writeToFile:sAns atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    path = nil;
    
    return sAns;
}

#pragma mark Write the Remedy Details to a file
/*! @brief Write the XML contents from sOutput to File
 */
+(NSString *) writeRemedyDetailsToFileToSendByName:(NSString *) sOutPut
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *sAns = [docPath stringByAppendingPathComponent:@"RemedyDetails.meor"];
    
    [sOutPut writeToFile:sAns atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    path = nil;
    
    return sAns;
}

#pragma mark Write the Remedy Details to a file based by Name
/*! @brief Write the XML contents from sOutput to File based on the remedy Name
 */
+(NSString *) writeRemedyDetailsToFileToSendOutput:(NSString *) sOutPut WithName:(NSString *) RemedyName
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *sAns = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.meor",RemedyName]];
    
    [sOutPut writeToFile:sAns atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    path = nil;
    
    return sAns;
}
#pragma mark Format Oil Details to one String
/*! @brief  Appened all the Oil Detail Fields to one formated string for output to send via Airdrop, message, email, notes, etc.
    @remark Used for rawText Details from View Oils Class
 */
+(NSString *) OilDetailsToStringByName:(NSString *) OilName CommonName:(NSString *) commonName BotanicalName:(NSString *) botName Ingredients:(NSString *) ingredients SafetyNotes:(NSString *) safetyNotes Color:(NSString *) color Viscosity:(NSString *) viscosity InStock:(NSString *) instock Vendor:(NSString *) vendor WebSite:(NSString *)website Description:(NSString *) description IsBlend:(NSString *) isblend
{
    
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
    sOutput = [self appendToOuput:sOutput forField:@"Is-Blend" Value:isblend];
    return sOutput;
}

#pragma mark Format Remedy Details to one String
/*! @brief   Append all the Remedy Details fields to one format string for output to send via Airdrop, message, noets etc.
 */
+(NSString *) RemedyDetailsToStringByName:(NSString *) remedyName Description:(NSString *) description OilsArray:(NSString *) oilsArray HowToUse:(NSString *) howTouse
{
    NSString *sOutPut = [NSString new];
    
    sOutPut = [NSString stringWithFormat:@"Remedy Name: %@\n", remedyName];
    sOutPut = [self appendToOuput:sOutPut forField:@"Description" Value:description];
    sOutPut = [self appendToOuput:sOutPut forField:@"\nOils" Value:@"\n"];

    sOutPut = [sOutPut stringByAppendingString:oilsArray];
    
    sOutPut = [self appendToOuput:sOutPut forField:@"\n\nHow To Use" Value:howTouse];

    return sOutPut;
}

@end
