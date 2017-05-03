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
#import "MySettings.h"
#import "FormFunctions.h"
#import "DatabaseManagement.h"

@interface SettingsiTunesBackupRestoreViewController : UIViewController <UIAlertViewDelegate,UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

#pragma mark Backup Database for iTunes
//This will make a copy of the database for iTunes to to retrived or in case you need to restore.
//This will make a backup file meo_datetime.bak
- (IBAction)btnBackUpDatabaseForiTunes:(id)sender;

@end
