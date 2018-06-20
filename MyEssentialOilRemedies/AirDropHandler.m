//
//  AirDropHandler.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 5/1/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import "AirDropHandler.h"

@implementation AirDropHandler
{
    
}
#pragma mark Open File By Path
// Set the database path and file for this application
-(NSString *) setDataBasePath
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    return [myObj getDatabasePath:@MYDBNAME];
}

#pragma mark Open File By Path for XML Importing
//IMport a the data from a file via AirDrop or email file.
+(void) OpenFilebyPath:(NSString *) filePath ViewController:(UIViewController *) viewController
{
    Parser *parser = [[Parser alloc] initWithXMLFile:filePath];
    
    AirDropHandler *myAir = [AirDropHandler new];
    FormFunctions *myobjF = [FormFunctions new];
    
    NSString *dbpath = [myAir setDataBasePath];
    
    NSString *AlertAction_Title = @"";
    NSString *AlertAction_Message = @"";
    
    if (parser.isOIL)
    {
        OilLists *myOils = [OilLists new];
        
        BOOL OilExists = [myOils oilExistsByName:parser.Oil_Name DatabasePath:dbpath ErrorMessage:nil];
        
        if (OilExists) {
            AlertAction_Title=@"Oil Exists!";
            AlertAction_Message= [NSString stringWithFormat:@"%@ already exists!  Do you wish to replace theRemedy you have with this one?",parser.Oil_Name];
        } else {
            AlertAction_Title=@"Add New Oil?";
            AlertAction_Message= [NSString stringWithFormat:@"Do you wish to add %@ to your oil collection?",parser.Oil_Name];
        }
        
        UIAlertController * alert=[UIAlertController
                                   alertControllerWithTitle:AlertAction_Title message:AlertAction_Message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Yes"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        BOOL INSERT_ACION_OK = NO;
                                        NSNumber *MYOID = [OilLists getOilIDByName:parser.Oil_Name InStock:0 DatabasePath:dbpath ErrorMessage:nil];

                                        if (!(MYOID==0)){
                                            
                                            if (OilExists) {
                                                INSERT_ACION_OK = [OilLists updateOilDetailsByOID:MYOID Description:parser.Oil_description BotanicalName:parser.Oil_BotanicalName Ingredients:parser.Oil_Ingredients SafetyNotes:parser.Oil_SafetyNotes Color:parser.Oil_Color Viscosity:parser.Oil_Viscosity CommonName:parser.Oil_CommonName Vendor:parser.Oil_vendor WebSite:parser.Oil_website DatabasePath:dbpath ErrorMessage:nil];
                                            } else {
                                                INSERT_ACION_OK = [OilLists insertOilDetailsByOID:MYOID Description:parser.Oil_description BotanicalName:parser.Oil_BotanicalName Ingredients:parser.Oil_Ingredients SafetyNotes:parser.Oil_SafetyNotes Color:parser.Oil_Color Viscosity:parser.Oil_Viscosity CommonName:parser.Oil_CommonName Vendor:parser.Oil_vendor WebSite:parser.Oil_website
                                                    Blended:parser.Oil_isBlend DatabasePath:dbpath ErrorMessage:nil];
                                            }
                                            
                                            
                                            if (INSERT_ACION_OK) {
                                                [myobjF sendMessage:[NSString stringWithFormat:@"Import of %@ oil details was completed.",parser.Oil_Name] MyTitle:@"Import Complete" ViewController:viewController];
                                                
                                            } else {
                                                [myobjF sendMessage:[NSString stringWithFormat:@"Import of %@ oil was had an error on details insert.",parser.Oil_Name] MyTitle:@"Import Error!" ViewController:viewController];
                                            }
                                        } else {
                                            [myobjF sendMessage:[NSString stringWithFormat:@"Import of %@ oil had an error getting existing Oil ID .",parser.Oil_Name] MyTitle:@"Import Error!" ViewController:viewController];
                                        }
                                        [BurnSoftGeneral clearDocumentInBox];
                                    }];
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"No"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [BurnSoftGeneral clearDocumentInBox];
                                       [myobjF sendMessage:[NSString stringWithFormat:@"Import of %@ oil was aborted.",parser.Oil_Name] MyTitle:@"Import Aborted!" ViewController:viewController];
                                   }];
        
        [alert addAction:yesButton];
        [alert addAction:noButton];
        
        [viewController presentViewController:alert animated:YES completion:nil];
    }
    
    if (parser.isREMEDY) {
        OilRemedies *myObj = [OilRemedies new];
        BOOL REMEDY_EXISTS = [myObj RemedyExistsByName:parser.Remedy_Name DatabasePath:dbpath ErrorMessage:nil];
        
        if (REMEDY_EXISTS) {
            AlertAction_Title = @"Remedy Exists!";
            AlertAction_Message =  [NSString stringWithFormat:@"%@ already exists!  Do you wish to replace the remedy you have with this one?",parser.Remedy_Name];
        } else {
            AlertAction_Title = @"Add new Remedy?";
            AlertAction_Message = [NSString stringWithFormat:@"Do you wish to add %@ to your Remedy collection?",parser.Remedy_Name];;
        }
        
        UIAlertController * alert=[UIAlertController
                                   alertControllerWithTitle:AlertAction_Title message:AlertAction_Message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Yes"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        OilRemedies *myObjOR = [OilRemedies new];
                                        
                                        if (REMEDY_EXISTS) {
                                            NSNumber *MYRID = [OilRemedies getRemedyIDByName:parser.Remedy_Name DatabasePath:dbpath ErrorMessage:nil];
                                            [FormFunctions doBuggermeMessage:[NSString stringWithFormat:@"Remedy Exists with ID %@",MYRID] FromSubFunction:@"AirDropHandler.OpenFileByPath"];
                                            [myObjOR deleteRemedyByID:[MYRID stringValue] DatabasePath:dbpath MessageHandler:nil];
                                        }
                                        
                                        BurnSoftGeneral *myObj = [BurnSoftGeneral new];
                                        NSString *RID;
                                        NSString *errorMsg;
                                        
                                        RID = [myObjOR AddRemedyDetailsByName:[myObj FCString:parser.Remedy_Name] Description:[myObj FCString:parser.Remedy_Description] Uses:[myObj FCString:parser.Remedy_Uses] DatabasePath:dbpath ERRORMESSAGE:&errorMsg];
                                        //Add Oils to this remedy
                                        [myObjOR addOilsToRemedyByRemedyID:RID OilsArray:parser.Remedy_Oils DatabasePath:dbpath ErrorMessage:&errorMsg];
                                        [BurnSoftGeneral clearDocumentInBox];
                                    }];
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"No"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [BurnSoftGeneral clearDocumentInBox];
                                       [myobjF sendMessage:[NSString stringWithFormat:@"Import of Remedy %@ was aborted.",parser.Remedy_Name] MyTitle:@"Import Aborted!" ViewController:viewController];
                                   }];
        
        [alert addAction:yesButton];
        [alert addAction:noButton];
        
        [viewController presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark Process Inbox Files
//This will look through the document/inbox files and start processing the files based on the name.
+(void) processInBoxFilesFromViewController:(UIViewController *) viewController
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingString:@"/Inbox/"];

    NSString *oilDropFile = [documentsDirectory stringByAppendingString:@"OilDetails.meo"];
    NSString *remedyDropFile = [documentsDirectory stringByAppendingString:@"RemedyDetails.meor"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:oilDropFile]){
        [self OpenFilebyPath:oilDropFile ViewController:viewController];
    }
    
    if ([fileManager fileExistsAtPath:remedyDropFile]) {
        [self OpenFilebyPath:remedyDropFile ViewController:viewController];
    }
    
    paths = nil;
    fileManager = nil;
    
}

#pragma mark Process Inbox All Files
//This will look through the document/inbox directory for all files that relate to this app to process
+(void) processAllInBoxFilesFromViewController:(UIViewController *) viewController
{
    NSArray *filePathsArray = [NSArray new];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingString:@"/Inbox/"];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    filePathsArray = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.meo'"]];
    NSString *oilFile = [NSString new];
    
    for (int x = 0; x < [dirFiles count]; x++) {
        oilFile = [documentsDirectory stringByAppendingString:dirFiles[x]];;
        [self OpenFilebyPath:oilFile ViewController:viewController];
    }
    
    NSString *remedyFile = [NSString new];
    filePathsArray = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.meor'"]];
    
    for (int x = 0; x < [dirFiles count]; x++) {
        remedyFile= [documentsDirectory stringByAppendingString:dirFiles[x]];;
        [self OpenFilebyPath:remedyFile ViewController:viewController];
    }
    
    paths = nil;
    filePathsArray = nil;
    dirFiles = nil;
    
}

@end
