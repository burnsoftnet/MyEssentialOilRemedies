//
//  VIEW_SingleRemedyViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 11/7/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//
// for regular size is 400x800
#import <UIKit/UIKit.h>
#import "MYSettings.h"
#import "OilRemedies.h"
#import <sqlite3.h>
#import "FormFunctions.h"
#import "PopUpOilSearchViewController.h"
#import "LIST_OilRemediesViewController.h"
#import "EDIT_RemedyViewController.h"


@interface VIEW_SingleRemedyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong,nonatomic) NSString *RID;
@property (assign) BOOL isFromSearch;
@property (strong,nonatomic)NSMutableArray *myOils;
@property (strong,nonatomic) NSString *myremedyName;
@property (strong,nonatomic) NSString *myremedyDescription;
@property (strong,nonatomic) NSString *myUses;

@property (weak, nonatomic) IBOutlet UILabel *lblProblem;
@property (weak, nonatomic) IBOutlet UITextView *lblDescription;
@property (weak, nonatomic) IBOutlet UITextView *lblUses;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tbSave;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tbEdit;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tbClose;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property (weak, nonatomic) IBOutlet UIView *ViewDescription;
@property (weak, nonatomic) IBOutlet UIView *ViewOils;
@property (weak, nonatomic) IBOutlet UIView *ViewUses;

- (IBAction)tbOils:(id)sender;
- (IBAction)tbUses:(id)sender;
- (IBAction)tbSave:(id)sender;
- (IBAction)tbEdit:(id)sender;
- (IBAction)tbDescription:(id)sender;
- (IBAction)tbClose:(id)sender;

#pragma mark View popup WIndow for details
- (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController;

@end
