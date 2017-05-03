//
//  DBUpgrade.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 12/30/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BurnSoftDatabase.h"
#import "MYSettings.h"
#import "FormFunctions.h"

@interface DBUpgrade : NSObject

#pragma mark Check if DB needs upgrading
//NOTE: Checks the expected version of the app to see if the database needs to be upgraded by looking at it's version
//USEDBY: MainStartViewController.m
-(void) checkDBVersionAgainstExpectedVersion;

@end
