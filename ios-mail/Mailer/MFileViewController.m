//
//  MFileViewController.m
//  Mailer
//
//  Created by Mac 7 on 22/01/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import "MFileViewController.h"
#import "MDataManager.h"
#import "Attachment.h"
#import "MDetailViewController.h"
#import "MDesignManager.h"

@interface MFileViewController ()<MSwipedButtonManagerDelegate>
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation MFileViewController

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
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"paper_clip.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    _isIndicating = YES;
 [self performSelector:@selector(mailUpdated) withObject:nil afterDelay:0.1];
//    [self mailUpdated];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

//    [self performSelector:@selector(mailUpdated) withObject:nil afterDelay:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
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
-(void)swipedButtonLongChanged:(UILongPressGestureRecognizer *)recognizer
{
}



- (void)composeNewMessage{
    
    [self performSegueWithIdentifier:@"composeNewMessageFromFile" sender:self];
}

- (void) mailUpdated
{
    
//    (NSArray *) findAllInContext:(NSManagedObjectContext *)context;
    
    MDataManager *dataManager = [MDataManager sharedManager];
    NSManagedObjectContext *managedObjectContext = dataManager.managedObjectContext;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"isImage = NO AND message.account.status = YES"];//AND message.account.status = YES
    
    _allFileAttachments = [Attachment findAllWithPredicate:predicate inContext:managedObjectContext];
    if ([_allFileAttachments count]<=0) {
        if (!self.emptyLabel) {
            self.emptyLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
            self.emptyLabel.textAlignment = NSTextAlignmentCenter;
            self.emptyLabel.text = @"No files avaiable in device.";
            [self.view addSubview:self.emptyLabel];
        }
    } else {
        if (!self.emptyLabel) {
            [self.emptyLabel removeFromSuperview];
            self.emptyLabel = nil;
        }
    }
//    _allFileAttachments = [Attachment findAllInContext:managedObjectContext];

//    //NSLog(@"_allFileAttachments.count = %d",[_allFileAttachments count]);
    
    [collctnView reloadData];
    
    
     [self performSelector:@selector(removeLoader) withObject:nil afterDelay:0.1];
    
//     [self performSelector:@selector(removeLoader) withObject:nil afterDelay:0.1];
}

-(void)removeLoader{
    
    _isIndicating = NO;
    [[MSwipedButtonManager sharedManager] setEnable:YES];
}


-(IBAction)backAction:(id)sender{
    
    [self performSegueWithIdentifier:@"UnwindBack" sender:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)viewWillAppear:(BOOL)animated{
//    
//    [super viewWillAppear:YES];
//    [self performSelector:@selector(mailUpdated) withObject:nil afterDelay:1.0];
    
//    [self performSelectorInBackground:@selector(mailUpdated) withObject:nil];
    
//    NSError *error;
//	if (![[self fetchedResultsController] performFetch:&error]) {
//        
//		// Update to handle the error appropriately.
//		//NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//		exit(-1);  // Fail
//	}
//    
//    [fileListTableView reloadData];
    
//}

//#pragma  mark - Fetching Data
//
//- (NSFetchedResultsController *)fetchedResultsController {
//    
//    if (_fetchedResultsController != nil) {
//        return _fetchedResultsController;
//    }
//    
//    MDataManager *dataManager = [MDataManager sharedManager];
//    NSManagedObjectContext *managedObjectContext = dataManager.managedObjectContext;
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription
//                                   entityForName:@"Attachment" inManagedObjectContext:managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    
//    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
//                              initWithKey:@"dateSaved" ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
//    
//    
//    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
//    
//    self.fetchedResultsController = theFetchedResultsController;
//    _fetchedResultsController.delegate = self;
//    
//    return _fetchedResultsController;
//    
//}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section > 0)
    {
        return 0;
    }
    return _allFileAttachments.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    double CELL_SIZE = 80.0;
    
    UICollectionViewCell *cell = [collctnView dequeueReusableCellWithReuseIdentifier:@"GALLERY_CELL" forIndexPath:indexPath];
    UIView *existingImage = [cell.contentView viewWithTag:99];
    if (existingImage != nil) {
        [existingImage removeFromSuperview];
    }
    
    Attachment *attachment = _allFileAttachments[indexPath.item];
    
    //NSLog(@"attachment.mimeType=%@",attachment.mimeType);
    
    NSArray *fileNmaeArray = [attachment.mimeType componentsSeparatedByString:@"/"];
    
    UIImage *image = [UIImage imageNamed:@"paper_icon.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.backgroundColor = [UIColor clearColor];
    
    double ratio = image.size.height / image.size.width;
    if (ratio >= 1.0) {
        //vertical image
        double height = CELL_SIZE * ratio;
        double offsetY = (height - CELL_SIZE) / 2.0;
        imageView.frame = CGRectMake(0, -offsetY, CELL_SIZE, height);
    }
    else {
        //horizontal image
        double width = CELL_SIZE / ratio;
        double offsetX = (width - CELL_SIZE) / 2.0;
        imageView.frame = CGRectMake(-offsetX, 0.0, width, CELL_SIZE);
    }
    
    imageView.tag = 99;
    [cell.contentView addSubview:imageView];
    
    UILabel *filNameLab = [[UILabel alloc] init];
    filNameLab.text = [fileNmaeArray objectAtIndex:1];
    filNameLab.backgroundColor = [UIColor lightGrayColor];
    filNameLab.frame = CGRectMake(5, 30, 70, 20);
    filNameLab.font = [UIFont boldSystemFontOfSize:12];
    filNameLab.textAlignment = NSTextAlignmentCenter;

    [imageView addSubview: filNameLab];
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Attachment *attachment = _allFileAttachments[indexPath.item];
    
    [self performSegueWithIdentifier:@"fileSelect" sender:attachment];
    
    
//    Message *message = attachment.message;
//    [self performSegueWithIdentifier:@"fileSelect" sender:message];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"fileSelect"]) {
        
        Attachment *attachment = sender;
        
//        NSArray *fileNmaeArray = [attachment.mimeType componentsSeparatedByString:@"/"];
//
//        //NSLog(@"fileNmaeArray=%@",[fileNmaeArray objectAtIndex:0]);
//
//        NSString *fileTypeStr = [fileNmaeArray objectAtIndex:0];
//
//        if ([fileTypeStr isEqualToString:@"image"]) {
//
//        }
//        else if ([fileTypeStr isEqualToString:@"audio"]) {
//
//        }
//        else if ([fileTypeStr isEqualToString:@"video"]) {
//
//        }
//        else if ([fileTypeStr isEqualToString:@"application"]) {
//            
//        }
//        
//        else{
//            
//        }

        MDetailViewController *detailView = segue.destinationViewController;
        detailView.message = attachment.message;
        detailView.isPictureMode = YES;
        
        
//        Message *message = sender;
//        MDetailViewController *detailController = segue.destinationViewController;
//        detailController.message = message;
//        
//        
//        
//        Message *message = sender;
//        UINavigationController *replyNavController = (UINavigationController *)segue.destinationViewController;
//        replyNavController.view.tintColor = [MDesignManager tintColor];
//        replyNavController.navigationBar.barTintColor = [MDesignManager tintColor];
//        replyNavController.navigationBar.tintColor = [MDesignManager highlightColor];
//        replyNavController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[MDesignManager highlightColor]};
//        
//        MWriteMessageViewController *writeController = (MWriteMessageViewController *)replyNavController.topViewController;
//        writeController.originalMessage = message;
//        writeController.textPart = (MCOAttachment *)_textPart;

        
    }
}


@end
