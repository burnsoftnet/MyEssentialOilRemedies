//
//  Add_RemedyViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/3/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYSettings.h"
#import "FormFunctions.h"
#import "BUrnSoftDatabase.h"
#import "BurnSoftGeneral.h"
#import <sqlite3.h>
#import "OilRemedies.h"
#import "LIST_OilRemediesViewController.h"

@interface Add_RemedyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
//Class Properties
@property (nonatomic, strong) NSString *oilName;
@property (strong,nonatomic)NSMutableArray *myOils;


//View Properties
@property (weak, nonatomic) IBOutlet UIView *viewDescription;
@property (weak, nonatomic) IBOutlet UIView *viewOils;
@property (weak, nonatomic) IBOutlet UIView *viewUses;

//TabBar Buttongs
- (IBAction)tbUses:(id)sender;
- (IBAction)tbSave:(id)sender;
- (IBAction)tbOils:(id)sender;
- (IBAction)tbDescription:(id)sender;
//Form Properties
@property (weak, nonatomic) IBOutlet UITextView *txtUses;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextField *RemedyName;
@property (weak, nonatomic) IBOutlet UITextView *RemedyDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtOilName;
- (IBAction)btnAddOil:(id)sender;

@end
