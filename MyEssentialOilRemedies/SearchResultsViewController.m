//
//  SearchResultsViewController.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 9/22/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "VIEW_SingleRemedyViewController.h"


@interface SearchResultsViewController ()
@property (nonatomic, strong) NSArray *searchResults;
@end

@implementation SearchResultsViewController
{
    NSString *dbPathString;
    NSString *SelectedCellID;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSettings];
    //TODO: When you hit cancle on the search form, it blanks out and you have to leave the view and go back to bring it back to normal.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    NSString *myName = cell.textLabel.text;
    [self findLocationofSelection:myName];
}
-(void)findLocationofSelection:(NSString *) myValue
{
    SearchDatabase *myObj = [SearchDatabase new];
    FormFunctions *myObjF = [FormFunctions new];
    NSString *errorMsg = [NSString new];
    NSInteger iOil = [myObj isOilbyName:myValue databasePath:dbPathString ErrorMessage:&errorMsg];
    NSInteger iRemedy = [myObj isRemedybyName:myValue databasePath:dbPathString ErrorMessage:&errorMsg];
    BOOL isOil = NO;
    BOOL isRemedy = NO;
    NSString *myMsg = [NSString new];
    if (iOil > 0 ) {
        isOil = YES;
    }
    if (iRemedy > 0 )
    {
        isRemedy = YES;
    }
    
    if (isOil && !isRemedy)
    {
        //What was selected is an Oil and not a Remedy so Prep View Oil Sheet
        SelectedCellID = [NSString stringWithFormat:@"%ld",(long) iOil];
        
        [self performSegueWithIdentifier:@"segueViewOilFromSearch" sender:self];
    } else if (!isOil && isRemedy)
    {
        //What was selected is a Remedy and not an Oil, so Prep View Rememdy Sheet
        SelectedCellID = [NSString stringWithFormat:@"%ld",(long) iRemedy];
        
        [self performSegueWithIdentifier:@"segueViewRemedyFromSearch" sender:self];

    } else if (isOil && isRemedy)
    {
        //I don't know what the fuck you picked
        myMsg = [NSString stringWithFormat:@"%@ is something!",myValue];
        [myObjF sendMessage:myMsg MyTitle:myMsg ViewController:self];
    }
}
-(void) loadSettings
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    // extract array from observer
    self.searchResults = [(NSArray *)object valueForKey:@"results"];
    [self.tableView reloadData];
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier =@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSString *currentValue = [self.searchResults objectAtIndex:[indexPath row]];
    [[cell textLabel]setText:currentValue];
    return cell;
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueViewOilFromSearch"]) {
        VIEW_OilDetailsViewController *destViewController = (VIEW_OilDetailsViewController *)segue.destinationViewController;
        destViewController.OID = SelectedCellID;
    } else if ([segue.identifier isEqualToString:@"segueViewRemedyFromSearch"]){
        VIEW_RemedyViewController *destViewController = (VIEW_RemedyViewController *)segue.destinationViewController;
        destViewController.isFromSearch = YES;
        destViewController.RID = SelectedCellID;
    }

}
@end
