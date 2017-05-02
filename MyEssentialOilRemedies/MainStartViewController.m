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
}
#pragma mark Did Recieve Memory Warning
// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)handleOpenURL:(NSURL *)url {
    //[self.navigationController popToRootViewControllerAnimated:YES];
    //ScaryBugDoc *newDoc = [[[ScaryBugDoc alloc] init] autorelease];
    //if ([newDoc importFromURL:url]) {
    //    [self addNewDoc:newDoc];
    //}
    FormFunctions *myObj = [FormFunctions new];
    NSString *myPath = [NSString stringWithFormat:@"%@",url];
    [myObj sendMessage:[NSString stringWithFormat:@"got file %@",myPath] MyTitle:@"Got File" ViewController:self];
    
    // AIR DOP TESTING!!
    
    //NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *docPath = [path objectAtIndex:0];
    //NSString *sAns = [docPath stringByAppendingPathComponent:@"OilDetails.meo"];
    
    //[AirDropHandler OpenFilebyPath:myPath ViewController:self];
    
    //END AIR DROP TESTING
}
@end
