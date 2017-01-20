//
//  SearchViewController.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 9/17/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultsViewController.h"

@interface SearchViewController () <UISearchResultsUpdating, UISearchControllerDelegate>
@property (nonatomic,strong) NSMutableArray *myCombinedResults;
@property (strong, nonatomic) UISearchController *controller;
@property (strong, nonatomic) NSArray *results;
@property (strong, nonatomic) NSMutableArray *data;
@end

@implementation SearchViewController
{
    NSString *dbPathString;
    NSString *SelectedCellID;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //TODO: Finish figuring this out
    [self setupGlobalVars];

    
    SearchResultsViewController *searchResults = (SearchResultsViewController *)self.controller.searchResultsController;
    [self addObserver:searchResults forKeyPath:@"results" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupGlobalVars
{
    BurnSoftDatabase *myObj = [BurnSoftDatabase new];
    dbPathString = [myObj getDatabasePath:@MYDBNAME];
}
- (NSMutableArray *) myCombinedResults
{
    //In the sample code, myCombinedResults replaced data
    if (!_myCombinedResults)
    {
      _myCombinedResults = [NSMutableArray new];
        _myCombinedResults = [self combineOilsandRemedies];
    }
    return _myCombinedResults;
}
-(NSMutableArray *) combineOilsandRemedies
{
    SearchDatabase *myObj = [SearchDatabase new];
    return [myObj getAllSearchDataSimple:dbPathString ErrorMessage:nil];
    
}

#pragma mark Find Loaction of Cell Value that was picked
//NOTE: This will get the cell calue that was touched and pass it through and figure out is it is oil or a remedy
//ALSO_USED_AT: SearchResultsViewController.m
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
    //TODO: This section is broken when zipping to form
    if (isOil && !isRemedy)
    {
        //What was selected is an Oil and not a Remedy so Prep View Oil Sheet
        SelectedCellID = [NSString stringWithFormat:@"%ld",(long) iOil];

        VIEW_OilDetailsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewOilDetailsFromSearch"];
        controller.OID = SelectedCellID;
        [self.navigationController pushViewController:controller animated:YES];

    } else if (!isOil && isRemedy)
    {
        //What was selected is a Remedy and not an Oil, so Prep View Rememdy Sheet
        SelectedCellID = [NSString stringWithFormat:@"%ld",(long) iRemedy];
        
        VIEW_SingleRemedyViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"RemedyDetailsViewControllerFromSearchSingle"];
        controller.RID = SelectedCellID;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (isOil && isRemedy)
    {
        //I don't know what the fuck you picked
        myMsg = [NSString stringWithFormat:@"%@ is something!",myValue];
        [myObjF sendMessage:myMsg MyTitle:myMsg ViewController:self];
    }
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    NSString *myName = cell.textLabel.text;
    [self findLocationofSelection:myName];
}

- (UISearchController *)controller {
    
    if (!_controller) {
        
        // instantiate search results table view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
        SearchResultsViewController *resultsController = [storyboard instantiateViewControllerWithIdentifier:@"SearchResults"];
        
        // create search controller
        _controller = [[UISearchController alloc]initWithSearchResultsController:resultsController];
        _controller.searchResultsUpdater = self;
        
        // optional: set the search controller delegate
        _controller.delegate = self;
        
    }
    return _controller;
}

- (BOOL) tableView:(UITableView *) tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myCombinedResults.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [_myCombinedResults objectAtIndex:indexPath.row];

    return cell;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    // filter the search results
    //this might be the search function tha you need
    NSString *searchFormat = [NSString new];
    //searchFormat =@"SELF.SearchName contains [cd] %@";
    //searchFormat =@"SELF.SearchName LIKE [cd] %@";
    // =@"%K LIKE[cd] %@";
    searchFormat = @"%@ contains[c] %@";
    NSString *lookFor = self.controller.searchBar.text;
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains[c] %@",lookFor];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains [cd] %@",lookFor];
    //NSArray *data =[NSArray arrayWithArray:_myCombinedResults];
    self.results = [_myCombinedResults filteredArrayUsingPredicate:predicate];
    
    //NSLog(@"Search Results are: %@", [self.results description]);
}

- (IBAction)btnSearch:(id)sender {
    // present the search controller
    [self presentViewController:self.controller animated:YES completion:nil];
}
@end
