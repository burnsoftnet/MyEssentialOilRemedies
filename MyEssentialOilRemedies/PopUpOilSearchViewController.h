//
//  PopUpOilSearchViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 1/1/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OilLists.h"
#import "MySettings.h"
#import "FormFunctions.h"
#import "BurnSoftDatabase.h"
#import <sqlite3.h>

@interface PopUpOilSearchViewController : UIViewController
@property (strong, nonatomic) NSString *myOilName;
- (IBAction)btnClose:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblOilName;
@property (weak, nonatomic) IBOutlet UITextView *lblDescription;
@end
