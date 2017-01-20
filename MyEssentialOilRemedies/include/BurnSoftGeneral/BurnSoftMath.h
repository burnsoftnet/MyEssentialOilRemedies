//
//  BurnSoftMath.h
//  BurnSoftGeneral
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BurnSoftMath : NSObject
-(double)getPricePerItem :(NSString *) price :(NSString *) qty;
-(int) multiplyTwoItems :(NSString *) itemOne :(NSString *) itemTwo;
-(double) multiplyTwoItems2DecDouble :(NSString *) itemOne :(NSString *) itemTwo;
-(double) multiplyTwoItemsFullDouble :(NSString *) itemOne :(NSString *) itemTwo;
-(int) AddTwoItemsAsInteger :(NSString *) itemOne :(NSString *) itemTwo;
-(double) AddTwoItemsAsDouble :(NSString *) itemOne :(NSString *) itemTwo;
-(NSString *)convertDoubleToString :(double) dValue;
-(NSString *)getPricePerItemString :(NSString *) price :(NSString *) qty;
-(NSString *) multiplyTwoItemsString :(NSString *) itemOne :(NSString *) itemTwo;
-(NSString *) multiplyTwoItems2DecDoubleString :(NSString *) itemOne :(NSString *) itemTwo;
-(NSString *) multiplyTwoItemsFullDoubleString :(NSString *) itemOne :(NSString *) itemTwo;
-(NSString *) AddTwoItemsAsIntegerString :(NSString *) itemOne :(NSString *) itemTwo;
-(NSString *) AddTwoItemsAsDoubleString :(NSString *) itemOne :(NSString *) itemTwo;

@end
