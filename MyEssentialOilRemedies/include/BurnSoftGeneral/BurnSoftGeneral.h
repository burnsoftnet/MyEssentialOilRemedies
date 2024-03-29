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
+(NSString *) FCStringXML: (NSString *) sValue;
-(unsigned long) FCLong:(NSString *) sValue;
-(NSString *)getValueFromLongString:(NSString *)sValue :(NSString *)mySeparater :(NSInteger) myIndex;
-(unsigned long) CountCharacters:(NSString *) sValue;
-(BOOL) isNumeric :(NSString *) sValue;
-(NSString *)formatDate:(NSDate *)date;
-(BOOL) copyFileFrom:(NSString *) sFrom To:(NSString *) sTo ErrorMessage:(NSString **) errorMessage;
+(BOOL) copyFileFrom:(NSString *) sFrom To:(NSString *) sTo ErrorMessage:(NSString **) errorMessage;
+(BOOL) copyFileFromFilePath:(NSString *) fromPath ToNewPath:(NSString *) toPath ErrorMessage:(NSString **) msg;
-(BOOL)DeleteFileByPath:(NSString *) sPath ErrorMessage:(NSString **) msg;
+(BOOL)DeleteFileByPath:(NSString *) sPath ErrorMessage:(NSString **) msg;
-(BOOL)createDirectoryIfNotExists:(NSString *) sPath ErrorMessage:(NSString **) errMsg;
+(NSString *) convertBOOLtoString:(BOOL) bValue;
+(NSString *) getFileExtensionbyPath:(NSString *) filePath;
+(void) clearDocumentInBox;
+(BOOL) newFilesfoundProcessing;
+(NSNumber *) convertToNSNumberByString:(NSString *) sValue;
@end
