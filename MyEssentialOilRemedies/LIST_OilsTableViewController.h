//
//  LIST_OilsTableViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BurnSoftDatabase.h"
#import "VIEW_OilDetailsViewController.h"
#import "MYSettings.h"
#import "FormFunctions.h"
#import "AirDropHandler.h"

@interface LIST_OilsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
- (IBAction)refresh:(UIRefreshControl *)sender;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end
