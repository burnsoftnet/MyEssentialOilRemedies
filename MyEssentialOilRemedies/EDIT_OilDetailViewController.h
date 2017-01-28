//
//  EDIT_OilDetailViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 7/1/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OilLists.h"
#import "MySettings.h"
#import "FormFunctions.h"
#import "BurnSoftDatabase.h"
#import "BurnSoftGeneral.h"
#import <sqlite3.h>

@interface EDIT_OilDetailViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSString *OID;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtCommonName;
@property (weak, nonatomic) IBOutlet UITextField *txtBotanicalName;
@property (weak, nonatomic) IBOutlet UITextView *txtIngredients;
@property (weak, nonatomic) IBOutlet UITextView *txtSafetyNotes;
@property (weak, nonatomic) IBOutlet UITextField *txtColor;
@property (weak, nonatomic) IBOutlet UITextField *txtViscosity;
@property (weak, nonatomic) IBOutlet UISwitch *swInStock;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtVendor;
@property (weak, nonatomic) IBOutlet UITextField *txtWebsite;
@property (assign) BOOL IsFromSearch;

- (IBAction)btnUpdate:(id)sender;


@end
