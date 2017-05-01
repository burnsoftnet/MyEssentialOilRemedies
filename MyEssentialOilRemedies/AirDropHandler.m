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
+(void) OpenFilebyPath:(NSString *) filePath ViewController:(UIViewController *) viewController
{
    Parser *parser = [[Parser alloc] initWithXMLFile:filePath];
    
    FormFunctions *myFunctions = [FormFunctions new];
    AirDropHandler *myAir = [AirDropHandler new];
    NSString *dbpath = [myAir setDataBasePath];
    
    NSLog(@"NEW SHIT %@",parser.Oil_Name);
    NSLog(@"NEW DESCRIPTION %@",parser.Oil_description);
    
    OilLists *myOils = [OilLists new];
    if ([myOils oilExistsByName:parser.Oil_Name DatabasePath:dbpath ErrorMessage:nil]){
        [myFunctions sendMessage:[NSString stringWithFormat:@"Oil %@ already exists!",parser.Oil_Name] MyTitle:@"Oil Exists" ViewController:viewController];
        NSLog(@"Oil Exists!");
    } else {
        NSLog(@"Oil Does not Exist!");
    }
}
@end
