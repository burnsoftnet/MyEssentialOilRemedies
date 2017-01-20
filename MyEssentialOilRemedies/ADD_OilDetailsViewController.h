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
#import "MySettings.h"
#import "FormFunctions.h"

@interface ADD_OilDetailsViewController : UIViewController <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtCommonName;
@property (weak, nonatomic) IBOutlet UITextField *txtBotanicalName;
@property (weak, nonatomic) IBOutlet UITextView *txtIngredients;
@property (weak, nonatomic) IBOutlet UITextView *txtSafetyNotes;
@property (weak, nonatomic) IBOutlet UITextField *txtColor;
@property (weak, nonatomic) IBOutlet UITextField *txtViscosity;
@property (weak, nonatomic) IBOutlet UISwitch *swInStock;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;

- (IBAction)btnAdd:(id)sender;

@end
