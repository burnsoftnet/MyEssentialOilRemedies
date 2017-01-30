//
//  SettingsViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 8/30/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "BurnSoftDatabase.h"
#import "MySettings.h"
#import "FormFunctions.h"

@interface SettingsViewController : UIViewController <UIAlertViewDelegate,UITableViewDataSource, UITableViewDelegate>
- (IBAction)btnClearOils:(id)sender;
- (IBAction)btnClearRemedies:(id)sender;
- (IBAction)btnRestoreFactory:(id)sender;
- (IBAction)btnBackUpDatabaseForiTunes:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UILabel *lblAppVersion;
@property (weak, nonatomic) IBOutlet UILabel *lblDBVersion;

@end
