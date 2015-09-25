//
//  MGalleryViewController.m
//  Mailer
//
//  Created by Martin Ceperley on 10/28/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MGalleryViewController.h"
#import "Attachment.h"
#import "Message.h"
#import "MDetailViewController.h"
#import "MMailManager.h"
#import "Account.h"
#import "MDataManager.h"
#import "MDesignManager.h"
#import "MCyclingViewController.h"

const NSUInteger MIN_IMAGE_SIZE = 51200;

@interface MGalleryViewController ()
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation MGalleryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) mailUpdated
{
    
    MDataManager *dataManager = [MDataManager sharedManager];
    NSManagedObjectContext *managedObjectContext = dataManager.managedObjectContext;
    
//    imageAttachments = [Attachment findAllSortedBy:@"dateSaved" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"isImage == YES  && %K >= %@", @"size", [NSNumber numberWithUnsignedInteger:MIN_IMAGE_SIZE]]inContext:managedObjectContext];
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K < %@",
//                              @"size", [NSNumber numberWithUnsignedInteger:MIN_IMAGE_SIZE]];
    
    
     imageAttachments = [Attachment findAllSortedBy:@"dateSaved" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"isImage == YES   && message.account.status == YES && %K >= %@", @"size", [NSNumber numberWithUnsignedInteger:MIN_IMAGE_SIZE]]inContext:managedObjectContext];
    if ([imageAttachments count]<=0) {
        if (!self.emptyLabel) {
            self.emptyLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
            self.emptyLabel.textAlignment = NSTextAlignmentCenter;
            self.emptyLabel.text = @"No pictures avaiable in device.";
            [self.view addSubview:self.emptyLabel];
        }
    } else {
        if (!self.emptyLabel) {
            [self.emptyLabel removeFromSuperview];
            self.emptyLabel = nil;
        }
    }
    
//     imageAttachments = [Attachment findAllSortedBy:@"dateSaved" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"isImage = YES AND message.account.status = YES"] inContext:managedObjectContext];
    
//     NSLog(@"_imageAttachments = %@",imageAttachments);
   
    [self.collectionView reloadData];
    
     [self performSelector:@selector(removeLoader) withObject:nil afterDelay:0.1];
    
}

-(void)removeLoader{
    
    _isIndicating = NO;
    [[MSwipedButtonManager sharedManager] setEnable:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Pictures";
    
//    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    _isIndicating = YES;
    [[MSwipedButtonManager sharedManager] setEnable:NO];
    
    [self performSelector:@selector(mailUpdated) withObject:nil afterDelay:0.1];

    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(mailUpdated) name:FETCHED_NEW_ATTACHMENT_NOTIFICATION object:nil];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"paper_clip.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
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
    
    if (!_isIndicating) {
        
        
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            
            [self composeNewMessage];
            
            
        }
        
      
        
    }
    
}



- (void)composeNewMessage{
    
    [self performSegueWithIdentifier:@"composeNewMessageFromGallery" sender:self];
}

-(IBAction)backAction:(id)sender{
    
     [self performSegueWithIdentifier:@"UnwindBack" sender:self];
    
//     [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gallerySelect"]) {
        Message *message = sender;
        MDetailViewController *detailController = segue.destinationViewController;
        detailController.message = message;
        detailController.isPictureMode = YES;
        
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section > 0)
    {
        return 0;
    }
    return imageAttachments.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    double CELL_SIZE = 100.0;
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"GALLERY_CELL" forIndexPath:indexPath];
    UIView *existingImage = [cell.contentView viewWithTag:99];
    
    if (existingImage != nil) {
        [existingImage removeFromSuperview];
    }
    
    Attachment *attachment = imageAttachments[indexPath.item];
    UIImage *image = attachment.image;
    
    
    //Reducing image size
    
    
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 320.0/480.0;
    
    if(imgRatio!= maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = 480.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 480.0;
        }
        else{
            imgRatio = 320.0 / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = 320.0;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    
    if (finalImage) {
        
    UIImageView *imageView = [[UIImageView alloc] initWithImage:finalImage];

    double ratio = finalImage.size.height / finalImage.size.width;
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
        
//        imageView = nil;

    }
    
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
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2) - 44);
    [self.collectionView addSubview:spinner];
    
    
    spinner.color = [MDesignManager tintColor];
    [spinner startAnimating];
    
    [self performSelector:@selector(loadDetailView:) withObject:indexPath afterDelay:.1];
    
}

-(void)loadDetailView :(NSIndexPath *)indexPath{
    
    Attachment *attachment = imageAttachments[indexPath.item];
    Message *message = attachment.message;
    [self performSegueWithIdentifier:@"gallerySelect" sender:message];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[MSwipedButtonManager sharedManager] setHidden:YES];
    [MSwipedButtonManager sharedManager].delegate = nil;
    if([spinner isDescendantOfView:[self view]]) {
        
        [spinner stopAnimating];
        [spinner removeFromSuperview];
    }
    [[MSwipedButtonManager sharedManager] setEnable:YES];
    
}


@end
