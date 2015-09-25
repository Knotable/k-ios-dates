//
//  ThreadSelectionViewController.m
//  Knotable
//
//  Created by Agus Guerra on 6/2/15.
//
//

#import "ThreadSelectionViewController.h"
#import "ThreadSelectionTableViewCell.h"
#import "DataManager.h"
#import "AppDelegate.h"
#import "DataManager.h"
#import "TopicInfo.h"
#import "AccountEntity.h"
#import "UserEntity.h"
#import <CoreData/CoreData.h>

@interface ThreadSelectionViewController () <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *threadsTableView;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSArray *topics;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic) NSInteger numberOfThreads;

@end

@implementation ThreadSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInView:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [self loadCoreDataRelatedProperties];
    [self registerTableViewCell];
}

-(void)tapInView:(UITapGestureRecognizer *) tapGestureRecognizer{
    if(self.searchBar.showsCancelButton){
        [self.searchBar setShowsCancelButton:NO animated:YES];
        [self.searchBar resignFirstResponder];
        self.threadsTableView.allowsSelection = YES;
        self.threadsTableView.scrollEnabled = YES;
        [self.threadsTableView reloadData];
    }
}

- (void)registerTableViewCell {
    [self.threadsTableView registerNib:[UINib nibWithNibName:@"ThreadSelectionTableViewCell" bundle:nil] forCellReuseIdentifier:@"ThreadSelectionTableViewCell"];
}

- (void)loadCoreDataRelatedProperties {
    self.managedObjectContext = [AppDelegate sharedDelegate].managedObjectContext;
    NSString *sortFields   =  @"order:NO,isPlaceHold:NO,updated_time:NO";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@) && isPlaceHold != %d", @(NO), kInvalidatePosition];

    self.fetchedResultsController.delegate = self;
    self.fetchedResultsController = [TopicsEntity MR_fetchAllSortedBy:sortFields ascending:YES withPredicate:predicate groupBy:nil delegate:self];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.threadsTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.threadsTableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.threadsTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.threadsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(ThreadSelectionTableViewCell *)[self.threadsTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.threadsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.threadsTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(![self.searchBar.text isEqualToString:@""]){
        return 1;
    }else{
        return [[self.fetchedResultsController sections] count];
    }
    
}

- (void)selectTopicInIndexPath:(NSIndexPath *)indexPath {
    
    if([self.searchBar.text isEqualToString:@""]){
        self.selectedTopic = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }else{
        self.selectedTopic = [self.searchResults objectAtIndex:indexPath.row];
    }
    
    [self.delegate threadWithTopicIdSelected:self.selectedTopic];
    [self navigateBack];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(![self.searchBar.text isEqualToString:@""]){
        return self.searchResults.count;
    }else{
        NSArray *sections = [self.fetchedResultsController sections];
        id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        
        NSInteger numberOfThreads = [sectionInfo numberOfObjects];
        if (!self.selectedTopic) {
            numberOfThreads++;
        }
        
        self.numberOfThreads = numberOfThreads;
        return numberOfThreads;
    }
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    self.threadsTableView.allowsSelection = NO;
    self.threadsTableView.scrollEnabled = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.threadsTableView.allowsSelection = YES;
    self.threadsTableView.scrollEnabled = YES;
    [self.threadsTableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self filterContentForSearchText:searchBar.text];    
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"topic contains[c] %@", searchText];
    self.searchResults = [[self.fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:resultPredicate];
    [self.threadsTableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ThreadSelectionTableViewCell *cell = (ThreadSelectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ThreadSelectionTableViewCell" forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:cell atIndexPath:indexPath];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if(![self.searchBar.text isEqualToString:@""]){
        TopicsEntity *topicEntity = [self.searchResults objectAtIndex:indexPath.row];
        [(ThreadSelectionTableViewCell *)cell initWithTitle:topicEntity.topic];
        
        if ((!self.selectedTopic && !topicEntity) || ([self.selectedTopic.topic_id isEqualToString:topicEntity.topic_id])) {
            [cell setSelected:YES];
        }
        
    }else{
        TopicsEntity *topicEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [(ThreadSelectionTableViewCell *)cell initWithTitle:topicEntity.topic];
        
        if ((!self.selectedTopic && !topicEntity) || ([self.selectedTopic.topic_id isEqualToString:topicEntity.topic_id])) {
            [cell setSelected:YES];
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self selectTopicInIndexPath:indexPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navigateBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backButtonTapped:(id)sender {
    [self navigateBack];
}

@end
