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
//View http://nshipster.com/uiactivityviewcontroller/ for details about activites
/*
 //Current excludeList caused nothing to show in the actionsheet
 
 NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
 UIActivityTypePostToWeibo,
 UIActivityTypeCopyToPasteboard,
 UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
 UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
 UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
 controller.excludedActivityTypes = excludedActivities;
 */
#pragma mark Create an Action Sheet for iPhone and iPad to send data to another device
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
+(NSString *) appendToOuput:(NSString *) sOutput forField:(NSString *) fieldName Value:(NSString *) value
{
    return [sOutput stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n",fieldName, value]];
}

#pragma mark Write the oil Details to a file
+(NSString *) writeOilDetailsToFileToSendByName:(NSString *) sOutPut
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *sAns = [docPath stringByAppendingPathComponent:@"OilDetails.meo"];
    [sOutPut writeToFile:sAns atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return sAns;
}

#pragma mark Format Oil Details to one String
// Appened all the Oil Detail Fields to one formated string for output to send via Airdrop, message, email, notes, etc.
+(NSString *) OilDetailsToStringByName:(NSString *) OilName CommonName:(NSString *) commonName BotanicalName:(NSString *) botName Ingredients:(NSString *) ingredients SafetyNotes:(NSString *) safetyNotes Color:(NSString *) color Viscosity:(NSString *) viscosity InStock:(NSString *) instock Vendor:(NSString *) vendor WebSite:(NSString *)website Description:(NSString *) description
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
    
    return sOutput;
}

#pragma mark Format Remedy Details to one String
//  Append all the Remedy Details fields to one format string for output to send via Airdrop, message, noets etc.
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
