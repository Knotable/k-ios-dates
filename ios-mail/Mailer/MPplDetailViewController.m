//
//  MPplDetailViewController.m
//  Mailer
//
//  Created by Mac 7 on 22/01/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import "MPplDetailViewController.h"
#import "Message.h"
#import "Address.h"
#import "MMessageCell.h"
#import "MCircleView.h"
#import "MDetailViewController.h"
#import "MDataManager.h"
#import "MAppDelegate.h"


@interface MPplDetailViewController ()

@end

@implementation MPplDetailViewController
@synthesize info,emailArray,fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//     //NSLog(@"self.emailArray=%@",self.emailArray);
    
    emailListTableView.delegate = self;
    emailListTableView.dataSource = self;
    
    [self fetchingData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeIndex:) name:@"reloadTable" object:nil];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon-1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    
    UIBarButtonItem *home = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"paper_clip.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backToHome)];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backButton, home, nil];
   
}

-(IBAction)backAction:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)backToHome{
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    MAppDelegate *delegate = (MAppDelegate *) [[UIApplication sharedApplication]delegate];
    [self.navigationController popToViewController:delegate.parentViewCntrllr animated:YES];
}

-(void)fetchingData{
    
    MDataManager *dataManager = [MDataManager sharedManager];
    NSManagedObjectContext *managedObjectContext = dataManager.managedObjectContext;
    
    Address *address = info;
    
//    NSLog(@"address.emai  === %@",address.email);
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"fromAddress = %@ AND account.status = YES",address.email];
    
    
    NSArray *resultArray = [Message findAllSortedBy:@"uid" ascending:YES withPredicate:predicate inContext:managedObjectContext];
    
    self.emailArray  = [NSMutableArray arrayWithArray:resultArray];
    
    
    
    //************** CoreData  Relationship Sorting *************************//
    
//    NSMutableArray *sortedIngredients = [[NSMutableArray alloc] initWithArray:[info.messagesFrom allObjects]];
  
//    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:[sortedIngredients filteredArrayUsingPredicate:predicate]];

//  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"uid" ascending:YES];
//	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    
//	[newArray sortUsingDescriptors:sortDescriptors];
//    
//    //        //NSLog(@"sortedIngredients=%@",sortedIngredients);
//    
//	self.emailArray = sortedIngredients;
    
    [emailListTableView reloadData];
    
}

-(void)removeIndex:(NSNotification *)notification {
    
//    //NSLog(@"notification.object =%@", notification.object);
    
    [self.emailArray removeObjectAtIndex: [notification.object integerValue]];
    [emailListTableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.emailArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    //Modified by 3E ------START------
    
    UIImage *image = [UIImage imageNamed:@"arrow.png"];
    UIImageView *disclosure = [[UIImageView alloc] initWithImage:image];
    CGRect frame = CGRectMake(44.0, 44.0, image.size.width, image.size.height);
    disclosure.frame = frame;//cell.accessoryView.frame;
    cell.accessoryView = disclosure;
    
    //Modified by 3E ------END------
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    Message *message = [self.emailArray objectAtIndex:indexPath.row];
    
    MMessageCell *messageCell = (MMessageCell *)cell;
    messageCell.message = message;
    
//        //NSLog(@"message = %@",message);
    
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
        
        //dateFormatter.dateStyle = NSDateFormatterShortStyle;
        //dateFormatter.timeStyle = NSDateFormatterNoStyle;
        
    }
    
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    NSString *formattedDate = [dateFormatter stringFromDate:message.receivedDate];
    //NSLog(@"Date for locale %@: %@",
    //      [[dateFormatter locale] localeIdentifier], formattedDate);
    
    messageCell.subjectLabel.text = message.subject;
    
    if (message.fromName == nil || [message.fromName isEqualToString:@""]) {
        messageCell.fromLabel.text = message.fromAddress;
    }
    else {
        messageCell.fromLabel.text = message.fromName;
    }
    
    messageCell.dateLabel.text = formattedDate;
    
    if(message.summary != nil){
        messageCell.textLabel.text = message.summary;
    }
    else {
        messageCell.textLabel.text = @"";
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
    messageCell.characterCountLabel.hidden = YES;
    
    float progressMin = 0;
    float progressMax = 5000;
    float progress = (message.characterCount - progressMin) / (progressMax - progressMin);
    messageCell.progressView.progress = progress;
    messageCell.progressView.hidden = YES;
    
    /*
     if (!messageCell.longPressRecognizer) {
     UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
     [messageCell addGestureRecognizer:longPressRecognizer];
     longPressRecognizer.minimumPressDuration = 0.3;
     longPressRecognizer.delegate = self;
     messageCell.longPressRecognizer = longPressRecognizer;
     }
     
     */
    
    /*
     
     if (!messageCell.doubleTapRecognizer) {
     UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
     doubleTapRecognizer.numberOfTapsRequired = 2;
     [messageCell addGestureRecognizer:doubleTapRecognizer];
     doubleTapRecognizer.delegate = self;
     messageCell.doubleTapRecognizer = doubleTapRecognizer;
     
     */
    
//    if (!messageCell.leftSwipeRecognizer) {
//        UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
//        leftSwipe.direction = UISwipeGestureRecognizerDirectionRight;
//        [messageCell addGestureRecognizer:leftSwipe];
//        messageCell.leftSwipeRecognizer = leftSwipe;
//    }
    
}
- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"accessoryButtonTappedForRowWithIndexPath");
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"prepareForSegue: %@", segue.identifier);
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [emailListTableView indexPathForSelectedRow];
        MDetailViewController *detailController = [segue destinationViewController];
        
        
        Message *message = [self.emailArray objectAtIndex:indexPath.row];
        
//        detailController.fetchedResultsController = self.fetchedResultsController;
        detailController.message = message;
        detailController.messageArray = self.emailArray;
        detailController.peopleMode = YES;
        
    }
}

@end
