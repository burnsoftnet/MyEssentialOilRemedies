//
//  BurnSoftMath.m
//  BurnSoftGeneral
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "BurnSoftMath.h"

@implementation BurnSoftMath
#pragma mark Get Price Per Item
/*!
    @brief Pass the price and qty to have it broken down to Price per item
    @return returns a double with two decimal
 */
-(double)getPricePerItem :(NSString *) price :(NSString *) qty
{
    return [[NSString stringWithFormat:@"%.2f",[price doubleValue]/[qty doubleValue]] doubleValue];
}

#pragma mark Multiply Two Items
/*!
    @brief Pass two values to have them multiplied
    @return
 */
-(int) multiplyTwoItems :(NSString *) itemOne :(NSString *) itemTwo
{
    return [itemOne intValue] * [itemTwo intValue];
}

#pragma markMultiply Two Items as Double Two Decimals
/*!
 @brief Pass two values to have them multiplied
 @return returns a double with two decimal
 */
-(double) multiplyTwoItems2DecDouble :(NSString *) itemOne :(NSString *) itemTwo
{
    return [[NSString stringWithFormat:@"%.2f",[itemOne doubleValue] * [itemTwo doubleValue]] doubleValue];
}

#pragma markMultiply Two Items as Double
/*!
 @brief Pass two values to have them multiplied
 @return returns as full double value
 */
-(double) multiplyTwoItemsFullDouble :(NSString *) itemOne :(NSString *) itemTwo
{
    return [itemOne doubleValue] * [itemTwo doubleValue];
}

#pragma mark Add two Values as Integer
/*!
 @brief Pass two string values to return as intenger
 @return
 */
-(int) AddTwoItemsAsInteger :(NSString *) itemOne :(NSString *) itemTwo
{
    return [itemOne intValue] + [itemTwo intValue];
}

#pragma mark Add Two Values as Double
/*!
 @brief Pass Two string values to return as double
 @return
 */
-(double) AddTwoItemsAsDouble :(NSString *) itemOne :(NSString *) itemTwo
{
    return [itemOne doubleValue] + [itemTwo doubleValue];
}

#pragma mark Convert Double To String
/*!
 @brief Convert a Double Value to a string with two decimals
 @return
 */
-(NSString *)convertDoubleToString :(double) dValue
{
    return [NSString stringWithFormat:@"%f",dValue];
}

#pragma mark Get Price per item as String
/*!
 @brief Pass the price and qty to have it broken down to Price per item
 @return returns a string with two decimal
 */
-(NSString *)getPricePerItemString :(NSString *) price :(NSString *) qty
{
    return [NSString stringWithFormat:@"%.2f",[price doubleValue]/[qty doubleValue]];
}

#pragma mark Multiply Two Strings to Return String
/*!
 @brief Pass two string values to multiply and return the value as string
 @return
 */
-(NSString *) multiplyTwoItemsString :(NSString *) itemOne :(NSString *) itemTwo
{
    return [NSString stringWithFormat:@"%d",[itemOne intValue] * [itemTwo intValue]];
}

#pragma mark  Multiply Two Strings to Return Double Two Decimals
/*!
 @brief Pass two string values to multiply and return the value as stwo decimal point double
 @return
 */
-(NSString *) multiplyTwoItems2DecDoubleString :(NSString *) itemOne :(NSString *) itemTwo
{
    return [NSString stringWithFormat:@"%.2f",[itemOne doubleValue] * [itemTwo doubleValue]];
}

#pragma mark
/*!
 @brief Pass two string values to multiply and return the value as full double
 @return
 */
-(NSString *) multiplyTwoItemsFullDoubleString :(NSString *) itemOne :(NSString *) itemTwo
{
    return [NSString stringWithFormat:@"%f",[itemOne doubleValue] * [itemTwo doubleValue]];
}

#pragma mark Add Two Strings as Integers
/*!
 @brief Pass two string values to be added as integers and return the result as a string
 @return
 */
-(NSString *) AddTwoItemsAsIntegerString :(NSString *) itemOne :(NSString *) itemTwo
{
    return [NSString stringWithFormat:@"%d",[itemOne intValue] + [itemTwo intValue]];
}

#pragma mark Add Two Strings as Double Two Decimal
/*!
 @brief Pass two string values to be added as doubles and return the result as a string
 @return
 */
-(NSString *) AddTwoItemsAsDoubleString :(NSString *) itemOne :(NSString *) itemTwo
{
    return [NSString stringWithFormat:@"%f",[itemOne doubleValue] + [itemTwo doubleValue]];
}

@end
