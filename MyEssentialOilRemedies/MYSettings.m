//
//  MYSettings.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/23/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "MYSettings.h"

@implementation MYSettings

+(BOOL) IsLiteVersion
{
    NSString *targetName = [[NSProcessInfo processInfo] environment][@"TARGET_NAME"];
    if ([targetName isEqualToString: @"My Essential Oil Remedies"])
    {
        return NO;
    } else {
        return YES;
    }
}
@end
