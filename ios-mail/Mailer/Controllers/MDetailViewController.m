//
//  MDetailViewController.m
//  Mailer
//
//  Created by Martin Ceperley on 9/20/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MDetailViewController.h"
#import "MAppDelegate.h"
#import "MMailManager.h"
#import "Message.h"
#import "Attachment.h"
#import "MPlainTextMessageView.h"
#import "MMessageListController.h"
#import "MWriteMessageViewController.h"
#import "MAttachmentsView.h"
#import "MDesignManager.h"
#import "MPDFViewController.h"

@interface MDetailViewController ()
- (void)configureView;
@end

@implementation MDetailViewController

#pragma mark - Managing the detail item

- (void)setMessage:(Message *)newMessage
{
    if (_message != newMessage) {
        BOOL shouldConfigureView = _message != nil;
        _message = newMessage;
        
        if (shouldConfigureView) {
            [self configureView];

        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    //NSLog(@"_isPictureMode = %d",_isPictureMode);
    if (!_isPictureMode) {
        [self.navigationController setToolbarHidden:NO animated:NO];

    }
    else{
        [self.navigationController setToolbarHidden:YES animated:NO];
    }
    
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    [self configureView];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon-1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    UIBarButtonItem *home = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"paper_clip.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backToHome)];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:back, home, nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addMoviePlayer:) name:@"Video" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addAudioPlayer:) name:@"Audio" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pdfLoader:) name:@"PDF" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showAlert) name:@"Alert" object:nil];
    
//    if (!_shortMode) {
    
        swipeDetailBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [swipeDetailBut setImage:[UIImage imageNamed:@"pen-icon.png"] forState:UIControlStateNormal];
        swipeDetailBut.frame = CGRectMake((self.view.frame.size.width/2)-35, [[UIApplication sharedApplication] keyWindow].frame.size.height-120, 70, 70);
        
        //    [[[UIApplication sharedApplication] keyWindow] addSubview:swipeDetailBut];
        
        [self.view addSubview:swipeDetailBut];
        
        UIPanGestureRecognizer *panGesture;
        panGesture = [[UIPanGestureRecognizer alloc]
                      initWithTarget:self action:@selector(handlePan:)];
        //    panGesture.delegate = viewController;
        [swipeDetailBut addGestureRecognizer:panGesture];
        
        UILongPressGestureRecognizer *btn_LongPress_gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleBtnLongPressgesture:)];
        [btn_LongPress_gesture setMinimumPressDuration:.15];
        [swipeDetailBut addGestureRecognizer:btn_LongPress_gesture];

//    }
    
}


#pragma mark - UIPanGesture

- (void) handlePan:(UIPanGestureRecognizer *)recognizer
{
    
        swipeDetailBut.center = [recognizer locationInView:swipeDetailBut.superview];
        
//    NSLog(@"recognizer.x ==== %f",[recognizer locationInView:swipeDetailBut.superview].x);
//    NSLog(@"recognizer.y ==== %f",[recognizer locationInView:swipeDetailBut.superview].y);
    
    
    
    
//            NSLog(@"recognizer.view.center.y ==== %f",recognizer.view.center.y);
    
        
        NSInteger height = [[UIApplication sharedApplication] keyWindow].frame.size.height + 0.5f;
    
//     NSLog(@"height = %d",height);
    
    
    if(recognizer.state == UIGestureRecognizerStateEnded)

        {
            
//            [self gotoNextMessage];
//            [self gotoPreviousMessage];
            
            
            swipeDetailBut.userInteractionEnabled = NO;
            
            
            switch (height)
            {
                case 568:
                    //iPhone 5
                {
                    
                    //                if ((recognizer.view.center.x > 170)&&(recognizer.view.center.y > 470)&&(recognizer.view.center.y < 500)){
                    
                    if ((recognizer.view.center.x > 170)&&(recognizer.view.center.y > 200)&&(recognizer.view.center.y < 560)){
                        
//                        NSLog(@"gotoPreviousMessage");
                        
                        [self gotoPreviousMessage];
                        
                        
                        
                    }
                    //                else if ((recognizer.view.center.x < 170)&&(recognizer.view.center.y > 470)&&(recognizer.view.center.y < 500)){
                    
                    else if ((recognizer.view.center.x < 170)&&(recognizer.view.center.y > 200)&&(recognizer.view.center.y < 560)){
                        
                        
//                         NSLog(@"gotoNextMessage");
                          [self gotoNextMessage];
                        
                        
                        
                    }
//                    else{
                    
                        
                                [UIView beginAnimations:@"presentWithSuperview" context:nil];
                                [UIView setAnimationDuration:0.3];
                                
                                 swipeDetailBut.frame = CGRectMake((self.view.frame.size.width/2)-35, [[UIApplication sharedApplication] keyWindow].frame.size.height-120, 70, 70);
                                
                                [UIView commitAnimations];
                        
//                    }
                    
                }
                    
                    break;
                    
                case 480:
                    //iPhone
                {
                    
                    
                    if ((recognizer.view.center.x > 170)&&(recognizer.view.center.y > 150)&&(recognizer.view.center.y < 460)){
                        
                        
//                        NSLog(@"gotoPreviousMessage");
                        
                        [self gotoPreviousMessage];
                        
                        
                    }
                    else if ((recognizer.view.center.x < 170)&&(recognizer.view.center.y > 150)&&(recognizer.view.center.y < 460)){
                        
//                        NSLog(@"gotoNextMessage");
                        
                        
                        [self gotoNextMessage];
                        
                    }
//                    else{
                    
                                [UIView beginAnimations:@"presentWithSuperview" context:nil];
                                [UIView setAnimationDuration:0.3];
                                
                                swipeDetailBut.frame = CGRectMake((self.view.frame.size.width/2)-35, [[UIApplication sharedApplication] keyWindow].frame.size.height-120, 70, 70);
                                
                                [UIView commitAnimations];
//                    }
                    
                }
                    
                    break;
                    
                default:
                    //iPad
                    
                {
                    if ((recognizer.view.center.x > 395)&&(recognizer.view.center.y > 200)&&(recognizer.view.center.y < 1000)){
                        //                    if ((recognizer.view.center.x > 395)&&(recognizer.view.center.y > 930)&&(recognizer.view.center.y < 970)){
                        
//                        NSLog(@"gotoPreviousMessage ");
                        
                          [self gotoPreviousMessage];
                        
                    }
                    else if ((recognizer.view.center.x < 395)&&(recognizer.view.center.y > 200)&&(recognizer.view.center.y < 1000)){
                        //                    else if ((recognizer.view.center.x < 395)&&(recognizer.view.center.y > 930)&&(recognizer.view.center.y < 970)){
                        
//                          NSLog(@"gotoNextMessage");
                        
                        
                         [self gotoNextMessage];
                    }
//                    else{
                    
                                [UIView beginAnimations:@"presentWithSuperview" context:nil];
                                [UIView setAnimationDuration:0.3];
                                
                                swipeDetailBut.frame = CGRectMake((self.view.frame.size.width/2)-35, [[UIApplication sharedApplication] keyWindow].frame.size.height-120, 70, 70);
                                
                                [UIView commitAnimations];
                                
                        
//                    }
                    
                }
                    
                    break;
            }
            
            
            swipeDetailBut.userInteractionEnabled = YES;
        }
    
}

#pragma mark - UILongPressGestureRecognizer

- (void)handleBtnLongPressgesture:(UILongPressGestureRecognizer *)recognizer{
    
    if (![_loadingIndicator isAnimating]) {
        
        //as you hold the button this would fire
        
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            
            if(_shortMode){
                
//                UIActionSheet *actionSht = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Skip",@"Reply" ,@"Reply All",@"Forward",@"Delete",nil];
                
                UIActionSheet *actionSht = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply" ,@"Reply All",@"Forward",nil];
                
                actionSht.tag = 2;
                [actionSht showInView:[UIApplication sharedApplication].keyWindow];
                
            }
            else{
                
//                UIActionSheet *actionSht = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply",@"Reply All",@"Forward",@"Trash",nil];
                
                UIActionSheet *actionSht = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply",@"Reply All",@"Forward",nil];
                
                actionSht.tag = 1;
                [actionSht showInView:[UIApplication sharedApplication].keyWindow];
            }
            
            //            [self composeNewMessage];
            //            NSLog(@"recognizer.x ==== %f",[recognizer locationInView:swipeDetailBut.superview].x);
            //            NSLog(@"recognizer.y ==== %f",[recognizer locationInView:swipeDetailBut.superview].y);
            
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message is loading" message:@"Please wait." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    }
    
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1:
            
            switch (buttonIndex) {
                case 0:{
                    
                    _replyType = 1;
                    [self replyItemPressed];
                }
                    
                    break;
                case 1:
                {
                    //Reply All
                    _replyType = 2;
                    [self replyItemPressed];
                }
                    
                    break;
                case 2:
                    
                {
                    //Forward
                    _replyType = 3;
                    [self replyItemPressed];
                }
                    
                    break;
//                case 3:
//                    [self trashPressed];
//                    break;
                default:
                    break;
            }
            
            break;
            
            
        case 2:
            
            switch (buttonIndex) {
//                case 0:
//                    [self passPressed];
//                    break;
                case 0:
                {
                    _replyType = 1;
                    [self replyItemPressed];
                }

                    break;
                case 1:
                {
                    //Reply All
                    _replyType = 2;
                    [self replyItemPressed];
                }
                    
                    break;
                case 2:
                {
                    //Forward
                    _replyType = 3;
                    [self replyItemPressed];
                }
                    
                    break;

//                case 4:
//                    [self deletePressed];
//                    break;
                default:
                    break;
            }

            break;
        
        default:
            break;
    }

}

#pragma mark - Next / Prev actions

- (void) showNextMessage
{
//    NSLog(@"showNextMessage");
    
    NSArray *messages;
    if (_peopleMode) {
        messages = self.messageArray ;
    }
    else{
        if (_fetchedResultsController == nil) {
            //NSLog(@"showNextMessage but no fetchedResultsController");
            return;
        }
        
         messages = self.fetchedResultsController.fetchedObjects;
        
//         NSLog(@"self.fetchedResultsController.count = %d",self.fetchedResultsController.fetchedObjects.count);
//         NSLog(@"_fetchedResultsController.count = %d",_fetchedResultsController.fetchedObjects.count);

    }
    
    if (self.fetchedResultsController.fetchedObjects.count) {
    
    NSUInteger currentIndex = [messages indexOfObject:_message];
    NSUInteger nextIndex = 0;
    if (currentIndex + 1 < messages.count) {
        nextIndex = currentIndex + 1;
    }
    
    //NSLog(@"showNextMessage messages count: %lu currentIndex: %lu nextIndex: %lu", (unsigned long)messages.count, (unsigned long)currentIndex, (unsigned long)nextIndex);
    
    self.message = messages[nextIndex];
    [self.message markRead];
        
    }

}

- (void) showPreviousMessage
{
//    NSLog(@"showNextMessage");
    
    NSArray *messages;
    if (_peopleMode) {
        messages = self.messageArray ;
    }
    else{
        if (_fetchedResultsController == nil) {
            //NSLog(@"showNextMessage but no fetchedResultsController");
            return;
        }
        
        messages = self.fetchedResultsController.fetchedObjects;
        
//        NSLog(@"self.fetchedResultsController.count = %d",self.fetchedResultsController.fetchedObjects.count);
//        NSLog(@"_fetchedResultsController.count = %d",_fetchedResultsController.fetchedObjects.count);
        
    }
    
    if (self.fetchedResultsController.fetchedObjects.count) {
        
        NSUInteger currentIndex = [messages indexOfObject:_message];
        NSUInteger nextIndex = 0;
        
        if ((currentIndex - 1 < messages.count) && ( currentIndex - 1 > -1 )) {
            nextIndex = currentIndex - 1;
        }
        
        //NSLog(@"showNextMessage messages count: %lu currentIndex: %lu nextIndex: %lu", (unsigned long)messages.count, (unsigned long)currentIndex, (unsigned long)nextIndex);
        
        self.message = messages[nextIndex];
        [self.message markRead];
        
    }
    
}




//Modified by 3E ------START------

- (void) gotoNextMessage{
    
//    NSLog(@"gotoNextMessage");
    
    if (_peopleMode) {
        
//         NSLog(@"_peopleMode");
        
        NSInteger index=[self.messageArray indexOfObject:_message];
        NSInteger updatedIndex;
        
        if (index < [self.messageArray count]-1) {
            updatedIndex = index + 1;
        }
        else{
            updatedIndex = index;
        }
        
        self.message = [self.messageArray objectAtIndex:updatedIndex];
        
    }
    else{
        
//        if (_shortMode) {
//            
//            [self showNextMessage];
//            
//            
//        }
//        else{
        
//            NSLog(@"Not  _peopleMode");
//            NSLog(@"self.fetchedResultsController.count = %d",self.fetchedResultsController.fetchedObjects.count);
        
            NSIndexPath *index=[self.fetchedResultsController indexPathForObject:_message];
            
//            NSLog(@"index = %@",index);
        
            if (index) {
                
                NSIndexPath *updatedIndex;
                if (index.row < [self.fetchedResultsController.fetchedObjects count]-1)
                    updatedIndex=[NSIndexPath indexPathForRow:index.row+1 inSection:index.section];
                
                else
                    updatedIndex=[NSIndexPath indexPathForRow:index.row inSection:index.section];
                
                self.message = [self.fetchedResultsController objectAtIndexPath:updatedIndex];
            }

            
        }
        
        
        
//    }
    
    [self configureView];
    Message *message = self.message;
    [message markRead];
    
}

- (void) gotoPreviousMessage{
    
    NSLog(@"gotoPreviousMessage");
    
    if (_peopleMode) {
        
        NSInteger index=[self.messageArray indexOfObject:_message];
        NSInteger updatedIndex;
        
        if (index > 0) {
            updatedIndex = index - 1;
        }
        else{
            updatedIndex = index;
        }
        
        self.message = [self.messageArray objectAtIndex:updatedIndex];
        
    }
    else{
        
//        if (_shortMode) {
//            
//            [self showPreviousMessage];
//            
//        }
//        
//        else{
        
//            NSLog(@"self.fetchedResultsController.count = %d",self.fetchedResultsController.fetchedObjects.count);
        
            NSIndexPath *index=[self.fetchedResultsController indexPathForObject:_message];
//            NSLog(@"index = %@",index);
            if (index) {
                
                NSIndexPath *updatedIndex;
                if (index.row>0)
                    updatedIndex=[NSIndexPath indexPathForRow:index.row-1 inSection:index.section];
                
                else
                    updatedIndex=[NSIndexPath indexPathForRow:index.row inSection:index.section];
                
                self.message = [self.fetchedResultsController objectAtIndexPath:updatedIndex];
//        }
             
        }
    }
    
    [self configureView];
    Message *message = self.message;
    [message markRead];
}

//Modified by 3E ------END------

- (void)passPressed{
    
    [self.message markPassed];
    
    [self showNextMessage];
}

- (void)replyPressed{
    
        [self performSegueWithIdentifier:@"reply" sender:_message];
        [self showNextMessage];
}

- (void)replyItemPressed{
    
//    if(_haveHTML){
//        
//        NSLog(@"_haveHTML");
////        [self displayHTML];
//    }
    
    if (_textPart || _htmlPart) {
        [self performSegueWithIdentifier:@"reply" sender:_message];

    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mailable" message:@"Message is loading, please wait." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"reply"]) {
        
        Message *message = sender;
        UINavigationController *replyNavController = (UINavigationController *)segue.destinationViewController;
        replyNavController.view.tintColor = [MDesignManager tintColor];
        replyNavController.navigationBar.barTintColor = [MDesignManager tintColor];
        replyNavController.navigationBar.tintColor = [MDesignManager highlightColor];
                replyNavController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[MDesignManager highlightColor]};

        MWriteMessageViewController *writeController = (MWriteMessageViewController *)replyNavController.topViewController;
        writeController.originalMessage = message;
        writeController.textPart = (MCOAttachment *)_textPart;
        writeController.boolVal = _replyType;
        
    }
    else if ([segue.identifier isEqualToString:@"pdfwebView"]) {
        
        UINavigationController *replyNavController = (UINavigationController *)segue.destinationViewController;
        replyNavController.view.tintColor = [MDesignManager tintColor];
        replyNavController.navigationBar.barTintColor = [MDesignManager tintColor];
        replyNavController.navigationBar.tintColor = [MDesignManager highlightColor];
        replyNavController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[MDesignManager highlightColor]};

            MPDFViewController *pdfController = (MPDFViewController *)replyNavController.topViewController;
        
            pdfController.urlStr = sender;
            
        }
}

- (void)archivePressed{
    
//    NSLog(@"self.fetchedResultsController.count Before= %d",self.fetchedResultsController.fetchedObjects.count);
    
    self.loadingIndicator.color = [MDesignManager tintColor];
    [self.loadingIndicator startAnimating];
    
    Message *messageToDelete = self.message;
    messageToDelete.processed = YES;
    
    [messageToDelete archiveAction];
    
//    [messageToDelete deleteMessage];
    
//    NSLog(@"self.fetchedResultsController.count After= %d",self.fetchedResultsController.fetchedObjects.count);

//    NSIndexPath *index=[self.fetchedResultsController indexPathForObject:_message];
//    [self.fetchedResultsController delete:index];
    
//    [self performSelector:@selector(stopAnimator) withObject:nil afterDelay:0.7];
    
    [self performSelector:@selector(popAction) withObject:nil afterDelay:0.7];

}

-(void)stopAnimator{
    
    [self.loadingIndicator stopAnimating];
    
    [self showNextMessage];
 
}

- (void)trashPressed{
    
    self.loadingIndicator.color = [MDesignManager tintColor];
    [self.loadingIndicator startAnimating];
    
    [self.message deleteMessage];
    
    if (_peopleMode) {
        NSInteger index=[self.messageArray indexOfObject:self.message];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:[NSString stringWithFormat:@"%li",(long)index]];
    }
    
    //[self.fetchedResultsController r]
    
    [self performSelector:@selector(popAction) withObject:nil afterDelay:0.7];
    
}

-(void)popAction{
    
    [self.loadingIndicator stopAnimating];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureView
{
//    NSLog(@"configureView shortMode: %d", _shortMode);
    
    if (_message) {
        
        if (_plainView != nil) {
            [_plainView removeFromSuperview];
            _plainView = nil;
        }
        
        if (_webView != nil) {
            [_webView removeFromSuperview];
        }
        
        _loadingMessage = YES;
        self.loadingIndicator.color = [MDesignManager tintColor];
        [self.loadingIndicator startAnimating];
        
        self.navigationItem.title = nil;
        
        //Modified by 3E ------START------
        //self.title = nil;
  
        [self.navigationController.toolbar setBarStyle:UIBarStyleBlackOpaque];
        self.navigationController.toolbar.translucent = NO;
        [self.navigationController.toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        
//        NSString *strTitle=_message.fromName == nil || [_message.fromName isEqualToString:@""] ? _message.fromAddress : _message.fromName;
//        self.navigationItem.title = strTitle;//[strTitle stringByReplacingOccurrencesOfString:@"From:" withString:@""];
        
        self.fromLabel.text = [NSString stringWithFormat:@"%@",
                               _message.fromName == nil || [_message.fromName isEqualToString:@""] ? _message.fromAddress : _message.fromName];
        
//        NSString *leftArrowString = @"\U000025C0\U0000FE0E";
//        NSString *rightArrowString = @"\U000025B6\U0000FE0E";
        
        self.fromLabel.text = [NSString stringWithFormat:@"From: %@",
                               _message.fromName == nil || [_message.fromName isEqualToString:@""] ? _message.fromAddress : _message.fromName];
        
        //self.toLabel.text = @"To: Martin";
        
        //Modified by 3E -------END-------
        
        self.subjectLabel.text = _message.subject;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        NSString *formattedDate = [dateFormatter stringFromDate:_message.receivedDate];
        
        self.dateReceivedLabel.text = formattedDate;
        
        if(_shortMode){
            
            _loadTime = [NSDate date];

            UIBarButtonItem *passItem = [[UIBarButtonItem alloc] initWithTitle:@"Skip"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(passPressed)];
//            UIBarButtonItem *replyItem = [[UIBarButtonItem alloc] initWithTitle:@"Reply"
//                                                                          style:UIBarButtonItemStylePlain
//                                                                         target:self
//                                                                         action:@selector(replyPressed)];
            UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"Archive"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(archivePressed)];
            
//            passItem.tintColor = replyItem.tintColor = deleteItem.tintColor = [MDesignManager highlightColor];
            
            passItem.tintColor = deleteItem.tintColor = [MDesignManager highlightColor];

            //Modified by 3E -------START-------
            
//            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:leftArrowString style:UIBarButtonItemStylePlain target:self action:@selector(gotoPreviousMessage)];
//            
//            UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:rightArrowString style:UIBarButtonItemStylePlain target:self action:@selector(gotoNextMessage)];
            
            [self.navigationController setToolbarHidden:NO animated:NO];
//            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//            self.toolbarItems = @[leftItem,spacer,passItem, spacer, replyItem, spacer, deleteItem,spacer,rightItem];
            
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            self.toolbarItems = @[passItem, spacer, deleteItem];

            
            
            //Modified by 3E -------END-------
            
        }
        else {

            UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashPressed)];
            
            
            UIBarButtonItem *passItem = [[UIBarButtonItem alloc] initWithTitle:@"Skip"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(passPressed)];
            
            
//            UIBarButtonItem *replyItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(replyItemPressed)];
            
            
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

//            deleteItem.tintColor = replyItem.tintColor = [MDesignManager highlightColor];
            
            deleteItem.tintColor = [MDesignManager highlightColor];


            //Modified by 3E -------START-------
//            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:leftArrowString style:UIBarButtonItemStylePlain target:self action:@selector(gotoPreviousMessage)];
//            UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:rightArrowString style:UIBarButtonItemStylePlain target:self action:@selector(gotoNextMessage)];
            
            self.toolbarItems = @[passItem, spacer, deleteItem];
            //Modified by 3E -------END-------
            
        }
        
        self.scrollView.bounces = YES;
        self.scrollView.bouncesZoom = NO;
        self.scrollView.backgroundColor = [UIColor whiteColor];
        
        
        if(_message.body != nil){
            
            
            [self displayMessage];
        }
        else {
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageBodyFetched:) name:MESSAGE_BODY_FETCHED_NOTIFICATION object:nil];
            
            [[MMailManager sharedManager] fetchMessageContent:_message highPriority:YES];
        }

    } else {
        //NSLog(@"configureView message not set");
        
    }
}

- (void) messageBodyFetched:(NSNotification *)notification
{
    NSManagedObjectID *messageID = notification.object;
    
    if ([_message.objectID isEqual:messageID]) {
//        NSLog(@"Body fetched, message ID is the same");
        if (_message.body == nil) {
            NSLog(@"hmm body is still nil");
            
        }
        else {
            
//            NSLog(@"body is not nil");
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:MESSAGE_BODY_FETCHED_NOTIFICATION object:nil];
             
            [self displayMessage];
        }
        
    } else {
        
        //NSLog(@"Body fetched, message ID is NOT the same");
    }
}

- (void) displayMessage
{
    _parser = [MCOMessageParser messageParserWithData:_message.body];
    
//    NSLog(@"_parser = %@",_parser);
    
    MCOAbstractPart* mainPart = _parser.mainPart;
    _textPart = nil;
    _htmlPart = nil;
    
    //NSData *data = parser.data;

    if(mainPart != nil){
        
        if (mainPart.partType == MCOPartTypeMultipartMixed ||
            mainPart.partType == MCOPartTypeMultipartRelated ||
            mainPart.partType == MCOPartTypeMultipartAlternative) {
            
            MCOAbstractMultipart* multipart = (MCOAbstractMultipart *)mainPart;
            
            _textPart = [MMailManager plainTextFromPart:multipart];
            _htmlPart = [MMailManager htmlFromPart:multipart];
            
        } else {
            
            NSString* mainPartMime = mainPart.mimeType.lowercaseString;
            
            if([mainPartMime isEqualToString:@"text/html"]){
                _htmlPart = mainPart;
            } else if([mainPartMime isEqualToString:@"text/plain"]){
                _textPart = mainPart;
            }
        }
        
    } else {
        NSLog(@" main part is nil");
    }
    
    _haveHTML = _htmlPart != nil;
    _havePlaintext = _textPart != nil;
    
    if(_haveHTML){
        [self displayHTML];
        
    } else if (_havePlaintext){
        [self displayText];
        
    } else {
        //NSLog(@"couldnt find html or text???");
        
    }
}

- (NSString *) fixInlineImages:(NSString *)msgHTMLBody
{
    NSArray *imageAttachments = _message.imageAttachments;
    if (imageAttachments.count == 0) {
        return msgHTMLBody;
    }

    NSString *pattern = @"<img([^>]+)>";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
    
    NSMutableString *body = [msgHTMLBody mutableCopy];
    NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
    for (Attachment *attachment in imageAttachments){
        if (attachment.contentID != nil)[content setObject:attachment forKey:attachment.contentID];
    }
    
    NSArray *matches = [regex matchesInString:msgHTMLBody options:0 range:NSMakeRange(0, msgHTMLBody.length)];
    NSUInteger rangeOffset = 0;
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = match.range;
        NSString *tagString = [msgHTMLBody substringWithRange:matchRange];
        
        NSString *cidPattern = @"\"cid:([^\"]+)\"";
        NSRegularExpression *cidRegex = [NSRegularExpression regularExpressionWithPattern:cidPattern options:NSRegularExpressionCaseInsensitive error:NULL];
        NSTextCheckingResult *result = [cidRegex firstMatchInString:tagString options:0 range:NSMakeRange(0, tagString.length)];
        if (result != nil) {
            NSRange cidStringRange = result.range;
            NSRange cidRange = [result rangeAtIndex:1];
            NSString *cidString = [tagString substringWithRange:cidRange];
            Attachment *attachment = content[cidString];
            
            if (attachment != nil) {
                
                NSString *localURLString = [NSString stringWithFormat:@"\"file://%@\"", attachment.path];
                NSRange rangeWithOffset = NSMakeRange(matchRange.location + cidStringRange.location + rangeOffset, cidStringRange.length);
                [body replaceCharactersInRange:rangeWithOffset withString:localURLString];
                NSUInteger rangeDelta = localURLString.length - cidStringRange.length;
                rangeOffset += rangeDelta;
            }
        }
    }
    
    if (rangeOffset > 0) {
        msgHTMLBody = [body copy];
    }
    
    return msgHTMLBody;
}

- (void)displayHTML
{
    if (_plainView != nil) {
        [_plainView removeFromSuperview];
        _plainView = nil;
    }
    
    if (_webView != nil) {
        [_webView removeFromSuperview];
    }
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _webView.delegate = self;
    _webView.backgroundColor = [UIColor greenColor];
    _webView.scrollView.bounces = NO;
    _webView.scrollView.bouncesZoom = NO;
    _webView.scrollView.scrollEnabled = NO;
    _webView.scrollView.delegate = self;
    _webView.hidden = YES;
    _webView.scalesPageToFit = NO;
    _webView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    [_scrollView addSubview:_webView];

    NSString *msgHTMLBody = [_parser htmlRenderingWithDelegate:_message];
    //Check for CID inline image URLS
    msgHTMLBody = [self fixInlineImages:msgHTMLBody];
    
    if(!_loadingMessage) {
        
        _loadingMessage = YES;
        self.loadingIndicator.color = [MDesignManager tintColor];
        [self.loadingIndicator startAnimating];
       
    }

    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(_dateReceivedLabel.mas_bottom).with.offset(12.0);
        //make.bottom.equalTo(@0.0);
        make.left.equalTo(@0.0);
        make.right.equalTo(self.view);
        
//         _webviewHeightConstraint.equalTo(@(_webviewHeight));
        
        _webviewHeightConstraint = make.height.equalTo(@130);

    }];
    
    _webView.backgroundColor = [UIColor greenColor];
    
    _scrollView.contentOffset = CGPointMake(0, -_scrollView.contentInset.top);
    
    if(_havePlaintext){
        
        //Modified by 3E ------START------
        
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"TEXT" style:UIBarButtonItemStylePlain target:self action:@selector(displayText)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"t.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displayText)];
        
        //Modified by 3E ------END------
        
    }
    else {
        
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self.webView loadHTMLString:msgHTMLBody baseURL:nil];
    
    [self displayAttachmentsBelow:_webView];
    
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:msgHTMLBody]]];
    
}

- (void)displayText
{
    if (_havePlaintext && [_textPart isKindOfClass:[MCOAttachment class]]){
        if (_webView != nil) {
            [_webView removeFromSuperview];
            _webView = nil;
        }
        
        MCOAttachment *textAttachment = (MCOAttachment *) _textPart;
        NSString *text = [[textAttachment decodedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        UIFont *font = [UIFont systemFontOfSize:12.0];
        NSDictionary *attDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 font, NSFontAttributeName,
                                 nil];
        NSAttributedString* att = [[NSAttributedString alloc] initWithString:text attributes:attDict];
        
        _plainView = [[MPlainTextMessageView alloc] initWithAttributedText:att];
        [_scrollView addSubview:_plainView];
        
        [_plainView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(_dateReceivedLabel.mas_bottom).with.offset(12.0);
            //make.bottom.equalTo(@0.0);
            
            make.left.equalTo(@6.0);
            make.right.equalTo(self.view).with.offset(-8.0);
        }];
        
        _plainView.backgroundColor = [UIColor greenColor];

        [self.loadingIndicator stopAnimating];

        _scrollView.scrollEnabled = YES;
        
        _loadingMessage = NO;
        
        if(_haveHTML){
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"HTML" style:UIBarButtonItemStylePlain target:self action:@selector(displayHTML)];
        } else {
            
            self.navigationItem.rightBarButtonItem = nil;
        }
        
        [self displayAttachmentsBelow:_plainView];
        
        _scrollView.contentOffset = CGPointMake(0, -_scrollView.contentInset.top);
        
        if(_shortMode){
            [self startTimer];
        }

    } else {
        
        //NSLog(@"cant display text version");
    }
}

- (void)displayAttachmentsBelow:(UIView *)aboveView
{
    
//    NSLog(@"aboveView.mas_bottom = %@",aboveView.mas_bottom);
    
    if(_attachmentsView != nil){
        
        [_attachmentsView removeFromSuperview];
        _attachmentsView = nil;
    }
    
//    NSLog(@"self.message = %@",self.message);
//    NSLog(@"self.message.attachments.count = %d",self.message.attachments.count);
//    NSLog(@"self.message.imageAttachments.count = %d",self.message.imageAttachments.count);
    
         if (self.message.attachments.count > 0) {
             
             _attachmentsView = [[MAttachmentsView alloc] initWithFrame:CGRectZero];
             [_scrollView addSubview:_attachmentsView];
             
             [_attachmentsView mas_makeConstraints:^(MASConstraintMaker *make) {
                 
                 make.top.equalTo(aboveView.mas_bottom).offset(12.0);
                 make.bottom.equalTo(@0.0);
                 make.right.equalTo(_scrollView);
                 make.left.equalTo(_scrollView);
                 make.width.equalTo(self.view);
                 
             }];
             
             _attachmentsView.attachments = self.message.attachments.array ;
             
         }
         else{
             
             [aboveView mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.bottom.equalTo(@0.0);
             }];

         }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Mark message as read in UI and on server
    
    Message *message = self.message;
    
    //if (!message.read.boolValue) {
    //    message.read = @YES;
    //}
    
    [message markRead];
}

-(void)removingNotifications{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Video"  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Audio"  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PDF"  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Alert"  object:nil];
    
    if ([theAudio isPlaying]) {
        [theAudio stop];
        theAudio = nil;
    }
    
//    if ([videoPlayerView is]) {
//        <#statements#>
//    }
    
}

-(void)addMoviePlayer : (NSNotification *)notif{

        videoPlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:notif.object];
    
//       [[NSNotificationCenter defaultCenter] addObserver: self
//                                             selector: @selector(playBackStateChanged:)
//                                                 name: MPMoviePlayerPlaybackStateDidChangeNotification
//                                               object: videoPlayerView];
    
        [self presentMoviePlayerViewControllerAnimated:videoPlayerView];
        [videoPlayerView.moviePlayer play];
}

//-(void)playBackStateChanged:(NSNotification *)notif
//{
//    MPMoviePlaybackState playbackState = [notif.object playbackState];
//    
//    switch (playbackState) {
//            
//        case MPMoviePlaybackStateStopped :
//            
//            
//            break;
//            
//        case MPMoviePlaybackStatePlaying :
//            break;
//            
//        case MPMoviePlaybackStateInterrupted :
//            break;
//    }
//}

-(void)addAudioPlayer: (NSNotification *)notif{
    
//    NSLog(@"notif.object ==== %@",notif.object);
//    NSString *surfAdvisorAudioURL = @"APP_Audio_-_HOME_PAGE.mp3";
//    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], surfAdvisorAudioURL]];
//    
//    NSLog(@"url = %@",url);

    theAudio=[[AVAudioPlayer alloc] initWithContentsOfURL:notif.object error:NULL];
    [theAudio prepareToPlay];
    
//    theAudio.numberOfLoops = -1;
    NSError *error;
	
	if (theAudio == nil)
    {
        NSLog(@"%@",[error description]);

    }
	else{
        
        [theAudio play];
    }
}

-(void)pdfLoader : (NSNotification *)notif{
    
    [self performSegueWithIdentifier:@"pdfwebView" sender:notif.object];
    
////    swipeDetailBut.frame = CGRectMake(([[UIApplication sharedApplication] keyWindow].frame.size.width/2)-35, [[UIApplication sharedApplication] keyWindow].frame.size.height-100, 70, 70);
////    [[[UIApplication sharedApplication] keyWindow] addSubview:swipeDetailBut];
//    
//    
////    containerView.frame = CGRectMake(0, 0, [[UIApplication sharedApplication] keyWindow].frame.size.width, [[UIApplication sharedApplication] keyWindow].frame.size.height);
//    
//    
////    if (![[self.view subviews] containsObject:containerView]) {
////        [self.view addSubview:containerView];
////    }
////    
//    UIWebView *webView = (UIWebView *)[containerView viewWithTag:10];
//    
//    webView.scalesPageToFit = YES;
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:notif.object];
//    [webView loadRequest:request];
//    
//    
//    UIButton *cancelBtn = (UIButton *)[containerView viewWithTag:20];
//    [cancelBtn addTarget:self action:@selector(cancelPdfView:) forControlEvents:UIControlEventTouchUpInside];
//    
//
//    containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
//    
////    containerView.backgroundColor = [UIColor clearColor];
////
//////    webView.backgroundColor = [UIColor grayColor];
////    
////    [self.view addSubview:popUp];
////
////    [[[UIApplication sharedApplication] keyWindow] addSubview:containerView];
//
//    [self.view addSubview:containerView];
//    
//    [UIView animateWithDuration:0.3/1.5 animations:^{
//        containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
//    } completion:^(BOOL finished) {
//        
//    }];
    
}

-(void)showAlert{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File doesn't support" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alert show];
    
}

-(void)backAction{
    
    [self removingNotifications];
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)backToHome{
    
    [self removingNotifications];
    
//    [self performSegueWithIdentifier:@"UnwindBack" sender:self];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    MAppDelegate *delegate = (MAppDelegate *) [[UIApplication sharedApplication]delegate];
    [self.navigationController popToViewController:delegate.parentViewCntrllr animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setHeightConstraintOnView:(UIView *)view height:(CGFloat)newHeight
{
    for(NSLayoutConstraint* constraint in view.constraints){
        if(constraint.firstAttribute == NSLayoutAttributeHeight){
            
            constraint.constant = newHeight;
            return;
        }
    }

}

- (void)didPinch
{
    //NSLog(@"didPinch scale: %f contentSize: %@ _initialSize: %@", _pinchRecognizer.scale, NSStringFromCGSize(_webView.scrollView.contentSize), NSStringFromCGSize(_initialSize));
    //NSLog(@"_webBrowserView frame: %@", NSStringFromCGRect(_webBrowserView.frame));

    
    CGFloat newHeight = _pinchRecognizer.scale * _initialSize.height;
    CGFloat newZoom = _pinchRecognizer.scale * _initialZoom;
    if ((!_webView.scrollView.scrollEnabled) && newZoom > _initialZoom) {
        _webView.scrollView.scrollEnabled = YES;
    }
    
    CGFloat relativeScale = newHeight / _webviewHeight;
    
    if(newZoom < 0.75){
        //NSLog(@"Won't go smaller than original height");
        return;
    }
    
    if(newZoom > 1.5){
        //NSLog(@"Won't zoom in more than 1.5");

        return;
    }
    
    //CGFloat newWidth = _pinchRecognizer.scale * _initialSize.width;
    
    //this location needs to stay the same after changes
    //CGPoint locationInView = [_pinchRecognizer locationInView:self.view];

    //CGPoint locationInScrollview = [_pinchRecognizer locationInView:_scrollView];
    CGPoint touchWebviewLocation = [_pinchRecognizer locationInView:_webView];
    
    CGPoint scaledtouchWebviewLocation = CGPointMake(touchWebviewLocation.x * relativeScale, touchWebviewLocation.y * relativeScale);
    CGPoint touchOffset = CGPointMake(scaledtouchWebviewLocation.x - touchWebviewLocation.x, scaledtouchWebviewLocation.y - touchWebviewLocation.y);


    //NSLog(@"didPinch scale: %f velocity: %f location in scrollview: %@ newHeight: %f newZoom: %f heightDelta: %f", _pinchRecognizer.scale, _pinchRecognizer.velocity, NSStringFromCGPoint(locationInScrollview), newHeight, newZoom, heightDelta);

    _webviewHeight = newHeight;
    _webviewHeightConstraint.equalTo(@(_webviewHeight));
    
    //_webviewWidthConstraint.constant = newWidth;
    //(@"contentSize after: %@", NSStringFromCGSize(_webView.scrollView.contentSize));

    
    _webView.scrollView.maximumZoomScale = newZoom;
    _webView.scrollView.minimumZoomScale = newZoom;
    
    [_webView.scrollView setZoomScale:newZoom animated:NO];
    
    
    //_webView.scrollView.transform = CGAffineTransformMakeScale(newZoom, newZoom);

    //NSLog(@"didPinch contentSize after: %@", NSStringFromCGSize(_webView.scrollView.contentSize));

    //[_webView.scrollView setContentSize:CGSizeMake(newWidth, _webView.scrollView.contentSize.height)];

    //NSLog(@"contentSize after setZoomScale: %@", NSStringFromCGSize(_webView.scrollView.contentSize));
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x+touchOffset.x, _scrollView.contentOffset.y+touchOffset.y) animated:NO];
    
    //[self.scrollView setNeedsLayout];
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"gestureRecognizerShouldBegin zoomScale: %f height: %f contentSize: %@", _webView.scrollView.zoomScale, _webView.frame.size.height, NSStringFromCGSize(_webView.scrollView.contentSize));
    _initialSize = CGSizeMake(_webView.scrollView.contentSize.width ,_webView.frame.size.height);
    _initialZoom = _webView.scrollView.zoomScale;

    return YES;
}


//Modified by 3E ------START------

//-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
//    
//    if ([recognizer direction] == UISwipeGestureRecognizerDirectionLeft) {
//        
////        //NSLog(@"Left Swipe received.");
//        [self gotoNextMessage];
//        
//    }
//    else if ([recognizer direction] == UISwipeGestureRecognizerDirectionRight) {
//        
////        //NSLog(@"Right Swipe received.");
//        
//        [self gotoPreviousMessage];
//    }
//}


//Modified by 3E ------END------

#pragma mark UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //NSLog(@"webViewDidFinishLoad");
    
    if (!_loadingMessage) {
        return;
    }
    _loadingMessage = NO;
    
    _pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinch)];
    _pinchRecognizer.delegate = self;
    
    [self.scrollView addGestureRecognizer:_pinchRecognizer];
    
    //Modified by 3E ------START------
    
//    UISwipeGestureRecognizer *recognizer;
//    
//    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
//    [self.scrollView addGestureRecognizer:recognizer];
//    
//    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//    [self.scrollView addGestureRecognizer:recognizer];
    
    
    //Modified by 3E ------END------
    
    //for(UIView *subview in webView.scrollView.subviews){
        //NSLog(@"Subview: %@ Instrinsic: %@", subview, NSStringFromCGSize(subview.intrinsicContentSize) );
        //for(UIView *subsubview in subview.subviews){
        //    //NSLog(@"subsubview: %@ Instrinsic: %@", subsubview, NSStringFromCGSize(subview.intrinsicContentSize) );
        //}
    //}
    _webBrowserView = [webView.scrollView.subviews firstObject];
    _webBrowserView.backgroundColor = [UIColor whiteColor];
    
    //webView.scrollView.backgroundColor = [UIColor blueColor];
    //self.scrollView.backgroundColor = [UIColor greenColor];
    //self.webView.backgroundColor = [UIColor redColor];
    //NSLog(@"webViewDidFinishLoad contentSize: %@ contentOffset: %@", NSStringFromCGSize(webView.scrollView.contentSize), NSStringFromCGPoint(webView.scrollView.contentOffset) );
    
    _originalContentSize = webView.scrollView.contentSize;
    //NSLog(@"_originalContentSize frame: %@", NSStringFromCGSize(_originalContentSize));

    CGFloat contentWidth = webView.scrollView.contentSize.width;
    CGFloat frameWidth = self.view.bounds.size.width;
    CGFloat scaleFactor = frameWidth / contentWidth;
    //NSLog(@"Scale factor %f/%f: %f", frameWidth, contentWidth, scaleFactor);
    CGFloat scaledContentHeight = scaleFactor * webView.scrollView.contentSize.height;

    //NSLog(@"INITIAL zoomScale %f contentScale %f contentOffset %@ contentSize %@" , webView.scrollView.zoomScale, webView.scrollView.contentScaleFactor, NSStringFromCGPoint(webView.scrollView.contentOffset), NSStringFromCGSize(webView.scrollView.contentSize) );

    //webView.scrollView.maximumZoomScale = scaleFactor * 1.5;
    //webView.scrollView.maximumZoomScale = scaleFactor;
    //webView.scrollView.minimumZoomScale = scaleFactor;

    webView.scrollView.maximumZoomScale = 1.0;
    webView.scrollView.minimumZoomScale = 1.0;

    //[webView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom = 0.5;"];

    //NSString* js =
    //@"var meta = document.createElement('meta'); "
    //"meta.setAttribute( 'name', 'viewport' ); "
    //"meta.setAttribute( 'content', 'width = device-width' ); "
    //"document.getElementsByTagName('head')[0].appendChild(meta)";
    //[webView stringByEvaluatingJavaScriptFromString: js];

    //[webView.scrollView setZoomScale:scaleFactor animated:NO];
    //[_webBrowserView setContentScaleFactor:scaleFactor];
    //NSLog(@"_webBrowserView contentScale: %f", _webBrowserView.contentScaleFactor);
    
    webView.scrollView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    
    //NSLog(@"AFTER INITIAL SETZOOMSCALE zoomScale %f contentOffset %@ contentSize %@" , webView.scrollView.zoomScale, NSStringFromCGPoint(webView.scrollView.contentOffset), NSStringFromCGSize(webView.scrollView.contentSize) );
    
    _webviewHeight = scaledContentHeight;
    _webviewHeightConstraint.equalTo(@(_webviewHeight));
    

    [self.loadingIndicator stopAnimating];
    [_textView removeFromSuperview];
    webView.hidden = NO;
    
    if(_shortMode){
        [self startTimer];
    }
}

- (void)startTimer
{
    _loadTime = [NSDate date];
    _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTick) userInfo:nil repeats:YES];
    [self timeTick];
}

- (void)timeTick
{
    NSTimeInterval seconds = [_loadTime timeIntervalSinceNow];
    NSInteger secondsInt = (int) -1 * round(seconds);
    NSInteger minutesInt = 0;
    
    if (secondsInt >= 60) {
        minutesInt = (int) secondsInt / 60.0;
        secondsInt = secondsInt - (minutesInt * 60);
    }
    
    self.title = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutesInt, (long)secondsInt];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //NSLog(@"webView shouldStartLoadWithRequest: %@ type: %d", request, (int)navigationType);
    
    if(_loadingMessage){
        return YES;
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
    }
    
    return NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    //Modified by 3E ------START------

    if (_webView != nil) {
        _webView.delegate=nil;
        _webView=nil;
    }
    _peopleMode = NO;
    
    //Modified by 3E ------END------

}

#pragma mark UIScrollViewDelegate methods
/*
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    //return nil;
    return _webBrowserView;
}


- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    //NSLog(@"scrollViewWillBeginZooming zoomScale: %f", scrollView.zoomScale);
    //NSLog(@"ZOOM WILL START zoomScale %f contentOffset %@ contentSize %@" , scrollView.zoomScale, NSStringFromCGPoint(scrollView.contentOffset), NSStringFromCGSize(scrollView.contentSize) );

    _initialYOffset = _scrollView.contentOffset.y;
}
 */
/*
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (scrollView == self.webView.scrollView) {
        
        //NSLog(@"ZOOMED zoomScale %f contentScale %f contentOffset %@ contentSize %@" , scrollView.zoomScale, scrollView.contentScaleFactor, NSStringFromCGPoint(scrollView.contentOffset), NSStringFromCGSize(scrollView.contentSize) );
        
        //CGPoint inverseOffset = CGPointMake(0, scrollView.contentOffset.y * -1.0);
        //CGFloat newYOffset = _initialYOffset + scrollView.contentOffset.y;
        //NSLog(@"ZOOMED scale: %f newYOffset: %f + %f = %f", scrollView.zoomScale, _initialYOffset, scrollView.contentOffset.y, newYOffset);
        //NSLog(@"ZOOMED outer Y Offset: %f inner Y Offset: %f delta: %f", self.scrollView.contentOffset.y, scrollView.contentOffset.y, deltaY);
        //[_scrollView setContentOffset:CGPointMake(0.0, newYOffset) animated:NO];
        //[scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0.0) animated:NO];
        
        
        //NSLog(@"ZOOMED zoomscale: %f setting webview height: %f", scrollView.zoomScale, scrollView.contentSize.height*scrollView.zoomScale);
        //NSLog(@"ZOOMED zoomScale %f contentOffset %@ contentSize %@" , scrollView.zoomScale, NSStringFromCGPoint(scrollView.contentOffset), NSStringFromCGSize(scrollView.contentSize) );

        //[scrollView setContentOffset:CGPointZero animated:NO];
        
        //_webviewHeightConstraint.constant = scrollView.contentSize.height*scrollView.zoomScale;

        //[self setHeightConstraintOnView:self.webView height:scrollView.contentSize.height];

    }
}
 */

/*
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    //NSLog(@"scrollViewDidEndZooming atScale: %f contentoffset: %@", scale, NSStringFromCGPoint(scrollView.contentOffset));

    
    //scrollView.transform = CGAffineTransformScale(scrollView.transform, scale, scale);
    
    //NSLog(@"_webBrowserView bounds %@ frame %@", NSStringFromCGRect(_webBrowserView.bounds), NSStringFromCGRect(_webBrowserView.bounds));
    //[_webBrowserView setContentScaleFactor:scale];
    
    //_webBrowserView.transform = CGAffineTransformMakeScale(scale, scale);
        //_webviewHeightConstraint.constant = _originalContentSize.height * scale;

    //CGFloat newHeight = _originalContentSize.height * scale;
    //NSLog(@"Setting new webview height to: %f", newHeight);
    //[self setHeightConstraintOnView:self.webView height:newHeight];

}
 */

@end
