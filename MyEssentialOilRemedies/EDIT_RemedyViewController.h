//
//  EDIT_RemedyViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/3/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySettings.h"
#import "FormFunctions.h"
#import "OilRemedies.h"
#import "BurnSoftDatabase.h"
#import "BurnSoftGeneral.h"
#import <sqlite3.h>
#import "LIST_OilRemediesViewController.h"

@interface EDIT_RemedyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
//Global Var
@property (strong,nonatomic) NSString *RID;
@property (assign) BOOL isFromSearch;
@property (strong, nonatomic) NSMutableArray *myOils;
@property (strong,nonatomic) NSString *myremedyName;
@property (strong,nonatomic) NSString *myremedyDescription;
@property (strong,nonatomic) NSString *myUses;

//Form Fields
@property (weak, nonatomic) IBOutlet UITextField *txtOilName;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextView *txtUses;
@property (weak, nonatomic) IBOutlet UITextField *txtRemedy;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
- (IBAction)btnAddOil:(id)sender;

//Tool Bar Buttons
- (IBAction)tbOils:(id)sender;
- (IBAction)tbUses:(id)sender;
- (IBAction)tbDescription:(id)sender;
- (IBAction)tbUpdate:(id)sender;


@end
