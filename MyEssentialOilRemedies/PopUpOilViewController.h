//
//  PopUpOilViewController.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 9/13/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OilLists.h"
#import "MYSettings.h"
#import "FormFunctions.h"
#import "BurnSoftDatabase.h"
#import <sqlite3.h>

@interface PopUpOilViewController : UIViewController
@property (strong, nonatomic) NSString *myOilName;
- (IBAction)btnClose:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblOilName;
@property (weak, nonatomic) IBOutlet UITextView *lblDescription;

@end
