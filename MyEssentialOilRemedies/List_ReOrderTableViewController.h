//
//  List_ReOrderTableViewController.h
//  My Essential Oil Remedies
//
//  Created by burnsoft on 6/30/18.
//  Copyright © 2018 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BurnSoftDatabase.h"
#import "VIEW_OilDetailsViewController.h"
#import "MYSettings.h"
#import "FormFunctions.h"
#import "OilLists.h"

@interface List_ReOrderTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
- (IBAction)refresh:(UIRefreshControl *)sender;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
- (void) refreshData;
@end
