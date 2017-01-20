//
//  BurnSoftMath.m
//  BurnSoftGeneral
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "BurnSoftMath.h"

@implementation BurnSoftMath
// Missing divide and Subtract functions
-(double)getPricePerItem :(NSString *) price :(NSString *) qty
{
    return [[NSString stringWithFormat:@"%.2f",[price doubleValue]/[qty doubleValue]] doubleValue];
}
-(int) multiplyTwoItems :(NSString *) itemOne :(NSString *) itemTwo
{
    return [itemOne intValue] * [itemTwo intValue];
}
-(double) multiplyTwoItems2DecDouble :(NSString *) itemOne :(NSString *) itemTwo
{
    return [[NSString stringWithFormat:@"%.2f",[itemOne doubleValue] * [itemTwo doubleValue]] doubleValue];
}
-(double) multiplyTwoItemsFullDouble :(NSString *) itemOne :(NSString *) itemTwo
{
    return [itemOne doubleValue] * [itemTwo doubleValue];
}
-(int) AddTwoItemsAsInteger :(NSString *) itemOne :(NSString *) itemTwo
{
    return [itemOne intValue] + [itemTwo intValue];
}
-(double) AddTwoItemsAsDouble :(NSString *) itemOne :(NSString *) itemTwo
{
    return [itemOne doubleValue] + [itemTwo doubleValue];
}
-(NSString *)convertDoubleToString :(double) dValue
{
    return [NSString stringWithFormat:@"%f",dValue];
}
-(NSString *)getPricePerItemString :(NSString *) price :(NSString *) qty
{
    return [NSString stringWithFormat:@"%.2f",[price doubleValue]/[qty doubleValue]];
}
-(NSString *) multiplyTwoItemsString :(NSString *) itemOne :(NSString *) itemTwo
{
    return [NSString stringWithFormat:@"%d",[itemOne intValue] * [itemTwo intValue]];
}
-(NSString *) multiplyTwoItems2DecDoubleString :(NSString *) itemOne :(NSString *) itemTwo
{
    return [NSString stringWithFormat:@"%.2f",[itemOne doubleValue] * [itemTwo doubleValue]];
}
-(NSString *) multiplyTwoItemsFullDoubleString :(NSString *) itemOne :(NSString *) itemTwo
{
    return [NSString stringWithFormat:@"%f",[itemOne doubleValue] * [itemTwo doubleValue]];
}
-(NSString *) AddTwoItemsAsIntegerString :(NSString *) itemOne :(NSString *) itemTwo
{
    return [NSString stringWithFormat:@"%d",[itemOne intValue] + [itemTwo intValue]];
}
-(NSString *) AddTwoItemsAsDoubleString :(NSString *) itemOne :(NSString *) itemTwo
{
    return [NSString stringWithFormat:@"%f",[itemOne doubleValue] + [itemTwo doubleValue]];
}

@end
