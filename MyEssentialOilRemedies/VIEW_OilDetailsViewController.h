//
//  VIEW_OilDetailsViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/20/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OilLists.h"
#import "MySettings.h"
#import "FormFunctions.h"
#import "BurnSoftDatabase.h"
#import <sqlite3.h>

@interface VIEW_OilDetailsViewController : UIViewController

@property (strong, nonatomic) NSString *OID;

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblCommonName;
@property (weak, nonatomic) IBOutlet UILabel *lblBotanicalName;
@property (weak, nonatomic) IBOutlet UILabel *lblIngredients;
@property (weak, nonatomic) IBOutlet UILabel *lblSafetyNotes;
@property (weak, nonatomic) IBOutlet UILabel *lblColor;
@property (weak, nonatomic) IBOutlet UILabel *lblViscosity;
@property (weak, nonatomic) IBOutlet UISwitch *swInStock;
@property (weak, nonatomic) IBOutlet UITextView *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblVendor;
@property (weak, nonatomic) IBOutlet UILabel *lblWebsite;



- (IBAction)swUpdateStockStatus:(id)sender;
- (IBAction)btnClose:(id)sender;

@end
