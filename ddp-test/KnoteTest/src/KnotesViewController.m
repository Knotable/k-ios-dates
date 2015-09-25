//
//  KnotesViewController.m
//  Example
//
//  Created by wuli on 2/5/15.
//  Copyright (c) 2015 smart4c. All rights reserved.
//

#import "KnotesViewController.h"
#import "KnotesViewCell.h"

#define METEORCOLLECTION_KNOTE_TOPIC            @"topic"
#define METEORCOLLECTION_KNOTE_PINNED           @"pinnedKnotesForTopic"
#define METEORCOLLECTION_KNOTE_ARCHIVED         @"archivedKnotesForTopic"
#define METEORCOLLECTION_KNOTE_REST             @"allRestKnotesByTopicId"

@interface KnotesViewController ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *contentArray;

@end

@implementation KnotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray new];
    self.contentArray = [NSMutableArray new];
    [self addSubKnotes];
    self.tableView.scrollEnabled = NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
-(void)addSubKnotes
{
    self.knotesDate = [NSDate date];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"knotes_added" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messages_added" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"topic_ready" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contacts_added" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NumberOfKnotesOnCurrentPad_added" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NumberOfArchivedKnotesOnCurrentPad_added" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(knotesAdded:)
                                                 name:@"knotes_added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messagesAdded:)
                                                 name:@"messages_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactsAdded:)
                                                 name:@"contacts_added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(knotableEventsAdded:)
                                                 name:@"knotable_events_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicReady:)
                                                 name:@"topic_ready"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(numberOfKnotesOnCurrentPadAdded:)
                                                 name:@"NumberOfKnotesOnCurrentPad_added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(numberOfArchivedKnotesOnCurrentPadAdded:)
                                                 name:@"NumberOfArchivedKnotesOnCurrentPad_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pinnedKnotesForTopicReady:)
                                                 name:@"pinnedKnotesForTopic_ready"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NumberOfPinnedKnotesOnCurrentPadAdded:)
                                                 name:@"NumberOfPinnedKnotesOnCurrentPad_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(archivedKnotesForTopicReady:)
                                                 name:@"archivedKnotesForTopic_ready"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(allRestKnotesByTopicIdReady:)
                                                 name:@"allRestKnotesByTopicId_ready"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NumberOfRestKnotesOnCurrentPadAdded:)
                                                 name:@"NumberOfRestKnotesOnCurrentPad_added"
                                               object:nil];
    
    
    [self.dataArray addObject:@"topic_ready"];
    [self.dataArray addObject:@"knotes_added"];
    [self.dataArray addObject:@"contacts_added"];
    [self.dataArray addObject:@"knotable_events_added"];
    [self.dataArray addObject:@"NumberOfKnotesOnCurrentPad_added"];
    
    [self.dataArray addObject:@"NumberOfPinnedKnotesOnCurrentPad_added"];
    [self.dataArray addObject:@"pinnedKnotesForTopic_ready"];

    [self.dataArray addObject:@"NumberOfArchivedKnotesOnCurrentPad_added"];
    [self.dataArray addObject:@"archivedKnotesForTopic_ready"];
    
    [self.dataArray addObject:@"NumberOfRestKnotesOnCurrentPad_added"];
    [self.dataArray addObject:@"allRestKnotesByTopicId_ready"];

    [self.meteor removeSubscription:METEORCOLLECTION_KNOTE_TOPIC];
    [self.meteor addSubscription:METEORCOLLECTION_KNOTE_TOPIC withParameters:@[self.topic_id]];
    
    [self.meteor removeSubscription:METEORCOLLECTION_KNOTE_PINNED];
    [self.meteor addSubscription:METEORCOLLECTION_KNOTE_PINNED
                                          withParameters:@[self.topic_id]];

    [self.meteor removeSubscription:METEORCOLLECTION_KNOTE_ARCHIVED];
    [self.meteor addSubscription:METEORCOLLECTION_KNOTE_ARCHIVED
                                          withParameters:@[self.topic_id]];
    
    [self.meteor removeSubscription:METEORCOLLECTION_KNOTE_REST];
    [self.meteor addSubscription:METEORCOLLECTION_KNOTE_REST
                  withParameters:@[self.topic_id]];
    
    
    
//    cell.detailLabel.text = [NSString stringWithFormat:@"total:%d current:%d Cost:%0.1fms",(int)self.topicsCount,(int)self.topicsArray.count,([self.topicsDate  timeIntervalSinceNow]*-1000)];
//    cell.timeLabel.text = [NSString stringWithFormat:@"Start:%@",[self.dateFormatter stringFromDate:self.topicsDate]];
}
-(NSIndexPath *)getIndexPath:(NSString *)str
{
    for (int i = 0; i<[self.tableView numberOfRowsInSection:0]; i++) {
        if ([self.dataArray[i] isEqualToString:str]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            return indexPath;
        }
    }
    return nil;
}

-(void)messagesAdded:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    
    if (note.userInfo)
    {
        serverData = note.userInfo;
        [self.contentArray addObject:serverData];
    }
    NSIndexPath *indexPath = [self getIndexPath:@"knotes_added"];
    if (indexPath) {
        KnotesViewCell *cell = ( KnotesViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.detailLabel.text = [NSString stringWithFormat:@"Cost:%0.1fms",([self.knotesDate  timeIntervalSinceNow]*-1000)];
    }
    NSIndexPath *indexPath1 = [self getIndexPath:@"topic_ready"];
    if (indexPath1) {
        KnotesViewCell *cell = ( KnotesViewCell *)[self.tableView cellForRowAtIndexPath:indexPath1];
        cell.detailLabel.text = [NSString stringWithFormat:@"CurrentCount:%d.Cost:%0.1fms",(int)self.contentArray.count,([self.knotesDate  timeIntervalSinceNow]*-1000)];
    }
}

-(void)knotesAdded:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    
    if (note.userInfo)
    {
        serverData = note.userInfo;
        [self.contentArray addObject:serverData];
    }
    NSIndexPath *indexPath = [self getIndexPath:@"knotes_added"];
    if (indexPath) {
        KnotesViewCell *cell = ( KnotesViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.detailLabel.text = [NSString stringWithFormat:@"Cost:%0.1fms",([self.knotesDate  timeIntervalSinceNow]*-1000)];
    }
    NSIndexPath *indexPath1 = [self getIndexPath:@"topic_ready"];
    if (indexPath1) {
        KnotesViewCell *cell = ( KnotesViewCell *)[self.tableView cellForRowAtIndexPath:indexPath1];
        cell.detailLabel.text = [NSString stringWithFormat:@"CurrentCount:%d.Cost:%0.1fms",(int)self.contentArray.count,([self.knotesDate  timeIntervalSinceNow]*-1000)];
    }
}

-(void)contactsAdded:(NSNotification *)note
{
    NSIndexPath *indexPath = [self getIndexPath:@"contacts_added"];
    if (indexPath) {
        KnotesViewCell *cell = ( KnotesViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.detailLabel.text = [NSString stringWithFormat:@"Cost:%0.1fms",([self.knotesDate  timeIntervalSinceNow]*-1000)];
    }
}

-(void)knotableEventsAdded:(NSNotification *)note
{
    NSIndexPath *indexPath = [self getIndexPath:@"knotable_events_added"];
    if (indexPath) {
        KnotesViewCell *cell = ( KnotesViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.detailLabel.text = [NSString stringWithFormat:@"Cost:%0.1fms",([self.knotesDate  timeIntervalSinceNow]*-1000)];
    }
}

-(void)topicReady:(NSNotification *)note
{
    NSIndexPath *indexPath = [self getIndexPath:@"topic_ready"];
    if (indexPath) {
        KnotesViewCell *cell = ( KnotesViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.detailLabel.text = [NSString stringWithFormat:@"CurrentCount:%d.Cost:%0.1fms",(int)self.contentArray.count,([self.knotesDate  timeIntervalSinceNow]*-1000)];
    }
}
-(void)numberOfKnotesOnCurrentPadAdded:(NSNotification *)note
{
    NSIndexPath *indexPath = [self getIndexPath:@"NumberOfKnotesOnCurrentPad_added"];
    if (indexPath) {
        KnotesViewCell *cell = ( KnotesViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        NSDictionary* serverData = Nil;
        
        if (note.userInfo)
        {
            serverData = note.userInfo;
        }
       
        cell.detailLabel.text = [NSString stringWithFormat:@"count:%@|Cost:%0.1fms",serverData[@"count"],([self.knotesDate  timeIntervalSinceNow]*-1000)];
    }
}
-(void)numberOfArchivedKnotesOnCurrentPadAdded:(NSNotification *)note
{
    NSIndexPath *indexPath = [self getIndexPath:@"NumberOfArchivedKnotesOnCurrentPad_added"];
    if (indexPath) {
        KnotesViewCell *cell = ( KnotesViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        NSDictionary* serverData = @{};
        
        if (note.userInfo)
        {
            serverData = note.userInfo;
        }
        
        cell.detailLabel.text = [NSString stringWithFormat:@"count:%@|Cost:%0.1fms",serverData[@"count"],([self.knotesDate  timeIntervalSinceNow]*-1000)];
    }
}
-(void)archivedKnotesForTopicReady:(NSNotification *)note
{
    NSIndexPath *indexPath = [self getIndexPath:@"archivedKnotesForTopic_ready"];
    if (indexPath) {
        KnotesViewCell *cell = ( KnotesViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

        cell.detailLabel.text = [NSString stringWithFormat:@"Cost:%0.1fms",([self.knotesDate  timeIntervalSinceNow]*-1000)];
    }
}
-(void)pinnedKnotesForTopicReady:(NSNotification *)note
{
    NSIndexPath *indexPath = [self getIndexPath:@"pinnedKnotesForTopic_ready"];
    if (indexPath) {
        KnotesViewCell *cell = ( KnotesViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        cell.detailLabel.text = [NSString stringWithFormat:@"Cost:%0.1fms",([self.knotesDate  timeIntervalSinceNow]*-1000)];
    }
}
-(void)NumberOfPinnedKnotesOnCurrentPadAdded:(NSNotification *)note
{
    NSIndexPath *indexPath = [self getIndexPath:@"NumberOfPinnedKnotesOnCurrentPad_added"];
    if (indexPath) {
        KnotesViewCell *cell = ( KnotesViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        NSDictionary* serverData = @{};
        
        if (note.userInfo)
        {
            serverData = note.userInfo;
        }
        
        cell.detailLabel.text = [NSString stringWithFormat:@"count:%@|Cost:%0.1fms",serverData[@"count"],([self.knotesDate  timeIntervalSinceNow]*-1000)];
    }
}


-(void)allRestKnotesByTopicIdReady:(NSNotification *)note
{
    NSIndexPath *indexPath = [self getIndexPath:@"allRestKnotesByTopicId_ready"];
    if (indexPath) {
        KnotesViewCell *cell = ( KnotesViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        cell.detailLabel.text = [NSString stringWithFormat:@"Cost:%0.1fms",([self.knotesDate  timeIntervalSinceNow]*-1000)];
    }
}
-(void)NumberOfRestKnotesOnCurrentPadAdded:(NSNotification *)note
{
    NSIndexPath *indexPath = [self getIndexPath:@"NumberOfRestKnotesOnCurrentPad_added"];
    if (indexPath) {
        KnotesViewCell *cell = ( KnotesViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        NSDictionary* serverData = @{};
        
        if (note.userInfo)
        {
            serverData = note.userInfo;
        }
        
        cell.detailLabel.text = [NSString stringWithFormat:@"count:%@|Cost:%0.1fms",serverData[@"count"],([self.knotesDate  timeIntervalSinceNow]*-1000)];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = self.dataArray[indexPath.row];
    
    KnotesViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[KnotesViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:cellIdentifier];
    }
    cell.funName.text = self.dataArray[indexPath.row];
    if ([cell.funName.text isEqualToString:@"topic_ready"]) {
        cell.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.1];
    } else {
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
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
