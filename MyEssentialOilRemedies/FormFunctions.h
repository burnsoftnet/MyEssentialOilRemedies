//
//  FormFunctions.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/23/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySettings.h"
@interface FormFunctions : UIViewController
-(void) setBordersTextView :(UITextView *) myObj;
-(void) setBorderTextBox :(UITextField *) myObj;
-(void) setBorderLabel :(UILabel *) myObj;
-(void)sendMessage:(NSString *) msg MyTitle:(NSString *) mytitle ViewController:(UIViewController *) MyViewController;
-(void)checkForError :(NSString *) errorMsg MyTitle:(NSString *) errTitle ViewController:(UIViewController *) MyViewController;
-(void)checkForErrorLogOnly :(NSString *) errorMsg MyTitle:(NSString *) errTitle;
-(void)doBuggermeMessage :(NSString *) msg FromSubFunction:(NSString *) fromlocation;
+(void)doBuggermeMessage :(NSString *) msg FromSubFunction:(NSString *) fromlocation;
@end
