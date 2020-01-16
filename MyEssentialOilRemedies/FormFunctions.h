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
-(void) setBordersTextView :(UITextView *) myObj;

#pragma mark Textbox Layout
-(void) setBorderTextBox :(UITextField *) myObj;

#pragma mark Label Borders
-(void) setBorderLabel :(UILabel *) myObj;
#pragma mark Set BackGround
+(void) setBackGroundImage:(UIView *) myview;
+(UIColor *) setHighlightColor;
+(UIColor *) setTextColor;
+(UIFont *) setHeaderTextFontSize;
+(int) setHeaderTextHeight;
+(int) setTableHeaderHeight;
+(UIColor *) setDefaultBackgroundColor;
+(UIColor *) setDefaultBackground;
+(UIColor *) setDefaultViewBackground;
+(UIColor *) setEditColor;
+(UIColor *) setDeleteColor;
+(UIColor *) setCartColor;

#pragma mark Common Alert/Message Handling
-(void)sendMessage:(NSString *) msg MyTitle:(NSString *) mytitle ViewController:(UIViewController *) MyViewController;
+(void)sendMessage:(NSString *) msg MyTitle:(NSString *) mytitle ViewController:(UIViewController *) MyViewController;

#pragma mark Alert on Limit
+(void) AlertonLimitForViewController:(UIViewController *) MyVewController;

#pragma mark Check For Error in Message via MessageBog
-(void)checkForError :(NSString *) errorMsg MyTitle:(NSString *) errTitle ViewController:(UIViewController *) MyViewController;

#pragma mark Check for Error in Message via NSLOG
-(void)checkForErrorLogOnly :(NSString *) errorMsg MyTitle:(NSString *) errTitle;
+(void)checkForErrorLogOnly :(NSString *) errorMsg MyTitle:(NSString *) errTitle;
#pragma mark NSLog Debug Message
-(void)doBuggermeMessage :(NSString *) msg FromSubFunction:(NSString *) fromlocation;

#pragma mark NSLog Debug Message
+(void)doBuggermeMessage :(NSString *) msg FromSubFunction:(NSString *) fromlocation;
@end
