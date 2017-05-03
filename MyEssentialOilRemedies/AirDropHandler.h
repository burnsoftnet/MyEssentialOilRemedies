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
//IMport a the data from a file via AirDrop or email file.
+(void) OpenFilebyPath:(NSString *) filePath ViewController:(UIViewController *) viewController;

#pragma mark Process Inbox Files
//This will look through the document/inbox files and start processing the files based on the name.
+(void) processInBoxFilesFromViewController:(UIViewController *) viewController;
@end
