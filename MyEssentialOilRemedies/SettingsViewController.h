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
#import "MYSettings.h"
#import "FormFunctions.h"
#import "DatabaseManagement.h"
#import "DBUpgrade.h"

@interface SettingsViewController : UIViewController <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnClearOils;
@property (weak, nonatomic) IBOutlet UIButton *btnClearRemedies;
@property (weak, nonatomic) IBOutlet UIButton *btnRestoreFactory;
@property (weak, nonatomic) IBOutlet UIButton *btnBackuptoiCloud;
@property (weak, nonatomic) IBOutlet UIButton *btnRestoreFromiCloud;
@property (weak, nonatomic) IBOutlet UIButton *btnDoiTunesBackup;


- (IBAction)btnClearOils:(id)sender;
- (IBAction)btnClearRemedies:(id)sender;
- (IBAction)btnRestoreFactory:(id)sender;
- (IBAction)btnBackuptoiCloud:(id)sender;
- (IBAction)btnRestoreFromiCloud:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewMain;

@property (weak, nonatomic) IBOutlet UILabel *lblAppVersion;
@property (weak, nonatomic) IBOutlet UILabel *lblDBVersion;

@end
