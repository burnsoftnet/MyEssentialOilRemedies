//
//  FormFunctions.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/23/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "FormFunctions.h"

@implementation FormFunctions
#pragma mark Textbox View Layouts
//NOTE: Creates a border around a Textview
//USEBD: GENERAL
-(void) setBordersTextView :(UITextView *) myObj
{
    [[myObj layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[myObj layer] setBorderWidth:2.3];
    [[myObj layer] setCornerRadius:2];
}
#pragma mark Textbox Layout
//NOTE: Creates a border around a regular text box
//USEBD: GENERAL
-(void) setBorderTextBox :(UITextField *) myObj
{
    [[myObj layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[myObj layer] setBorderWidth:2.3];
    [[myObj layer] setCornerRadius:2];
}
#pragma mark Label Borders
//NOTE: Creates a border around the label
//USEBD: GENERAL
-(void) setBorderLabel :(UILabel *) myObj
{
    [[myObj layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[myObj layer] setBorderWidth:2.3];
    [[myObj layer] setCornerRadius:2];
}
#pragma mark Common Alert/Message Handling
//NOTE: Send a Message box from the View controller that you are currently on. It's easier then copying this function all over the place
//USEBD: GENERAL
-(void)sendMessage:(NSString *) msg MyTitle:(NSString *) mytitle ViewController:(UIViewController *) MyViewController
{
    //Send MessageBox Alert message to screen
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:mytitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {}];
    [alert addAction:defaultAction];
    [MyViewController presentViewController:alert animated:YES completion:nil];
}
#pragma mark Check For Error in Message via MessageBog
//NOTE: This will check the message to see if something is in it, if not it will not alert via MessageBox
//USEBD: GENERAL
-(void)checkForError :(NSString *) errorMsg MyTitle:(NSString *) errTitle ViewController:(UIViewController *) MyViewController
{
    if (![errorMsg  isEqual: @""])
    {
        [self doBuggermeMessage:errorMsg FromSubFunction:[NSString stringWithFormat:@"CheckForError.%@",errTitle]];

        NSString *mytitle = [NSString stringWithFormat:@"%@ Error",errTitle];
        [self sendMessage:errorMsg MyTitle:mytitle ViewController:MyViewController];
        
    }
}
#pragma mark Check for Error in Message via NSLOG
//NOTE: his will check the message to see if something is in it, if not it will not alert via NSLog
//USEBD: GENERAL
-(void)checkForErrorLogOnly :(NSString *) errorMsg MyTitle:(NSString *) errTitle
{
    if (![errorMsg  isEqual: @""])
    {
        [self doBuggermeMessage:errorMsg FromSubFunction:[NSString stringWithFormat:@"CheckForError.%@",errTitle]];
        NSLog(@"%@",errorMsg);
    }

}
#pragma mark NSLog Debug Message
//NOTE: Mostly used for runtime debugging by sending message of information back to the output window.
//      Only when the Global Var BUGGERME is true will it write out message
//USEBD: GENERAL
-(void)doBuggermeMessage :(NSString *) msg FromSubFunction:(NSString *) fromlocation
{
    if (BUGGERME) {
        NSLog(@"%@ - %@",fromlocation,msg);
    }
}

#pragma mark NSLog Debug Message
//NOTE: Mostly used for runtime debugging by sending message of information back to the output window.
//      Only when the Global Var BUGGERME is true will it write out message
//USEBD: GENERAL
+(void)doBuggermeMessage :(NSString *) msg FromSubFunction:(NSString *) fromlocation
{
    if (BUGGERME) {
        NSLog(@"%@ - %@",fromlocation,msg);
    }

}
#pragma mark
@end
