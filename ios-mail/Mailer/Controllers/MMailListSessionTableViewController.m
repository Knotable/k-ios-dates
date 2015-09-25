//
//  MMailListSessionTableViewController.m
//  Mailer
//
//  Created by wuli on 14-6-12.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import "MMailListSessionTableViewController.h"
#import "MMailManager.h"
#import "Message.h"
#import "Address.h"
#import "MSessionViewCell.h"
#import "MCircleView.h"
#import "MDetailViewController.h"
static const int MESSAGE_CELLS_PER_LOAD = 10;

@interface MMailListSessionTableViewController ()<NSFetchedResultsControllerDelegate,JZSwipeCellDelegate>
{
    UIActivityIndicatorView *spinner;
}
@property (nonatomic, strong) NSArray *contentArray;
@end

@implementation MMailListSessionTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.92 alpha:0.92];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.fetchedResultsController.delegate = self;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    [Message setDefaultBatchSize:MESSAGE_CELLS_PER_LOAD];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account = %@  AND account.status = YES AND folder = %@ AND deleted = NO AND archive = NO AND NOT (passed=YES OR processed=YES) AND gmailThreadID = %llud", self.message.account, self.message.folder,self.message.gmailThreadID];
    _fetchedResultsController = [Message MR_fetchAllGroupedBy:@"gmailThreadID" withPredicate:predicate sortedBy:@"uid" ascending:YES];
    _fetchedResultsController.fetchRequest.fetchLimit = 10;
    _fetchedResultsController.fetchRequest.fetchOffset = 0;

    if (_fetchedResultsController.fetchedObjects.count == 0) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2) - 44);
        [self.view addSubview:spinner];
        
        [spinner startAnimating];
    }
    return _fetchedResultsController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section!=0) return 0;
    NSInteger count = _fetchedResultsController.fetchedObjects.count;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@">>>>>>>%ld,%ld",(long)indexPath.row,(long)indexPath.section);
    Message *message = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    //    Message *message = (Message *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    CGFloat height = 126.0;

    if (message.summary == nil || message.summary.length == 0)
    {
        height = 62.0;
    }
    
    return height;
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    
//    if (![_deleteIndexArray containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
    {

        
//        if (isSpinning) {
//            isSpinning = NO;
//            [spinner stopAnimating];
//            [spinner removeFromSuperview];
//        }

        MSessionViewCell *messageCell = (MSessionViewCell *)cell;
        messageCell.message = message;
        
        //    //NSLog(@"message = %@",message);
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* rec = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:message.receivedDate];
        NSDateComponents* today = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
        
        if (rec.day == today.day && rec.month == today.month && rec.year == today.year) {
            dateFormatter.timeStyle = NSDateFormatterShortStyle;
            dateFormatter.dateStyle = NSDateFormatterNoStyle;
        }
        else
        {
            [dateFormatter setDateFormat:@"MMM dd"];
        }
        
        [dateFormatter setLocale:[NSLocale currentLocale]];
        
        
        NSString *formattedDate = [dateFormatter stringFromDate:message.receivedDate];
        
        
        messageCell.subjectLabel.text = message.subject;
        
        if (message.fromName == nil || [message.fromName isEqualToString:@""]) {
            messageCell.fromLabel.text = message.fromAddress;
            
        } else {
            messageCell.fromLabel.text = message.fromName;
        }
        messageCell.delegate = self;
#ifdef DEBUG
        messageCell.dateLabel.text = [NSString stringWithFormat:@"%@,%ld",formattedDate,(long)indexPath.row];
        messageCell.dateLabel.frame = CGRectMake(200, 8, 120, 16);
#else
        messageCell.dateLabel.text = formattedDate;
#endif
        
        if(message.summary != nil){
            messageCell.sumaryLabel.text = message.summary;
        } else {
            messageCell.sumaryLabel.text = @"";
        }
        
        messageCell.unreadCircle.hidden = YES;
        
        if (message.read) {
            messageCell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
            messageCell.fromLabel.font =   [UIFont systemFontOfSize:13];
            messageCell.subjectLabel.font =   [UIFont systemFontOfSize:12];
            messageCell.textLabel.font =  [UIFont systemFontOfSize:11];
        }
        else {
            messageCell.backgroundColor = [UIColor whiteColor];
            messageCell.fromLabel.font =   [UIFont boldSystemFontOfSize:13];
            messageCell.subjectLabel.font =   [UIFont boldSystemFontOfSize:12];
            messageCell.textLabel.font =  [UIFont boldSystemFontOfSize:11];
        }
        
        messageCell.characterCountLabel.text = [NSString stringWithFormat:@"%d", message.characterCount];
//        messageCell.characterCountLabel.hidden = !(_shortMode || _longMode);
        

        messageCell.progressView.hidden = YES;
        messageCell.characterCountLabel.hidden = YES;

    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSessionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageSessionCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showDetail" sender:self];
    
//    if (![undoBut isDescendantOfView:[[UIApplication sharedApplication] keyWindow]]){
//    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    MDetailViewController *detailController = [segue destinationViewController];
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    detailController.shortMode = _shortMode;
    detailController.fetchedResultsController = self.fetchedResultsController;
    detailController.message = message;
    detailController.peopleMode = NO;
}
- (void)swipeCell:(JZSwipeCell*)cell triggeredSwipeWithType:(JZSwipeType)swipeType
{
//    if (swipeType == JZSwipeTypeLongLeft) {
//        NSIndexPath *swipedIndexPath = [self.tableView indexPathForCell:cell];
//        
//        Message *message = [self.fetchedResultsController objectAtIndexPath:swipedIndexPath];
//        [_deleteMessageArray addObject:message];
//        [self performSelector:@selector(removeTableIndex:) withObject:swipedIndexPath afterDelay:0.5];
//    } else if (swipeType == JZSwipeTypeShortLeft) {
//        NSIndexPath *swipedIndexPath = [self.tableView indexPathForCell:cell];
//        
//        MMessageCell *acell = (MMessageCell *)cell;
//        Message *message = acell.message;
//        [_archiveIndexArray addObject:message];
//        
//        [_archiveIndexPathArray addObject:[NSString stringWithFormat:@"%ld",(long)swipedIndexPath.row]];
//        
//        [self performSelector:@selector(removeTableIndexForArchive:) withObject:swipedIndexPath afterDelay:0.5];
//    }
}
@end
