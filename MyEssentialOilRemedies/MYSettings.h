//
//  MYSettings.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/23/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MYDBNAME "MEO.db"       //Database Name
#define MYDBVERSION 1.2         //Expected Database Version for the current version of this app
//extern BOOL * const BUGGERME;   //Enable the Debug Functions for additional information during run time.
#warning TODO: ONRELEASE upgrade DBVERSION TO 1.3
static BOOL BUGGERME = NO;
#warning TODO: ON RELEASE COMPILE LITE AND REGULAR VERSION
static BOOL ISLITE = NO;
static int LITE_LIMIT = 15;


@interface MYSettings : NSObject



@end
