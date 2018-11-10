//
//  ADD_OilDetailsViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/20/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BurnSoftGeneral.h"
#import "BurnSoftDatabase.h"
#import "LIST_OilsTableViewController.h"
#import "MYSettings.h"
#import "FormFunctions.h"

@interface ADD_OilDetailsViewController : UIViewController <UIGestureRecognizerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtCommonName;
@property (weak, nonatomic) IBOutlet UITextField *txtBotanicalName;
@property (weak, nonatomic) IBOutlet UITextView *txtIngredients;
@property (weak, nonatomic) IBOutlet UITextView *txtSafetyNotes;
@property (weak, nonatomic) IBOutlet UITextField *txtColor;
@property (weak, nonatomic) IBOutlet UITextField *txtViscosity;
@property (weak, nonatomic) IBOutlet UISwitch *swInStock;
@property (weak, nonatomic) IBOutlet UISwitch *swIsBlend;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtVedor;
@property (weak, nonatomic) IBOutlet UITextField *txtWebsite;

#pragma mark Add Oil Button
- (IBAction)btnAdd:(id)sender;

@end
