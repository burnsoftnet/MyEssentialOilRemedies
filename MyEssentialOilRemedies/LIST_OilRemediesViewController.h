//
//  LIST_OilRemediesViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OilRemedies.h"
#import "BurnSoftDatabase.h"
#import "MYSettings.h"
#import "FormFunctions.h"
#import "VIEW_RemedyViewController.h"
#import "EDIT_RemedyViewController.h"
#import "OilLists.h"

@interface LIST_OilRemediesViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
//Actions
- (IBAction)refresh:(UIRefreshControl *)sender;
@end
