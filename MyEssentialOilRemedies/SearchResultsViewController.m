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

#pragma mark On Form Load
/*! @brief When form first loads
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSettings];
    [FormFunctions setBackGroundImage:self.view];
}

#pragma mark Did Recieve Memory Warning
/*! @brief when you are fucking with the memory
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table Set Sections
/*! @brief set the sections in the table
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark Table Set Number of Rows
/*! @brief set the number of rows int he table
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

#pragma mark Table Row Selected
/*! @brief actions to take when a row has been selected.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    NSString *myName = cell.textLabel.text;
     [FormFunctions setBackGroundImage:cell.contentView];
    [self findLocationofSelection:myName];
}

#pragma mark Find Location Of Selection
/*! @brief Determine what was clicked by searching the oils and remedy tables to see where is lies
 */
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

#pragma mark Load Settings
/*! @brief This will load the setting for the for as well as database and set the borders for the textboxes and text views.
 */
-(void) loadSettings
{
    dbPathString = [BurnSoftDatabase getDatabasePath:@MYDBNAME];
}

#pragma mark Observe Value for Path
/*! @brief extract array from observer
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{    
    self.searchResults = [(NSArray *)object valueForKey:@"results"];
    [self.tableView reloadData];
}

#pragma mark Table Set Cell Data
/*! @brief set the cell data by use of an array
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier =@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    [FormFunctions setBackGroundImage:cell.contentView];
    
    NSString *currentValue = [self.searchResults objectAtIndex:[indexPath row]];
    [[cell textLabel]setText:currentValue];
    return cell;
}
#pragma mark Prepare for Segue
/*! @brief Actions to take before switching to the next window
    @discussion This is the section that is activated when you search for something and then click on the results.
                if you scroll through the list without searching and click on something, it uses something else.
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueViewOilFromSearch"]) {
        VIEW_OilDetailsViewController *destViewController = (VIEW_OilDetailsViewController *)segue.destinationViewController;
        destViewController.OID = SelectedCellID;
    } else if ([segue.identifier isEqualToString:@"segueViewRemedyFromSearch"]){
        VIEW_RemedyViewController *destViewController = (VIEW_RemedyViewController *)segue.destinationViewController;
        destViewController.RID = SelectedCellID;

        UIViewController *dvc = segue.destinationViewController;

        if (@available(iOS 13.0, *)) {
            [dvc setModalPresentationStyle: UIModalPresentationAutomatic];
            [self.navigationController pushViewController:dvc animated:YES];
        } else {
            UIPopoverPresentationController *controller = dvc.popoverPresentationController;

                    if (controller) {
                        controller.delegate = nil;
                    }
        }
    }

}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {

    return UIModalPresentationNone;
}

@end
