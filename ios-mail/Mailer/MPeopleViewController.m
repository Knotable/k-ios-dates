//
//  MPeopleViewController.m
//  Mailer
//
//  Created by Mac 7 on 22/01/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import "MPeopleViewController.h"
#import "Message.h"
#import "MMessageCell.h"

#import "Address.h"
#import "MDataManager.h"
#import "MPplDetailViewController.h"
#import "MDesignManager.h"


@interface MPeopleViewController ()

@end

@implementation MPeopleViewController

//@synthesize managedObjectContext;

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
    
    pplListTableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

    
	// Do any additional setup after loading the view.
    
//    pplListArray = [[NSMutableArray alloc] init];
    
//    Folder *folder = [MMailManager sharedManager].currentFolder;
//    Account *account = [MMailManager sharedManager].currentAccount;
//    
//    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account = %@ AND folder = %@ AND deleted = NO",
//                              account, folder];
//    NSFetchedResultsController *fetchedResultsController = [Message fetchAllSortedBy:@"uid"
//                                                ascending:NO
//                                            withPredicate:predicate
//                                                  groupBy:nil
//                                                 delegate:self];
//    
//    
//    //NSLog(@"fetchedResultsController = %@",fetchedResultsController);
//    
//    NSInteger count = fetchedResultsController.fetchedObjects.count;
//    
//    //NSLog(@"count = %i",count);
    
//    for (int i = 0; i < count; i++) {
//        Message *message = [fetchedResultsController objectAtIndexPath:];
//        
//        //NSLog(@"message = %@",message);
//    }
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"paper_clip.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [[MSwipedButtonManager sharedManager] setHidden:NO];
    [MSwipedButtonManager sharedManager].delegate = self;
//    swipeBut = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [swipeBut setTitle:@"+" forState:UIControlStateNormal];
//    swipeBut.titleLabel.font = [UIFont boldSystemFontOfSize:50];
//    swipeBut.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
//    swipeBut.tintColor = [UIColor whiteColor];
//    
//    
//    [swipeBut addTarget:self
//                 action:nil
//       forControlEvents:UIControlEventTouchDown];
//    
//    swipeBut.backgroundColor = [MDesignManager patternImage];
//    
//    swipeBut.frame = CGRectMake(([[UIApplication sharedApplication] keyWindow].frame.size.width/2)-35, [[UIApplication sharedApplication] keyWindow].frame.size.height-100, 70, 70);
//    
//    swipeBut.layer.cornerRadius = 35.0f;
//    swipeBut.layer.borderWidth = 1.0f;
//    swipeBut.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    
    
    _isIndicating = YES;
    
    [self performSelector:@selector(mailUpdated) withObject:nil afterDelay:0.1];
    
}

- (void) mailUpdated
{
    
    NSError *error;
    
	if (![[self fetchedResultsController] performFetch:&error]) {
        
		// Update to handle the error appropriately.
		//NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
		exit(-1);  // Fail
	}
    
    [pplListTableView reloadData];
    
    [self performSelector:@selector(removeLoader) withObject:nil afterDelay:0.1];
    
}

-(void)removeLoader{
    
    _isIndicating = NO;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[MSwipedButtonManager sharedManager] setHidden:YES];
    [MSwipedButtonManager sharedManager].delegate = nil;

}

#pragma mark - UIPanGesture

- (void) swipedButtonPanChanged:(UIPanGestureRecognizer *)recognizer
{
    
    if (!_isIndicating) {
        
        
        
        //    NSLog(@"recognizer.x ==== %f",[recognizer locationInView:swipeBut.superview].x);
        //    NSLog(@"recognizer.y ==== %f",[recognizer locationInView:swipeBut.superview].y);
        
        NSInteger height = self.view.frame.size.height + 0.5f;
        
        //    NSLog(@"self.view.frame.size.width ==== %f",self.view.frame.size.width);
        
        
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            
            switch (height)
            {
                case 568:
                    //iPhone 5
                {
                    //                if ((recognizer.view.center.y > 470)&&(recognizer.view.center.y < 500)) {
                    if ((recognizer.view.center.y > 200)&&(recognizer.view.center.y < 560)) {
                        
                        
                        
                        [UIView beginAnimations:@"presentWithSuperview" context:nil];
                        [UIView setAnimationDuration:0.3];
                        //                    self.view.frame=CGRectMake(recognizer.view.center.x - self.view.frame.size.width/2, 0, self.view.frame.size.width, self.view.frame.size.height);
                        
                        self.view.frame=CGRectMake(recognizer.view.center.x - self.view.frame.size.width/2, 0, self.view.frame.size.width, self.view.frame.size.height);
                        
                        [UIView commitAnimations];
                        
                    }
                }
                    
                    break;
                    
                case 480:
                    //iPhone
                {
                    //                 if ((recognizer.view.center.y > 380)&&(recognizer.view.center.y < 450)) {
                    
                    if ((recognizer.view.center.y > 150)&&(recognizer.view.center.y < 460)) {
                        
                        
                        [UIView beginAnimations:@"presentWithSuperview" context:nil];
                        [UIView setAnimationDuration:0.3];
                        //                     self.view.frame=CGRectMake(recognizer.view.center.x - self.view.frame.size.width/2, recognizer.view.center.y-416, self.view.frame.size.width, self.view.frame.size.height);
                        self.view.frame=CGRectMake(recognizer.view.center.x - self.view.frame.size.width/2,0, self.view.frame.size.width, self.view.frame.size.height);
                        
                        [UIView commitAnimations];
                        
                        
                    }
                }
                    
                    break;
                    
                default:
                    //iPad
                    
                {
                    if ((recognizer.view.center.y > 200)&&(recognizer.view.center.y < 1000)) {
                        
                        //                     if ((recognizer.view.center.y > 930)&&(recognizer.view.center.y < 970)) {
                        
                        
                        [UIView beginAnimations:@"presentWithSuperview" context:nil];
                        [UIView setAnimationDuration:0.2];
                        //                     self.view.frame=CGRectMake(recognizer.view.center.x - self.view.frame.size.width/2, recognizer.view.center.y-955, self.view.frame.size.width, self.view.frame.size.height);
                        self.view.frame=CGRectMake(recognizer.view.center.x - self.view.frame.size.width/2, 0, self.view.frame.size.width, self.view.frame.size.height);
                        
                        [UIView commitAnimations];
                        
                    }
                }
                    
                    
                    break;
            }
            
        }
        
        else if(recognizer.state == UIGestureRecognizerStateEnded)
        {
            
            switch (height)
            {
                case 568:
                    //iPhone 5
                {
                    
                    //                if ((recognizer.view.center.x > 170)&&(recognizer.view.center.y > 470)&&(recognizer.view.center.y < 500)){
                    
                    if ((recognizer.view.center.x > 190)&&(recognizer.view.center.y > 150)&&(recognizer.view.center.y < 560)){
                        
                        [MCyclingViewController panLeftFrom:self recognizer:recognizer];
                        
                        
                    }
                    //                else if ((recognizer.view.center.x < 170)&&(recognizer.view.center.y > 470)&&(recognizer.view.center.y < 500)){
                    
                    else if ((recognizer.view.center.x < 150)&&(recognizer.view.center.y > 150)&&(recognizer.view.center.y < 560)){
                        
                        [MCyclingViewController panRightFrom:self recognizer:recognizer];
                        
                    }
                    else{
                        
                        if ((recognizer.view.center.x > 151) &&(recognizer.view.center.x < 189)&&(recognizer.view.center.y > 495)) {
                            
                            _isIndicating = YES;
                            [[MSwipedButtonManager sharedManager] setEnable:NO];
                            
                            [self performSelector:@selector(mailUpdated) withObject:nil afterDelay:0.1];
                            
                            
                        }
                        
                        else if ((recognizer.view.center.x > 151) &&(recognizer.view.center.x < 189)&&(recognizer.view.center.y < 490)){
                            
                            //                        [self.navigationController popViewControllerAnimated:NO];
                            
                            [self backAction:0];
                            
                        }
                        
                        
                        
                        
                        
                        [UIView animateWithDuration:.3 animations:^{
                            
                            [UIView beginAnimations:@"presentWithSuperview" context:nil];
                            self.view.frame = CGRectMake(0 , 0 , self.view.frame.size.width, self.view.frame.size.height);
                            
                            [UIView commitAnimations];
                            
                            
                        } completion:^(BOOL isFinished){
                            if (isFinished == true)
                            {
                                
                                [UIView beginAnimations:@"presentWithSuperview" context:nil];
                                [UIView setAnimationDuration:0.3];
                                
                                
                                [UIView commitAnimations];
                                
                            }
                        }];
                        
                    }
                    
                }
                    
                    break;
                    
                case 480:
                    //iPhone
                {
                    
                    //                if ((recognizer.view.center.x > 170)&&(recognizer.view.center.y > 380)&&(recognizer.view.center.y < 450)){
                    
                    if ((recognizer.view.center.x > 190)&&(recognizer.view.center.y > 150)&&(recognizer.view.center.y < 460)){
                        
                        
                        [MCyclingViewController panLeftFrom:self recognizer:recognizer];
                        
                        //                    [[MControllerManager sharedManager] goPanLeftFrom:[self.navigationController.viewControllers lastObject] recognizer:recognizer];
                        //                    _shortMode = YES;
                        
                        //                    [self.navigationController pushViewController:[self.navigationController.viewControllers lastObject] animated:YES];
                        
                        
                    }
                    else if ((recognizer.view.center.x < 150)&&(recognizer.view.center.y > 150)&&(recognizer.view.center.y < 460)){
                        
                        //                    else if ((recognizer.view.center.x < 170)&&(recognizer.view.center.y > 380)&&(recognizer.view.center.y < 450)){
                        
                        
                        
                        [MCyclingViewController panRightFrom:self recognizer:recognizer];
                        
                        //                    [[MControllerManager sharedManager] goPanRightFrom:[self.navigationController.viewControllers lastObject] recognizer:recognizer];
                        
                    }
                    else{
                        
                        if ((recognizer.view.center.x > 151) &&(recognizer.view.center.x < 189)&&(recognizer.view.center.y > 435)) {
                            
                            _isIndicating = YES;
                            [[MSwipedButtonManager sharedManager] setEnable:NO];
                            
                            [self performSelector:@selector(mailUpdated) withObject:nil afterDelay:0.1];
                            
                            //                        [self ballRefreshAction];
                            
                        }
                        else if ((recognizer.view.center.x > 151) &&(recognizer.view.center.x < 189)&&(recognizer.view.center.y < 390)){
                            
                            //                        [self.navigationController popViewControllerAnimated:NO];
                            
                            //                         [self performSegueWithIdentifier:@"UnwindBack" sender:self];
                            
                            [self backAction:0];
                            
                        }
                        
                        
                        [UIView animateWithDuration:.3 animations:^{
                            
                            [UIView beginAnimations:@"presentWithSuperview" context:nil];
                            self.view.frame = CGRectMake(0 , 0 , self.view.frame.size.width, self.view.frame.size.height);
                            
                            [UIView commitAnimations];
                            
                        } completion:^(BOOL isFinished){
                            if (isFinished == true)
                            {
                                
                                [UIView beginAnimations:@"presentWithSuperview" context:nil];
                                [UIView setAnimationDuration:0.3];
                                
                                
                                [UIView commitAnimations];
                                
                            }
                        }];
                        
                    }
                    
                }
                    
                    break;
                    
                default:
                    //iPad
                    
                {
                    if ((recognizer.view.center.x > 405)&&(recognizer.view.center.y > 200)&&(recognizer.view.center.y < 1000)){
                        //                    if ((recognizer.view.center.x > 395)&&(recognizer.view.center.y > 930)&&(recognizer.view.center.y < 970)){
                        
                        [MCyclingViewController panLeftFrom:self recognizer:recognizer];
                        
                    }
                    else if ((recognizer.view.center.x < 365)&&(recognizer.view.center.y > 200)&&(recognizer.view.center.y < 1000)){
                        //                    else if ((recognizer.view.center.x < 395)&&(recognizer.view.center.y > 930)&&(recognizer.view.center.y < 970)){
                        
                        
                        [MCyclingViewController panRightFrom:self recognizer:recognizer];
                    }
                    else{
                        
                        if ((recognizer.view.center.x > 366)&&(recognizer.view.center.x < 404)&&(recognizer.view.center.y > 965)){
                            
                            _isIndicating = YES;
                            [[MSwipedButtonManager sharedManager] setEnable:NO];
                            
                            [self performSelector:@selector(mailUpdated) withObject:nil afterDelay:0.1];
                            
                            
                        }
                        
                        else if ((recognizer.view.center.x > 366)&&(recognizer.view.center.x < 404)&&(recognizer.view.center.y < 960)){
                            
                            //                        [self.navigationController popViewControllerAnimated:NO];
                            
                            [self backAction:0];
                            
                        }
                        
                        
                        
                        [UIView animateWithDuration:.3 animations:^{
                            
                            [UIView beginAnimations:@"presentWithSuperview" context:nil];
                            self.view.frame = CGRectMake(0 , 0 , self.view.frame.size.width, self.view.frame.size.height);
                            
                            [UIView commitAnimations];
                            
                        } completion:^(BOOL isFinished){
                            if (isFinished == true)
                            {
                                
                                [UIView beginAnimations:@"presentWithSuperview" context:nil];
                                [UIView setAnimationDuration:0.3];
                                
                                
                                [UIView commitAnimations];
                                
                            }
                        }];
                        
                    }
                    
                }
                    
                    
                    break;
            }
            
            
        }
        
    }
}

#pragma mark - UILongPressGestureRecognizer


- (void)swipedButtonLongChanged:(UILongPressGestureRecognizer *)recognizer{
    
//    if (!_isIndicating) {
    
        
        
        //as you hold the button this would fire
        
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            
            [self composeNewMessage];
            
            
            //            NSLog(@"recognizer.x ==== %f",[recognizer locationInView:swipeBut.superview].x);
            //            NSLog(@"recognizer.y ==== %f",[recognizer locationInView:swipeBut.superview].y);
            
        }
        
        //as you release the button this would fire
        
        //    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        //            NSLog(@"recognizer.x  END==== %f",[recognizer locationInView:swipeBut.superview].x);
        //            NSLog(@"recognizer.y END ==== %f",[recognizer locationInView:swipeBut.superview].y);
        
        
        
        //    }
        
//    }
    
}

- (void)composeNewMessage{
    
    [self performSegueWithIdentifier:@"composeNewMessageFromPeople" sender:self];
}


-(IBAction)backAction:(id)sender{
    
    [self performSegueWithIdentifier:@"UnwindBack" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - Fetching Data

- (NSFetchedResultsController *)fetchedResultsController {
    
//    if (_fetchedResultsController != nil) {
//        return _fetchedResultsController;
//    }
//    
//    MDataManager *dataManager = [MDataManager sharedManager];
//    NSManagedObjectContext *managedObjectContext = dataManager.managedObjectContext;
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription
//                                   entityForName:@"Address" inManagedObjectContext:managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account.status = YES"];
//    [fetchRequest setPredicate:predicate];
//    
//    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
//                              initWithKey:@"abRecordID" ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
//    
//        
//    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
//    
//    
//    self.fetchedResultsController = theFetchedResultsController;
//    _fetchedResultsController.delegate = self;
    
    
    MDataManager *dataManager = [MDataManager sharedManager];
    NSManagedObjectContext *managedObjectContext = dataManager.managedObjectContext;
    
   NSPredicate* predicate = [NSPredicate predicateWithFormat:@"message.account.status = YES"];
    
    _fetchedResultsController = [Address fetchAllSortedBy:@"abRecordID" ascending:YES withPredicate:predicate groupBy:nil delegate:self inContext:managedObjectContext];

    return _fetchedResultsController;
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Address *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = info.name;
    cell.detailTextLabel.text = info.email;
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:UITableViewRowAnimationFade];
    
    Address *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    MPplDetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"PeopleDetailView"];
    
    detailViewController.info = info;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

//- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
//{
//    
//    MMessageCell *messageCell = (MMessageCell *)cell;
//    
//    Address *info = [_fetchedResultsController objectAtIndexPath:indexPath];
//    
//    messageCell.fromLabel.text = info.name;
//    messageCell.subjectLabel.text = info.email;
//    
//}

#pragma mark - NSFetchedResultsControllerDelegate Methods
//For table reloading

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [pplListTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = pplListTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:{
            
            Address *info = [_fetchedResultsController objectAtIndexPath:indexPath];
            [tableView cellForRowAtIndexPath:indexPath].textLabel.text =  info.name;
        }
            
            //            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [pplListTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [pplListTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [pplListTableView endUpdates];
}



@end
