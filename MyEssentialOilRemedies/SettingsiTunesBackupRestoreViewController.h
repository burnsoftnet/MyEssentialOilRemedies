//
//  SettingsiTunesBackupRestoreViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 1/31/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "BurnSoftDatabase.h"
#import "MYSettings.h"
#import "FormFunctions.h"
#import "DatabaseManagement.h"

@interface SettingsiTunesBackupRestoreViewController : UIViewController <UIAlertViewDelegate,UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

#pragma mark Backup Database for iTunes
- (IBAction)btnBackUpDatabaseForiTunes:(id)sender;

@end
