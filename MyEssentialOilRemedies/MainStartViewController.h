//
//  MainStartViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/23/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYSettings.h"
#import "BurnSoftDatabase.h"
#import "DBUpgrade.h"
#import "DatabaseManagement.h"
#import "AirDropHandler.h"
#import "FormFunctions.h"

@interface MainStartViewController : UITabBarController
-(void)handleOpenURL:(NSURL *)url;
@end
