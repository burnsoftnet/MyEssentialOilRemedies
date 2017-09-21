//
//  FormFunctions.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/23/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYSettings.h"
@interface FormFunctions : UIViewController

#pragma mark Textbox View Layouts
//NOTE: Creates a border around a Textview
//USEBD: GENERAL
-(void) setBordersTextView :(UITextView *) myObj;

#pragma mark Textbox Layout
//NOTE: Creates a border around a regular text box
//USEBD: GENERAL
-(void) setBorderTextBox :(UITextField *) myObj;

#pragma mark Label Borders
//NOTE: Creates a border around the label
//USEBD: GENERAL
-(void) setBorderLabel :(UILabel *) myObj;

#pragma mark Common Alert/Message Handling
//NOTE: Send a Message box from the View controller that you are currently on. It's easier then copying this function all over the place
//USEBD: GENERAL
-(void)sendMessage:(NSString *) msg MyTitle:(NSString *) mytitle ViewController:(UIViewController *) MyViewController;
+(void)sendMessage:(NSString *) msg MyTitle:(NSString *) mytitle ViewController:(UIViewController *) MyViewController;

#pragma mark Alert on Limit
//Alert on limit reached and give the option to buy the full verion from the app sotre.
+(void) AlertonLimitForViewController:(UIViewController *) MyVewController;

#pragma mark Check For Error in Message via MessageBog
//NOTE: This will check the message to see if something is in it, if not it will not alert via MessageBox
//USEBD: GENERAL
-(void)checkForError :(NSString *) errorMsg MyTitle:(NSString *) errTitle ViewController:(UIViewController *) MyViewController;

#pragma mark Check for Error in Message via NSLOG
//NOTE: his will check the message to see if something is in it, if not it will not alert via NSLog
//USEBD: GENERAL
-(void)checkForErrorLogOnly :(NSString *) errorMsg MyTitle:(NSString *) errTitle;

#pragma mark NSLog Debug Message
//NOTE: Mostly used for runtime debugging by sending message of information back to the output window.
//      Only when the Global Var BUGGERME is true will it write out message
//USEBD: GENERAL
-(void)doBuggermeMessage :(NSString *) msg FromSubFunction:(NSString *) fromlocation;

#pragma mark NSLog Debug Message
//NOTE: Mostly used for runtime debugging by sending message of information back to the output window.
//      Only when the Global Var BUGGERME is true will it write out message
//USEBD: GENERAL
+(void)doBuggermeMessage :(NSString *) msg FromSubFunction:(NSString *) fromlocation;
@end
