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
-(NSString *) setDataBasePath
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    return [myObj getDatabasePath:@MYDBNAME];
}
/*
+(NSNumber *) getOilIDbyName:(NSString *) oilName
{
    BurnSoftGeneral *myObjOF = [BurnSoftGeneral new];
    BurnSoftDatabase *myObjDB = [BurnSoftDatabase new];
    AirDropHandler *myAir = [AirDropHandler new];
    
    NSNumber *MYOID = 0;
    NSString *dbPathString = [myAir setDataBasePath];
    NSString *msg = @"";
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO eo_oil_list (name,instock) VALUES ('%@',0)",[myObjOF FCString: oilName]];;
    
    if ([myObjDB runQuery:sql DatabasePath:dbPathString MessageHandler:&msg]){
        MYOID = [myObjDB getLastOneEntryIDbyName:oilName LookForColumnName:@"name" GetIDFomColumn:@"ID" InTable:@"eo_oil_list" DatabasePath:dbPathString MessageHandler:&msg];
    } else {
        
    }
    
    return MYOID;
}
*/

#pragma mark Open File By Path for XML Importing
//IMport a the data from a file via AirDrop or email file.
+(void) OpenFilebyPath:(NSString *) filePath ViewController:(UIViewController *) viewController
{
    Parser *parser = [[Parser alloc] initWithXMLFile:filePath];
    
    //FormFunctions *myFunctions = [FormFunctions new];
    AirDropHandler *myAir = [AirDropHandler new];
    FormFunctions *myobjF = [FormFunctions new];
    
    NSString *dbpath = [myAir setDataBasePath];
    
    //NSLog(@"NEW SHIT %@",parser.Oil_Name);
    //NSLog(@"NEW DESCRIPTION %@",parser.Oil_description);
    
    OilLists *myOils = [OilLists new];
    //NSString *msg = @"";
    if (parser.isOIL)
    {
        if ([myOils oilExistsByName:parser.Oil_Name DatabasePath:dbpath ErrorMessage:nil]){
            //[myFunctions sendMessage:[NSString stringWithFormat:@"Oil %@ already exists!",parser.Oil_Name] MyTitle:@"Oil Exists" ViewController:viewController];
            //NSLog(@"Oil Exists!");
            UIAlertController * alert=[UIAlertController
                                       alertControllerWithTitle:@"Add New Oil?" message:[NSString stringWithFormat:@"Do you wish to add %@ to your oil collection?",parser.Oil_Name] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"Yes"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            NSNumber *MYOID = [OilLists getOilIDByName:parser.Oil_Name InStock:0 DatabasePath:dbpath ErrorMessage:nil];
                                            //NSLog(@"you pressed Yes, please button %@",MYOID);
                                            if (!(MYOID==0)){
                                                if ([OilLists insertOilDetailsByOID:MYOID Description:parser.Oil_description BotanicalName:parser.Oil_BotanicalName Ingredients:parser.Oil_Ingredients SafetyNotes:parser.Oil_SafetyNotes Color:parser.Oil_Color Viscosity:parser.Oil_Viscosity CommonName:parser.Oil_CommonName Vendor:parser.Oil_vendor WebSite:parser.Oil_website DatabasePath:dbpath ErrorMessage:nil]) {
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
            
        } else {
            NSLog(@"Oil Does not Exist!");
            UIAlertController * alert=[UIAlertController
                                       alertControllerWithTitle:@"Oil Exists" message:[NSString stringWithFormat:@"%@ already exists!  Do you wish to replace the details you have with this one?",parser.Oil_Name] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"Yes"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            NSNumber *MYOID = [OilLists getOilIDByName:parser.Oil_Name InStock:0 DatabasePath:dbpath ErrorMessage:nil];
                                            //NSLog(@"you pressed Yes, please button %@",MYOID);
                                            if (!(MYOID==0)){
                                                if ([OilLists updateOilDetailsByOID:MYOID Description:parser.Oil_description BotanicalName:parser.Oil_BotanicalName Ingredients:parser.Oil_Ingredients SafetyNotes:parser.Oil_SafetyNotes Color:parser.Oil_Color Viscosity:parser.Oil_Viscosity CommonName:parser.Oil_CommonName Vendor:parser.Oil_vendor WebSite:parser.Oil_website DatabasePath:dbpath ErrorMessage:nil]) {
                                                    [myobjF sendMessage:[NSString stringWithFormat:@"Import of %@ oil details was updated.",parser.Oil_Name] MyTitle:@"Import Updated!" ViewController:viewController];
                                                } else {
                                                    [myobjF sendMessage:[NSString stringWithFormat:@"Import of %@ oil was had an error on update.",parser.Oil_Name] MyTitle:@"Import Error!" ViewController:viewController];
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

    }
}

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
}


@end
