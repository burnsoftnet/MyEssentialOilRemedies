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
    //NSString *dbPathString = [myObj getDatabasePath:@MYDBNAME];
    //[[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:@"2"];
    //[[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:@"3"];
     // [[self navigationController] tabBar].badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)[myOilCollection count]];
}
#pragma mark Did Recieve Memory Warning
// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
