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
-(void) checkDBVersionAgainstExpectedVersion;

@end
