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
#define FULLVERSIONNAME "My Essential Oil Remedies"

#ifndef NDEBUG
static BOOL BUGGERME = YES;
#else
static BOOL BUGGERME = NO;
#endif

static BOOL USESECTIONS_OIL = YES;
static BOOL USESECTIONS_REMEDIES = YES;
static int LITE_LIMIT = 15;


@interface MYSettings : NSObject

+(BOOL) IsLiteVersion;

@end
