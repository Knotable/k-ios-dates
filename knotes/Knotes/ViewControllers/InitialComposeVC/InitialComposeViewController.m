//
//  InitialComposeViewController.m
//  Knotable
//
//  Created by Agus Guerra on 5/15/15.
//
//

#import "InitialComposeViewController.h"
#import "CalendarEventManager.h"
#import "ThreadSelectionViewController.h"
#import "TopicManager.h"
#import "ThreadItemManager.h"
#import "DataManager.h"
#import "KnoteTextView.h"
#import "PostingManager.h"
#import "ThreadViewController.h"
#import "CombinedViewController.h"
#import "BWStatusBarOverlay.h"

@interface InitialComposeViewController () <ThreadSelectionDelegate>

@property (nonatomic, strong) TopicsEntity *selectedTopic;
@property (nonatomic, strong) TopicsEntity *temporaryTopicEntity;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSDictionary *fullAddress;
@property (nonatomic, strong) NSString *cityAddress;
@property (nonatomic) NSString* padTitle;

//@property (nonatomic, weak) IBOutlet UITextField *padTitleTextField;
@property (nonatomic, weak) IBOutlet KnoteTextView *padBodyTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verConsPadBodyTextView;
//@property (weak, nonatomic) IBOutlet UITextField *knoteTitleField;
@property (nonatomic) NSTimer* idleTimer;

@end

@implementation InitialComposeViewController

- (void)dealloc
{
    [self.idleTimer invalidate];
    self.idleTimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initProperties];
    [self loadLocationManager];
    [self loadCalendarEventManager];
    [self loadPadTitle];
//    [self loadLastContent];
//    [self createTemporaryTopic];
    [self notifyKeyboardActions];
//    [self addSwipeGestureRecognizer];
    
    self.idleTimer = [NSTimer scheduledTimerWithTimeInterval: 2
                                                      target: self
                                                    selector: @selector(backupCurrentEdit)
                                                    userInfo: nil
                                                     repeats: YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
//    [self.knoteTitleField becomeFirstResponder];
    [self.padBodyTextView becomeFirstResponder];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    if ([AppDelegate sharedDelegate].barstyleloaderCombine!=nil)
    {
        [[AppDelegate sharedDelegate].barstyleloaderCombine setBackgroundColor:[UIColor whiteColor]];
    }
    if ([AppDelegate sharedDelegate].barstyleloaderthread!=nil)
    {
        [[AppDelegate sharedDelegate].barstyleloaderthread setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.idleTimer invalidate];
    self.idleTimer = nil;
    
    [super viewWillDisappear: animated];
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear: animated];
//    [self.padTitleTextField endEditing:YES];
//    [self.padBodyTextView   endEditing:YES];
//}

//- (void)updateTemporaryTopicTitle {
//    self.temporaryTopicEntity.topic = self.padTitleTextField.text;
//    NSError *error = nil;
//    [self.temporaryTopicEntity.managedObjectContext save:&error];
//    [AppDelegate saveContext];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (NSString*) contentText
//{
//    return self.padBodyTextView.text;
//}

- (void)initProperties {
    self.selectedTopic = nil;
}

- (void)loadLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}

//- (void) loadLastContent
//{
//    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//    NSString* content = [defaults stringForKey: @"last_content"];
//    if (content.length > 0)
//    {
//        self.padBodyTextView.text = content;
//        [defaults removeObjectForKey: @"last_content"];
//    }
//}

- (void) backupCurrentEdit
{
    NSDictionary* currentDictionary = [self dataFromEditView];
    [ComposeThreadViewController backupWithData: currentDictionary];
}

- (NSDictionary*) dataFromEditView
{
    NSMutableDictionary *postDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    NSString *typeStr = @"knote";
    NSArray* titleAndContent = [self.padBodyTextView.text knotableTitleAndContent];
    NSString *body    = titleAndContent[1];
    NSString *cname   = @"knotes";
    //    NSString *title   = self.padTitleTextField.text;
    NSString *title   = titleAndContent[0];
    
    if (title.length == 0) {
        title = @"Untitled";
    }
    
    //    NSArray *auxArr = [body componentsSeparatedByString:@"<div>"];
    //
    //    NSString *auxTitle = [auxArr objectAtIndex:0];
    //    if (!auxTitle) {
    //        auxTitle = [auxArr objectAtIndex:1];
    //
    //        if (auxTitle.length > 0){
    //            auxTitle = [auxTitle stringByReplacingOccurrencesOfString:@"</div>" withString:@""];
    //        }
    //    }
    //
    //    auxTitle = [auxTitle stringByReplacingOccurrencesOfString:@"</u>" withString:@"</u> "];
    //    auxTitle = [self stringByStrippingHTML:auxTitle];
    
    //    if ([self.knoteTitleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0)
    //    {
    //        [postDic setObject:self.knoteTitleField.text forKey:@"title"];
    //    }
    //    else
    //    {
    //        [postDic setObject:@"" forKey:@"title"];
    //    }
    
    //    [postDic setObject:auxTitle forKey:@"title"];
    
    [postDic setObject: title forKey: @"title"];
    body = [MessageEntity wrapTextInHTML:body];
    
    [postDic setObject:body forKey:@"htmlBody"];
    [postDic setObject:body forKey:@"body"];
    
    NSDate * date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:kDateFormat1];
    [postDic setObject:[format stringFromDate:date] forKey:@"date"];
    NSTimeInterval timeStamp = [date timeIntervalSince1970] * 1000;
    [postDic setObject:[NSNumber numberWithLongLong:timeStamp]forKey:@"timestamp"];
    
    [postDic setObject:title forKey:@"message_subject"];
    [postDic setObject:cname forKey:@"cname"];
    [postDic setObject:typeStr forKey:@"type"];
    [postDic setObject:@"ready" forKey:@"status"];
    
    
    if ([DataManager sharedInstance].currentAccount){
        [postDic setObject:[DataManager sharedInstance].currentAccount.user.email forKey:@"from"];
        [postDic setObject:[DataManager sharedInstance].currentAccount.user.name forKey:@"name"];
    }
    
    if (self.selectedTopic.topic_id)
        postDic[@"topic_id"] = self.selectedTopic.topic_id;
    
    if ([DataManager sharedInstance].currentAccount.account_id) {
        postDic[@"account_id"] = [DataManager sharedInstance].currentAccount.account_id;
    }
    
    postDic[@"topic_type"] = @(0);
    
    NSString *itemId = [[AppDelegate sharedDelegate] mongo_id_generator];
    [postDic setObject:[NSString stringWithFormat:@"%@%@", kKnoteIdPrefix, itemId] forKey:@"_id"];
    
    postDic[@"order"] = @(-1);
    return postDic;
}

- (void)loadCalendarEventManager {
    [self performSelector:@selector(requestAccessToEvents) withObject:nil afterDelay:0.4];
}

- (void)loadPadTitle {
    NSString *padTitle = defaultTopicName;// @"Knotes from iOS";
    
//    if ([self getActualLocationAsString].length > 0 && [self getActualDateAsString].length > 0) {
//        padTitle = [NSString stringWithFormat:@"%@, %@",[self getActualLocationAsString], [self getActualDateAsString]];
//    } else if ([self getActualLocationAsString].length > 0) {
//        padTitle = [self getActualLocationAsString];
//    } else if ([self getActualDateAsString].length > 0) {
//        padTitle = [self getActualDateAsString];
//    } else {
//        padTitle = @"";
//    }
//    
//    BOOL haveAccessToCalendar = [[AppDelegate sharedDelegate].calendarEventManager eventsAccessGranted];
//    if (haveAccessToCalendar) {
//        NSString * nextEvenTitle = [[AppDelegate sharedDelegate].calendarEventManager getNextEventTitle];
//        if (nextEvenTitle.length > 0) {
//            padTitle = nextEvenTitle;
//        }
//    }
    
//    self.padTitleTextField.text = padTitle;
    self.padTitle = padTitle;
}

- (void)createTemporaryTopic {
    self.temporaryTopicEntity = [[TopicManager sharedInstance] generateNewTopicEntityWithTitle:self./*padTitleTextField.text*/ self.padTitle account:[DataManager sharedInstance].currentAccount sharedContacts:@[]];
    self.selectedTopic = self.temporaryTopicEntity;
//    [[NSUserDefaults standardUserDefaults] setObject:self.temporaryTopicEntity.topic_id forKey:@"Knotable_TemporaryTopicId_To_Delete"];
}

- (NSString *)getActualDateAsString {
    NSDate *date = [NSDate date];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    NSDateComponents *componentsDate = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    NSString *minuteS = [NSString stringWithFormat:@"%ld", (long)[components minute]];
    if (minuteS.length <= 1) { minuteS = [@"0" stringByAppendingString:minuteS]; }
    
    NSString * amORpm = @"am";
    NSInteger hour = [components hour];
    if ([components hour] >= 13) {
        amORpm = @"pm";
        if (hour > 12) {
            hour -= 12;
        }
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM"];
    NSString *monthStringFromDate = [formatter stringFromDate:date];
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE"];
    
    NSInteger dayNumber = [componentsDate day];
    NSString *dayNumberString = [NSString stringWithFormat:@"%ld", (long)dayNumber];
    
    return [NSString stringWithFormat:@"%@ %@, %@ %@", monthStringFromDate, dayNumberString, [NSString stringWithFormat:@"%ld:%@", (long)hour, minuteS], amORpm];
}

- (NSString *)getActualLocationAsString {
    NSString *sublocality = [self.fullAddress objectForKey:@"SubLocality"] ? [self.fullAddress objectForKey:@"SubLocality"] : @"";
    NSString *subadministrativeOrCity = [self.fullAddress objectForKey:@"SubAdministrativeArea"] ?
    [self.fullAddress objectForKey:@"SubAdministrativeArea"] : ([self.fullAddress objectForKey:@"City"]) ? [self.fullAddress objectForKey:@"City"] : @"";
    
    NSString *address = (sublocality.length > 0) ? address = [NSString stringWithFormat:@"%@, ", sublocality] : ( (subadministrativeOrCity.length > 0)  ? address = [NSString stringWithFormat:@"%@, ", subadministrativeOrCity] : @"");
    
    return address;
}

- (id)createNewPad {
    NSLog(@"New pad created");
    return @"new pad";
}

- (NSString *)stringByStrippingHTML:(NSString*)htmlString {
    NSRange r;
    NSString *s = [htmlString copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

- (void)addNoteToSelectedPad {
    NSDictionary *postDic = [self dataFromEditView];

    MessageEntity *message = [[ThreadItemManager sharedInstance] insertOrUpdateMessageObject:postDic withTopicId:self.selectedTopic.topic_id withFlag:nil];

    [[PostingManager sharedInstance] postKnote:message];

    [self navigateBack];
}
//
- (void)deleteTemporaryTopic {
    // Mark events with same title as discarded to make sure we don't suggest the same title again to the user
    [[AppDelegate sharedDelegate].calendarEventManager markEventDiscardedByTitle: /*self.padTitleTextField.text*/ self.padTitle];
    
    [self.temporaryTopicEntity MR_deleteEntity];
    [AppDelegate saveContext];
    self.temporaryTopicEntity = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Knotable_TemporaryTopicId_To_Delete"];
}
//
//- (void)updateTopic {
//    if (self.temporaryTopicEntity) {
//        if (self.temporaryTopicEntity.topic_id) {
//            [self updateTemporaryTopicTitle];
//        } else {
//            [self createTemporaryTopic];
//        }
//        self.selectedTopic = self.temporaryTopicEntity;
//    }
//}

- (void)threadWithTopicIdSelected:(TopicsEntity *)topic {
    self.selectedTopic = topic;
    
    if (self.selectedTopic != self.temporaryTopicEntity) {
        [self deleteTemporaryTopic];
    }
    
//    self.padTitleTextField.text = self.selectedTopic.topic;
    self.padTitle = self.selectedTopic.topic;
}

- (void)postNote {
    NSString *text = [self.padBodyTextView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        UIAlertController * alert = [UIAlertController
                                      alertControllerWithTitle:@"Empty Note"
                                      message:@"Please enter some text to post."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Knotable_TemporaryTopicId_To_Delete"];
//    [self updateTopic];
    [self createTemporaryTopic];
    if (self.temporaryTopicEntity) {
        self.selectedTopic = self.temporaryTopicEntity;
        self.selectedTopic.needSend = @(YES);
        NSError *error = nil;
        [self.temporaryTopicEntity.managedObjectContext save:&error];
        [AppDelegate saveContext];
    }

    [self addNoteToSelectedPad];
}

//- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    self.selectedTopic = nil;
//    if (!self.temporaryTopicEntity) {
//        [self createTemporaryTopic];
//    }
//    
//    //IAZ:
//    if (textField == self.padTitleTextField) {
//        [textField selectAll:textField];
//    }
//}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField{
//    
//    [self.padBodyTextView becomeFirstResponder];
//    
//    return YES;
//}
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{    
//        NSString *titleData = [textField.text stringByAppendingString:string];
//        
//        if (titleData.length > 150)
//        {
//            NSRange allowedChars = NSMakeRange(0, 150);
//            
//            NSString *allowedTitleText = [titleData substringWithRange:allowedChars];
//            
//            textField.text = allowedTitleText;
//            
//            NSRange remainChars = NSMakeRange(150, [titleData length] - 150);
//            
//            NSString *remainTitleText = [titleData substringWithRange:remainChars];
//            
//            self.padBodyTextView.text = [self.padBodyTextView.text stringByAppendingString:remainTitleText];
//            
//            [self.padBodyTextView becomeFirstResponder];
//            
//            return NO;
//        }
//    
//    return YES;
//}


-(void)notifyKeyboardActions {
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
}


-(void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary* userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.verConsPadBodyTextView.constant += keyboardSize.height;
}

-(void)keyboardWillHide:(NSNotification*)notification {
    NSDictionary* userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.verConsPadBodyTextView.constant -= keyboardSize.height;
}

#pragma mark LocationManager

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", [error description]);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = (CLLocation *)[locations lastObject];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocationCoordinate2D coordinate = [self.currentLocation coordinate];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error){
        
        if((!error) && (placemarks.count > 0)){
            
            CLPlacemark * placemark = [placemarks objectAtIndex:0];
            self.fullAddress = placemark.addressDictionary;
        }
    }];
}

#pragma mark CalendarEventsManager

- (void)requestAccessToEvents {
    [[AppDelegate sharedDelegate].calendarEventManager.eventStore requestAccessToEntityType:EKEntityTypeEvent
        completion:^(BOOL granted, NSError *error) {
             if (!error) {
                 [AppDelegate sharedDelegate].calendarEventManager.eventsAccessGranted = granted;
             } else {
                 NSLog(@"%@", [error localizedDescription]);
             }
         }
    ];
}

//- (void)navigateToThreadSelectionViewController {
//    [self updateTopic];
//    
//    ThreadSelectionViewController *threadSelectionViewController = [[ThreadSelectionViewController alloc] init];
//    threadSelectionViewController.delegate      = self;
//    threadSelectionViewController.selectedTopic = self.selectedTopic;
//    threadSelectionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self presentViewController:threadSelectionViewController animated:YES completion:nil];
//}

- (void)navigateBack {
    //[self.navigationController popViewControllerAnimated:YES];
    for(UIViewController * vc in self.navigationController.viewControllers){
        if([vc isKindOfClass:[ThreadViewController class]]){
            ThreadViewController * threadVC = (ThreadViewController *)vc;
            if(self.temporaryTopicEntity){
                TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:self.selectedTopic];
                threadVC.tInfo = tInfo;
                threadVC.shouldReloadKnotes = YES;
                [self.navigationController popViewControllerAnimated:YES];
            }/*else{
                threadVC.shouldPopToMainView = YES;
                [self deleteTemporaryTopic];
                for(int i=0;i<self.navigationController.viewControllers.count;i++)
                {
                    UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:i];
                    if([vc isKindOfClass:[CombinedViewController class]]){
                        NSMutableArray *arrOfNav=[self.navigationController.viewControllers mutableCopy];
                        TopicInfo* topic  = [[TopicInfo alloc] initWithTopicEntity:self.selectedTopic];
                        TopicsEntity *entity = topic.entity;
                        
                        if( entity.hasNewActivity.boolValue )
                        {
                            [entity markViewed];
                        }
                        topic.cell.processRetainCount = 1;
                        ThreadViewController* threadController = [[ThreadViewController alloc] initWithTopic:topic];
                        threadController.delegate = vc;
                        
                        CATransition *transition = [CATransition animation];
                        transition.duration = 5.8;
                        transition.timingFunction = [CAMediaTimingFunction
                                                     functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                        transition.type = kCATransitionPush;
                        transition.subtype = kCATransitionFromRight;
                        transition.fillMode = kCAFillModeForwards;
                        transition.delegate = self;
                        [self.view.layer addAnimation:transition forKey:@"kCombineAnimation"];
                        [arrOfNav insertObject:threadController atIndex:i+1];
                        self.navigationController.viewControllers=arrOfNav;
                        [self.navigationController popToViewController:threadController animated:YES];
                    }
                }
            }*/
        }
    }
}
- (void)navigateClose {
    //[self.navigationController popViewControllerAnimated:YES];
    for(UIViewController * vc in self.navigationController.viewControllers){
        if([vc isKindOfClass:[ThreadViewController class]]){
            ThreadViewController * threadVC = (ThreadViewController *)vc;
            if(self.temporaryTopicEntity){
                TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:self.selectedTopic];
                threadVC.tInfo = tInfo;
                threadVC.shouldReloadKnotes = YES;
                [self.navigationController popViewControllerAnimated:YES];
            }else{
//                threadVC.shouldPopToMainView = YES;
//                [self deleteTemporaryTopic];
//                for(UIViewController * vc in self.navigationController.viewControllers){
//                    if([vc isKindOfClass:[CombinedViewController class]]){
//                        [self.navigationController popToViewController:vc animated:YES];
//                    }
//                }
            }
        }
    }
}

#pragma mark IBActions

- (IBAction)postButtonTouchUpInside:(id)sender {
    [self postNote];
}

//- (IBAction)closeButtonTouchUpInside:(id)sender {
//    [self deleteTemporaryTopic];
//    [self navigateClose];
//}
//
//- (IBAction)showPadsButtonTouchUpInside:(id)sender {
//    [self navigateToThreadSelectionViewController];
//}



//IAZ:
//-(void)addSwipeGestureRecognizer {
//    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//    [[self view] addGestureRecognizer:recognizer];
//}
//
//-(void)handleSwipeFrom:(UISwipeGestureRecognizer*)recognizer {
//    [self deleteTemporaryTopic];
//    for(UIViewController * vc in self.navigationController.viewControllers){
//        if([vc isKindOfClass:[CombinedViewController class]]){
//            [self.navigationController popToViewController:vc animated:YES];
//        }
//    }
//}

@end
