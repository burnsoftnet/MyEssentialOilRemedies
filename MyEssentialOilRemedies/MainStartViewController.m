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
}
#pragma mark Did Recieve Memory Warning
//when you are fucking with the memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
