//
//  MainStartViewController.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/23/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//
//  StoryboardiD: MainController

#import "MainStartViewController.h"

@interface MainStartViewController ()

@end

@implementation MainStartViewController
#pragma mark On Form Load
//When form first loads
- (void)viewDidLoad {
    [super viewDidLoad];
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    [myObj copyDbIfNeeded:@MYDBNAME MessageHandler:nil];
    DBUpgrade *myDB = [DBUpgrade new];
    [myDB checkDBVersionAgainstExpectedVersion];
    [DatabaseManagement startiCloudSync];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkInBox) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(checkInBox) userInfo:nil repeats:YES];
    
    myObj = nil;
    myDB = nil;
    //TODELETE
    //ISLITE = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ISLITE"];
    //LITE_LIMIT = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"LITE_LIMIT"];
    //BOOL IsFree = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ISLITE"];
    //NSNumber *FreeLimit = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"LITE_LIMIT"];
    
    //NSLog(@"%@ : %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ISLITE"], FreeLimit);
    
}


#pragma mark View Did Disappear
//Action to take when the view disappears, more of cleanup
-(void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark Check InBox
//Check for files to process from the inbox
-(void) checkInBox
{
    if ([BurnSoftGeneral newFilesfoundProcessing]){
        [AirDropHandler processAllInBoxFilesFromViewController:self];
    }
}

#pragma mark Did Recieve Memory Warning
// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
