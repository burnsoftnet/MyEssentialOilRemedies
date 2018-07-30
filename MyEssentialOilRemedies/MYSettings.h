//
//  MYSettings.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/23/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MYDBNAME "MEO.db"       //Database Name
#define MYDBVERSION 1.3         //Expected Database Version for the current version of this app
static BOOL BUGGERME = NO;
#warning TODO: ON RELEASE COMPILE LITE AND REGULAR VERSION
static BOOL ISLITE = NO;
static int LITE_LIMIT = 15;


@interface MYSettings : NSObject



@end
