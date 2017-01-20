//
//  SearchViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 9/17/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "BurnSoftDatabase.h"
#import "MySettings.h"
#import "FormFunctions.h"
//#import "OilRemedies.h"
//#import "OilLists.h"
#import "SearchDatabase.h"

#import "VIEW_OilDetailsViewController.h"
#import "VIEW_RemedyViewController.h"
#import "VIEW_SingleRemedyViewController.h"
#import "VIEW_OilDetailsViewController.h"

@interface SearchViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
//<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

/*
@property (nonatomic,strong) NSString *SearchName;
@property (nonatomic,strong) NSString *SearchType;
@property (assign) int SearchID;
*/
- (IBAction)btnSearch:(id)sender;

@end
