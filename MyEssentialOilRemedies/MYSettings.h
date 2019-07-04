//
//  MYSettings.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/23/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MYDBNAME "MEO.db"       //Database Name
#define MYDBVERSION 1.4         //Expected Database Version for the current version of this app
static BOOL BUGGERME = YES;
#warning TODO: ON RELEASE COMPILE LITE AND REGULAR VERSION
static BOOL ISLITE = NO;
static BOOL USESECTIONS_OIL = YES;
static BOOL USESECTIONS_REMEDIES = YES;
static int LITE_LIMIT = 15;


@interface MYSettings : NSObject



@end
