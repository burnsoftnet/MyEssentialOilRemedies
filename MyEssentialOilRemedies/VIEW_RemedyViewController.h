//
//  VIEW_RemedyViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/3/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#include "TargetConditionals.h"
#if TARGET_OS_OSX
  // Put CPU-independent macOS code here.
  #if TARGET_CPU_ARM64
    // Put 64-bit Apple silicon macOS code here.
  #elif TARGET_CPU_X86_64
    // Put 64-bit Intel macOS code here.
  #endif
#elif TARGET_OS_MACCATALYST
   // Put Mac Catalyst-specific code here.
#elif TARGET_OS_IOS
    #import <UIKit/UIKit.h>
#endif
#import "MYSettings.h"
#import "OilRemedies.h"
#import <sqlite3.h>
#import "FormFunctions.h"
#import "PopUpOilViewController.h"
#import "LIST_OilRemediesViewController.h"
#import "ActionClass.h"
#import "Parser.h"
#import "AirDropHandler.h"

@interface VIEW_RemedyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong,nonatomic) NSString *RID;

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

#pragma mark View popup WIndow for details
- (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController;
@end
