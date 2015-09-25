//
//  ContactsListViewController.m
//  Example
//
//  Created by wuli on 2/9/15.
//  Copyright (c) 2015 smart4c. All rights reserved.
//

#import "ContactsListViewController.h"
#import "ContactsListCell.h"

@interface ContactsListViewController ()<UISearchBarDelegate,UISearchDisplayDelegate>
@property (nonatomic, strong) NSMutableArray *searchResults;
@end

@implementation ContactsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchResults = [NSMutableArray new];
    self.tableView.rowHeight = 69;
    [self addSearchBarAndSearchDisplayController];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
//===============================================
#pragma mark -
#pragma mark Search Display Controller
//===============================================

- (void)addSearchBarAndSearchDisplayController {
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [searchBar sizeToFit];
    searchBar.delegate = self;
    
    self.tableView.tableHeaderView = searchBar;
    
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    self.searchController = searchDisplayController;
}

//===============================================
#pragma mark -
#pragma mark Helper
//===============================================

- (void)configureTableView:(UITableView *)tableView {
    
    tableView.separatorInset = UIEdgeInsetsZero;
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
    
    UIView *tableFooterViewToGetRidOfBlankRows = [[UIView alloc] initWithFrame:CGRectZero];
    tableFooterViewToGetRidOfBlankRows.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = tableFooterViewToGetRidOfBlankRows;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return [self.dataArray count];
    }
    else {
        return [self.searchResults count];
    }
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68.0f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ContactsListCell";
    
    ContactsListCell *prototypeCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!prototypeCell) {
        prototypeCell = [[ContactsListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellIdentifier];
    }
    prototypeCell.contentDic = self.dataArray[indexPath.row];
    [prototypeCell setNeedsUpdateConstraints];
    [prototypeCell updateConstraintsIfNeeded];
    [prototypeCell.contentView setNeedsLayout];
    [prototypeCell.contentView layoutIfNeeded];
    
    CGFloat height = [prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize].height;

    return height;
    
}
-(void)resetCell:(ContactsListCell *)cell
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.tableView isEqual:tableView]) {
        
        static NSString *cellIdentifier = @"ContactsListCell";
        
        ContactsListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ContactsListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:cellIdentifier];
            [self resetCell:cell];
        }
        cell.contentDic = self.dataArray[indexPath.row];
        return cell;
    } else {
        
        static NSString *cellIdentifier = @"searchContactsListCell";
        
        ContactsListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ContactsListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:cellIdentifier];
            [self resetCell:cell];
        }
        cell.contentDic = self.searchResults[indexPath.row];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    KnotesViewController *vc = [[KnotesViewController alloc] init];
//    vc.meteor = self.meteor;
//    NSDictionary *dic = nil;
//    if ([self.tableView isEqual:tableView]) {
//        dic = self.dataArray[indexPath.row];
//    } else {
//        dic = self.searchResults[indexPath.row];
//    }
//    vc.topic_id = dic[@"_id"];
//    [self.navigationController pushViewController:vc animated:YES];
}

//===============================================
#pragma mark -
#pragma mark UISearchDisplayDelegate
//===============================================

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    NSLog(@"🔦 | will begin search");
}
- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    NSLog(@"🔦 | did begin search");
}
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    NSLog(@"🔦 | will end search");
}
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    NSLog(@"🔦 | did end search");
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"🔦 | did load table");
    [self configureTableView:tableView];
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"🔦 | will unload table");
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"🔦 | will show table");
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"🔦 | did show table");
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"🔦 | will hide table");
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"🔦 | did hide table");
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSLog(@"🔦 | should reload table for search string?");
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchString];
    
    //    self.searchResults = [self.names filteredArrayUsingPredicate:predicate];
    [self.searchResults removeAllObjects];
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    
    for (NSDictionary *dic  in self.dataArray)
    {
        NSString *subject = dic[@"username"];
        if(subject) {
            
        }
        NSString *original_subject= dic[@"fullname"];
        if (original_subject) {
        }
        NSString *changed_subject = dic[@"emails"];
        if (changed_subject) {
        }
        
        NSString *searchAgainst = [NSString stringWithFormat:@"%@^%@^%@",subject,original_subject,changed_subject];
        
        NSRange foundRange = [searchAgainst rangeOfString:searchString options:searchOptions range:NSMakeRange(0, searchAgainst.length)];
        
        if (foundRange.length > 0)
        {
            [self.searchResults addObject:dic];
        }
    }
    
    
    return YES;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    NSLog(@"🔦 | should reload table for search scope?");
    return YES;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
