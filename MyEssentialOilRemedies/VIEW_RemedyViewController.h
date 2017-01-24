//
//  VIEW_RemedyViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/3/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYSettings.h"
#import "OilRemedies.h"
#import <sqlite3.h>
#import "FormFunctions.h"
#import "PopUpOilViewController.h"
#import "LIST_OilRemediesViewController.h"

@interface VIEW_RemedyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong,nonatomic) NSString *RID;
//@property (assign) BOOL isFromSearch;
@property (strong,nonatomic)NSMutableArray *myOils;
//possible delete
//@property (strong,nonatomic) NSString *myremedyName;
//@property (strong,nonatomic) NSString *myremedyDescription;
//@property (strong,nonatomic) NSString *myUses;

//Views
@property (weak, nonatomic) IBOutlet UIView *viewDescription;
@property (weak, nonatomic) IBOutlet UIView *viewOils;
@property (weak, nonatomic) IBOutlet UIView *viewUses;

@property (weak, nonatomic) IBOutlet UILabel *lblProblem;
@property (weak, nonatomic) IBOutlet UITextView *lblDescription;
@property (weak, nonatomic) IBOutlet UITextView *lblUses;

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *tbSave;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tbClose;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;


- (IBAction)tbOils:(id)sender;
- (IBAction)tbUses:(id)sender;
- (IBAction)tbEdit:(id)sender;
- (IBAction)tbDescription:(id)sender;
- (IBAction)tbClose:(id)sender;

- (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController;
@end
