//
//  AirDropHandler.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 5/1/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Parser.h"
#import "BurnSoftGeneral.h"
#import "BurnSoftDatabase.h"
#import "FormFunctions.h"
#import "OilLists.h"
#import "OilRemedies.h"

@interface AirDropHandler : UIViewController

#pragma mark Open File By Path for XML Importing
+(void) OpenFilebyPath:(NSString *) filePath ViewController:(UIViewController *) viewController;

#pragma mark Process Inbox Files
+(void) processInBoxFilesFromViewController:(UIViewController *) viewController;

#pragma mark Process Inbox All Files
+(void) processAllInBoxFilesFromViewController:(UIViewController *) viewController;

@end
