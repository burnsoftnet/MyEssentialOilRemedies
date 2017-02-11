//
//  BurnSoftGeneral.h
//  BurnSoftGeneral
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BurnSoftGeneral : NSObject
-(NSString *) FCString:(NSString *) sValue;
-(unsigned long) FCLong:(NSString *) sValue;
-(NSString *)getValueFromLongString:(NSString *)sValue :(NSString *)mySeparater :(NSInteger) myIndex;
-(unsigned long) CountCharacters:(NSString *) sValue;
-(BOOL) isNumeric :(NSString *) sValue;
-(NSString *)formatDate:(NSDate *)date;
-(BOOL) copyFileFrom:(NSString *) sFrom To:(NSString *) sTo ErrorMessage:(NSString **) errorMessage;
-(BOOL)DeleteFileByPath:(NSString *) sPath ErrorMessage:(NSString **) msg;

@end
