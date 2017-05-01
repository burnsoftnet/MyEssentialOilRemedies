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

@interface AirDropHandler : UIViewController

#pragma mark Open File By Path
+(void) OpenFilebyPath:(NSString *) filePath ViewController:(UIViewController *) viewController;

@end
