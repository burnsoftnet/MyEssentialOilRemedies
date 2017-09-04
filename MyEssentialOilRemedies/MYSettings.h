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
static BOOL BUGGERME = NO;
static BOOL ISLITE = YES;
static int LITE_LIMIT = 15;


@interface MYSettings : NSObject



@end
