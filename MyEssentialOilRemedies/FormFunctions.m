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
/*! @brief Creates a border around a Textview
    @remark USEBD: GENERAL
 */
-(void) setBordersTextView :(UITextView *) myObj
{
    [[myObj layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[myObj layer] setBorderWidth:2.3];
    [[myObj layer] setCornerRadius:2];
}

#pragma mark Textbox Layout
/*! @brief Creates a border around a regular text box
    @remark USEBD: GENERAL
 */
-(void) setBorderTextBox :(UITextField *) myObj
{
    [[myObj layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[myObj layer] setBorderWidth:2.3];
    [[myObj layer] setCornerRadius:2];
}

#pragma mark Label Borders
/*! @brief Creates a border around the label
    @remark USEBD: GENERAL
 */
-(void) setBorderLabel :(UILabel *) myObj
{
    [[myObj layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[myObj layer] setBorderWidth:2.3];
    [[myObj layer] setCornerRadius:2];
}

+(void) setBackGroundImage:(UIView *) myview
{
    //[[myview layer] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background2.png"]]];
    myview.backgroundColor = [self setDefaultViewBackground];
}

+(UIColor *) setHighlightColor
{
    return [UIColor greenColor];
}

+(UIColor *) setTextColor
{
    return [UIColor whiteColor];
}

+(UIColor *) setDefaultBackground
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"systemBrown.png"]];
}

+(UIColor *) setDefaultViewBackground
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background2.png"]];
}

#pragma mark Common Alert/Message Handling
/*! @brief Send a Message box from the View controller that you are currently on. It's easier then copying this function all over the place
    @remark USEBD: GENERAL
 */
-(void)sendMessage:(NSString *) msg MyTitle:(NSString *) mytitle ViewController:(UIViewController *) MyViewController
{
    //Send MessageBox Alert message to screen
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:mytitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {}];
    [alert addAction:defaultAction];
    [MyViewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark Common Alert/Message Handling
/*! @brief Send a Message box from the View controller that you are currently on. It's easier then copying this function all over the place
    @remark USEBD: GENERAL
*/
+(void)sendMessage:(NSString *) msg MyTitle:(NSString *) mytitle ViewController:(UIViewController *) MyViewController
{
    //Send MessageBox Alert message to screen
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:mytitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * Action) {}];
    [alert addAction:defaultAction];
    [MyViewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark Alert on Limit
/*! @brief Alert on limit reached and give the option to buy the full verion from the app sotre.
 */
+(void) AlertonLimitForViewController:(UIViewController *) MyVewController
{
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Limit Reached!"
                                                                  message:@"You Have reached your limit on the Lite Version!\n Please Purchase the Regular Version for Unlimited access!"
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Purchase"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                {
                                    NSURL *AppStore = [NSURL URLWithString:@"https://itunes.apple.com/us/app/my-essential-oil-remedies/id1188303079?ls=1&mt=8"];
                                    UIApplication *application = [UIApplication sharedApplication];
                                    [application openURL:AppStore options:@{} completionHandler:nil];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"No Thanks"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   // call method whatever u need
                               }];
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [MyVewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark Check For Error in Message via MessageBog
/*! @brief This will check the message to see if something is in it, if not it will not alert via MessageBox
    @remark USEBD: GENERAL
 */
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
/*! @brief his will check the message to see if something is in it, if not it will not alert via NSLog
    @remark USEBD: GENERAL
 */
-(void)checkForErrorLogOnly :(NSString *) errorMsg MyTitle:(NSString *) errTitle
{
    if (![errorMsg  isEqual: @""])
    {
        [self doBuggermeMessage:errorMsg FromSubFunction:[NSString stringWithFormat:@"CheckForError.%@",errTitle]];
        NSLog(@"%@",errorMsg);
    }

}
#pragma mark Check for Error in Message via NSLOG
/*! @brief his will check the message to see if something is in it, if not it will not alert via NSLog
 @remark USEBD: GENERAL
 */
+(void)checkForErrorLogOnly :(NSString *) errorMsg MyTitle:(NSString *) errTitle
{
    if (![errorMsg  isEqual: @""])
    {
        [self doBuggermeMessage:errorMsg FromSubFunction:[NSString stringWithFormat:@"CheckForError.%@",errTitle]];
        NSLog(@"%@",errorMsg);
    }
    
}
#pragma mark NSLog Debug Message
/*! @brief Mostly used for runtime debugging by sending message of information back to the output window.
    Only when the Global Var BUGGERME is true will it write out message
    @remark USEBD: GENERAL
 */
-(void)doBuggermeMessage :(NSString *) msg FromSubFunction:(NSString *) fromlocation
{
#if DEBUG
    if (BUGGERME) {
        NSLog(@"DEBUG - %@ - %@",fromlocation,msg);
    }
#endif
}

#pragma mark NSLog Debug Message
/*! @brief  Mostly used for runtime debugging by sending message of information back to the output window.
    Only when the Global Var BUGGERME is true will it write out message
    @remark USEBD: GENERAL
*/
+(void)doBuggermeMessage :(NSString *) msg FromSubFunction:(NSString *) fromlocation
{
#if DEBUG
    if (BUGGERME) {
        NSLog(@"DEBUG - %@ - %@",fromlocation,msg);
    }
#endif
}
#pragma mark
@end
