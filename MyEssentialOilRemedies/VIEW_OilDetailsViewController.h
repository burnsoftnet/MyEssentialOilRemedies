//
//  VIEW_OilDetailsViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/20/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OilLists.h"
#import "MYSettings.h"
#import "FormFunctions.h"
#import "BurnSoftDatabase.h"
#import "ActionClass.h"
#import <sqlite3.h>
#import "Parser.h"
#import "AirDropHandler.h"


@interface VIEW_OilDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) NSString *OID;
@property (strong, nonatomic) NSString *RID;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblCommonName;
@property (weak, nonatomic) IBOutlet UILabel *lblBotanicalName;

@property (weak, nonatomic) IBOutlet UITextView *lblIngredients;
@property (weak, nonatomic) IBOutlet UILabel *lblSafetyNotes;
@property (weak, nonatomic) IBOutlet UILabel *lblColor;
@property (weak, nonatomic) IBOutlet UILabel *lblViscosity;
@property (weak, nonatomic) IBOutlet UISwitch *swInStock;
@property (weak, nonatomic) IBOutlet UISwitch *swIsBlend;
@property (weak, nonatomic) IBOutlet UITextView *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblVendor;
@property (weak, nonatomic) IBOutlet UITextView *txtWebsite;
@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIView *viewRelatedRemedies;
@property (weak, nonatomic) IBOutlet UITableView *RelatedRemediesTable;



- (IBAction)tbDescription:(id)sender;
- (IBAction)tbRelatedRemedies:(id)sender;
- (IBAction)swUpdateStockStatus:(id)sender;
- (IBAction)swUpdateBlendStatus:(id)sender;
- (IBAction)btnClose:(id)sender;
- (IBAction)btnEdit:(id)sender;

@end
