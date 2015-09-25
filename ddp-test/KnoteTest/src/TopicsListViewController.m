//
//  TopicsListViewController.m
//  Example
//
//  Created by wuli on 2/5/15.
//  Copyright (c) 2015 smart4c. All rights reserved.
//

#import "TopicsListViewController.h"
#import "LoginViewCell.h"
#import "KnotesViewController.h"
#import "Masonry.h"

@interface TopicsListViewController ()<UISearchBarDelegate,UISearchDisplayDelegate>
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation TopicsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchResults = [NSMutableArray new];
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(void)resetCell:(LoginViewCell *)cell
{
    cell.funName.font = [UIFont systemFontOfSize:12];
    cell.detailLabel.font = [UIFont systemFontOfSize:12];
    cell.timeLabel.font = [UIFont systemFontOfSize:12];
    [cell.funName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(2));
        make.top.equalTo(@(2));
        make.right.equalTo(@(0));
        make.height.equalTo(cell.timeLabel);
    }];

    [cell.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(2));
        make.right.equalTo(@(0));
        make.top.equalTo(cell.funName.mas_bottom);
        make.bottom.equalTo(cell.timeLabel.mas_top);
    }];
    cell.timeLabel.textAlignment = NSTextAlignmentLeft;
    [cell.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(2));
        make.right.equalTo(@(0));
        make.top.equalTo(cell.detailLabel.mas_bottom);
        make.height.equalTo(cell.funName);
        make.bottom.equalTo(@(-2));
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.tableView isEqual:tableView]) {
        
        static NSString *cellIdentifier = @"list";
        
        LoginViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[LoginViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:cellIdentifier];
            [self resetCell:cell];
        }
        NSString *subject = self.dataArray[indexPath.row][@"subject"];
        if(subject) {
            cell.funName.text = [NSString stringWithFormat:@"subject:%@",subject];
            NSRange range = [subject rangeOfString:@"dogfood"];
            if (range.location != NSNotFound) {
                cell.backgroundColor = [UIColor redColor];
            } else {
                cell.backgroundColor = [UIColor clearColor];
            }
        }
        NSString *original_subject= self.dataArray[indexPath.row][@"original_subject"];
        if (original_subject) {
            cell.detailLabel.text = [NSString stringWithFormat:@"original:%@",original_subject];
        }
        NSString *changed_subject = self.dataArray[indexPath.row][@"changed_subject"];
        if (changed_subject) {
            cell.timeLabel.text = [NSString stringWithFormat:@"changed:%@",changed_subject];
        }
        return cell;
    } else {
        
        static NSString *cellIdentifier = @"search1";
        
        LoginViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[LoginViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:cellIdentifier];
            [self resetCell:cell];
        }
        NSString *subject = self.searchResults[indexPath.row][@"subject"];
        if(subject) {
            cell.funName.text = [NSString stringWithFormat:@"subject:%@",subject];
            NSRange range = [subject rangeOfString:@"dogfood"];
            if (range.location != NSNotFound) {
                cell.backgroundColor = [UIColor redColor];
            } else {
                cell.backgroundColor = [UIColor clearColor];
            }
        }
        NSString *original_subject= self.searchResults[indexPath.row][@"original_subject"];
        if (original_subject) {
            cell.detailLabel.text = [NSString stringWithFormat:@"original:%@",original_subject];
        }
        NSString *changed_subject = self.searchResults[indexPath.row][@"changed_subject"];
        if (changed_subject) {
            cell.timeLabel.text = [NSString stringWithFormat:@"changed:%@",changed_subject];
        }
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    KnotesViewController *vc = [[KnotesViewController alloc] init];
    vc.meteor = self.meteor;
    NSDictionary *dic = nil;
    if ([self.tableView isEqual:tableView]) {
        dic = self.dataArray[indexPath.row];
    } else {
        dic = self.searchResults[indexPath.row];
    }
    vc.topic_id = dic[@"_id"];
    [self.navigationController pushViewController:vc animated:YES];
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
        NSString *subject = dic[@"subject"];
        if(subject) {
           
        }
        NSString *original_subject= dic[@"original_subject"];
        if (original_subject) {
        }
        NSString *changed_subject = dic[@"changed_subject"];
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
