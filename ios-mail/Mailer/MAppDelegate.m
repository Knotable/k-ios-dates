//
//  MAppDelegate.m
//  Mailer
//
//  Created by Martin Ceperley on 9/20/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MAppDelegate.h"
#import "MMessageListController.h"
#import "FXKeychain.h"
#import "MWelcomeViewController.h"
#import "MDataManager.h"
#import "MMailManager.h"
#import "MFileManager.h"
#import "MDesignManager.h"
#import "Account.h"
#import "Message.h"
#import "Folder.h"
#import "Attachment.h"
#import "Address.h"
#import "TestFlight.h"
#import "MControllerManager.h"
#import "DebugDraggableView.h"
#import "MHomeViewController.h"
#import "MMessageListController.h"
#import "Debug.h"
const BOOL CLEAR_IMAGES_ON_LAUNCH = NO;
const BOOL CLEAR_DB_ON_LAUNCH = NO;

@implementation MAppDelegate
@synthesize parentViewCntrllr,isChangeLogin,ispulled,addressArray;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (CLEAR_DB_ON_LAUNCH) {
        NSURL *storeURL = [NSPersistentStore urlForStoreName:[MagicalRecord defaultStoreName]];
        NSError *error;
        if(![[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error]){
            //NSLog(@"Error removing db on launch: %@", error);
        } else {
            //NSLog(@"Deleted db on launch");
        }
    }
    
    [[MDataManager sharedManager] setupStack];
#if 1
    NSPersistentStoreCoordinator *psc = [NSPersistentStoreCoordinator MR_defaultStoreCoordinator];
    NSError *error = nil;
    
    NSMutableDictionary *sqliteOptions = [NSMutableDictionary dictionary];
    [sqliteOptions setObject:@"DELETE" forKey:@"journal_mode"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             sqliteOptions, NSSQLitePragmasOption,
                             nil];
    NSString *storeFileName = [MagicalRecord defaultStoreName];
    NSURL *url = [NSPersistentStore MR_urlForStoreName:storeFileName];
    [psc removePersistentStore:[NSPersistentStore defaultPersistentStore] error:&error];
    
    NSPersistentStore *persistentStore = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error];
    if (! persistentStore) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [NSPersistentStore setDefaultPersistentStore:persistentStore];
#endif
    addressArray = [NSMutableArray arrayWithArray:nil];
    
    //[MagicalRecord setupCoreDataStack];
    //[MagicalRecord setShouldAutoCreateDefaultPersistentStoreCoordinator:YES];
    //[MagicalRecord setShouldDeleteStoreOnModelMismatch:YES];
    
    //DB Analytics
    //NSLog(@"Account count: %lu", (unsigned long)[Account countOfEntities]);
    //NSLog(@"Folder count: %lu", (unsigned long)[Folder countOfEntities]);
    //NSLog(@"Message count: %lu", (unsigned long)[Message countOfEntities]);
    //NSLog(@"Attachment count: %lu", (unsigned long)[Attachment countOfEntities]);
    //NSLog(@"Address count: %lu", (unsigned long)[Address countOfEntities]);

    
//    [TestFlight takeOff:@"f5a208b4-f00a-4a43-b795-75e3325ce489"];
//    [TestFlight takeOff:@"c309aef1-c20e-4176-9ce9-99fbf533dc5d"];
    
     [TestFlight takeOff:@"66878db9-2b65-4e3f-9bd5-f88807bbe8f5"];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    navigationController.view.tintColor = [MDesignManager tintColor];

    navigationController.navigationBar.barTintColor = [MDesignManager tintColor];
    navigationController.navigationBar.tintColor = [MDesignManager highlightColor];
    
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[MDesignManager highlightColor]};

    navigationController.toolbar.barTintColor = [MDesignManager barTintColor];
    navigationController.toolbar.tintColor = [MDesignManager highlightColor];

    //Modified by 3E ------START------
    
    [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"topbar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[MDesignManager highlightColor]}];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[MDesignManager highlightColor]} forState: UIControlStateNormal];
    
    //[[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"bottom.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    self.window.backgroundColor=[UIColor whiteColor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL checkLogin = [defaults boolForKey:@"IsLogin"] ;
    
    if (checkLogin) {
        
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
       
    Account* account = [Account selectedUser:[defaults valueForKey: @"Username"]];
        if(account){
            
//            [MMailManager sharedManager].currentAccount = account;
//            [[MMailManager sharedManager] beginFetchingMail];
            
            MWelcomeViewController *welcomeController = (MWelcomeViewController *)navigationController.topViewController;
            //[welcomeController performSegueWithIdentifier:@"haveAccount" sender:self];
#if 1
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MHomeViewController *homeVc = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
            [welcomeController.navigationController pushViewController:homeVc animated:NO];
            MMessageListController *listVc = [[MControllerManager sharedManager] setupAllInbox];
            [homeVc.navigationController pushViewController:(UIViewController *)listVc animated:YES];
#else
            [welcomeController performSegueWithIdentifier:@"showHome" sender:self];
#endif
            //        [[MControllerManager sharedManager] showFirstControllerFrom:welcomeController];
        }

    }

    //Modified by 3E ------END------
    
    if (CLEAR_IMAGES_ON_LAUNCH) {
        [MFileManager clearSnapshotsDir];
    }
    
//    [application setMinimumBackgroundFetchInterval:1.0];
//    [application setMinimumBackgroundFetchInterval:60.0 ];
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [self plistCreation];
    
    [self performSelectorInBackground:@selector(getAddress) withObject:nil];
    
    addressTimer = [NSTimer scheduledTimerWithTimeInterval:600
                                                      target:self
                                                    selector:@selector(getAddress)
                                                    userInfo:nil
                                                     repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:addressTimer forMode:NSRunLoopCommonModes];
    [[MMailManager sharedManager] reloadAllAccount];
//remove first come in to fetch emails
    [[MMailManager sharedManager] beginFetchingAllMail];

#ifdef DEBUG
    [self loadAvatarInKeyWindow];
#endif
    BIDERROR("App did finish launching");
    return YES;
}

-(void)plistCreation{
    
    // First - test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"KnotePlist.plist"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"KnotePlist.plist"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    
    if (!success) {
        NSAssert1(0, @"Failed to create writable plist file with message '%@'.", [error localizedDescription]);
    }
    else{
        NSLog(@"Plist successfully created");
    }
    
//    NSFileManager *fmngr = [[NSFileManager alloc] init];
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"KnotePlist.plist" ofType:nil];
//    
//    
//    NSError *error;
//    if(![fmngr copyItemAtPath:filePath toPath:[NSString stringWithFormat:@"%@/Documents/KnotePlist.plist", NSHomeDirectory()] error:&error]) {
//        // handle the error
//        NSLog(@"Error creating the KnotePlist: %@", [error description]);
//        
//    }

}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    LOG_METHOD;
    
    NSLog(@"performFetchWithCompletionHandler>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    BIDERROR("performFetchWithCompletionHandler");


    NSDate *startTime = [NSDate date];
    
    NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
    
    if (fetchComplete != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:fetchComplete];
        fetchComplete = nil;
    }
    if (fetchError != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:fetchError];
        fetchError = nil;
    }

    fetchComplete = [noteCenter addObserverForName:FETCHED_NEW_MAIL_HEADERS_NOTIFICATION object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        
        if (fetchComplete != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:fetchComplete];
            fetchComplete = nil;
        }
        if (fetchError != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:fetchError];
            fetchError = nil;
        }


        NSUInteger fetchedCount = ((NSNumber *)note.object).unsignedIntegerValue;

        NSLog(@"Background fetch of new mail complete in %f messages: %lu", -[startTime timeIntervalSinceNow], (unsigned long)fetchedCount);
        
        completionHandler(fetchedCount > 0 ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultNoData);
    }];
    
    fetchError = [noteCenter addObserverForName:ERROR_FETCHING_NEW_MAIL_NOTIFICATION  object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if (fetchComplete != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:fetchComplete];
            fetchComplete = nil;
        }
        if (fetchError != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:fetchError];
            fetchError = nil;
        }
        
        NSLog(@"Background fetch of new mail error in %f", -[startTime timeIntervalSinceNow]);

        
        completionHandler(UIBackgroundFetchResultFailed);
    }];

    [[MMailManager sharedManager] reloadAllAccount];
    [[MMailManager sharedManager] beginFetchingAllMail];
}

- (void)loadAvatarInKeyWindow {
    DebugDraggableView *avatar = [[DebugDraggableView alloc] initInKeyWindowWithFrame:CGRectMake(0, 100, 98, 36)];
    [avatar setBackgroundImage:[UIImage imageNamed:@"768x64"] forState:UIControlStateNormal];
#if 0
    [avatar setLongPressBlock:^(DebugDraggableView *avatar) {
        NSLog(@"\n\tAvatar in keyWindow ===  LongPress!!! ===");
        //More todo here.
        
    }];
    
    [avatar setTapBlock:^(DebugDraggableView *avatar) {
        NSLog(@"\n\tAvatar in keyWindow ===  Tap!!! ===");
        //More todo here.
        
    }];
    
    [avatar setDoubleTapBlock:^(DebugDraggableView *avatar) {
        NSLog(@"\n\tAvatar in keyWindow ===  DoubleTap!!! ===");
        //More todo here.
        
    }];
    
    [avatar setDraggingBlock:^(DebugDraggableView *avatar) {
        NSLog(@"\n\tAvatar in keyWindow === Dragging!!! ===");
        //More todo here.
        
    }];
    
    [avatar setDragDoneBlock:^(DebugDraggableView *avatar) {
        NSLog(@"\n\tAvatar in keyWindow === DragDone!!! ===");
        //More todo here.
        
    }];
    
    [avatar setAutoDockingBlock:^(DebugDraggableView *avatar) {
        NSLog(@"\n\tAvatar in keyWindow === AutoDocking!!! ===");
        //More todo here.
        
    }];
    
    [avatar setAutoDockingDoneBlock:^(DebugDraggableView *avatar) {
        NSLog(@"\n\tAvatar in keyWindow === AutoDockingDone!!! ===");
        //More todo here.
        
    }];
#endif
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    
//      NSLog(@"applicationWillResignActive");
    
    [locationManager stopUpdatingLocation];
    
    [locTimer invalidate];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    BIDERROR("applicationDidEnterBackground");

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    
    [[MMailManager sharedManager] stopFetchingMail];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
//    Account *account = [Account selectedUser:[defaults valueForKey: @"LastSelectedAccount"]];
    [MMailManager sharedManager].currentAccoutIndex = [[defaults valueForKey:@"selectedIndex"] integerValue];

    
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    request.resultType = NSCountResultType;
    request.predicate = [NSPredicate predicateWithFormat:@" account = %@ ",[[MMailManager sharedManager] getCurrentAccount]];
    
    NSError *error;
    //NSArray *array = [[MDataManager sharedManager].managedObjectContext executeFetchRequest:request error:&error];
    //NSNumber *count = [array firstObject];
    NSUInteger count = [[MDataManager sharedManager].managedObjectContext countForFetchRequest:request error:&error];
    
//    NSLog(@"count = %d",count);
    
    
    UIApplication*    app = [UIApplication sharedApplication];
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
     timer = [NSTimer scheduledTimerWithTimeInterval:600.0
                                     target:self
                                   selector:@selector(timerDidFire:)
                                   userInfo:[NSString stringWithFormat:@"%lu",(unsigned long)count]
                                    repeats:YES];
    
    
    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
        [self backgroundHandler];
    }];
    if (backgroundAccepted) {
        NSLog(@"backgrounding accepted");
    }
    [self backgroundHandler];
}

- (void) timerDidFire:(NSTimer *)timerLoc
{
   
//    NSLog(@"Timer did fire");//
    
//    NSLog(@"timer userInfo = %@",timerLoc.userInfo);//
    
    NSUInteger oldCount = [timerLoc.userInfo integerValue];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

//    Account *accnt = [Account selectedUser:[defaults valueForKey: @"LastSelectedAccount"]];
    NSInteger currentIndex = [[defaults valueForKey:@"selectedIndex"] integerValue];
    if (currentIndex>=[[MMailManager sharedManager].allAccount count]) {
        currentIndex=0;
    }
    [MMailManager sharedManager].currentAccoutIndex = currentIndex;
    
    [[MMailManager sharedManager] beginFetchingMail];
    
    
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    request.resultType = NSCountResultType;
    request.predicate = [NSPredicate predicateWithFormat:@" account = %@ ",[[MMailManager sharedManager] getCurrentAccount]];
    
    NSError *error;
    //NSArray *array = [[MDataManager sharedManager].managedObjectContext executeFetchRequest:request error:&error];
    //NSNumber *count = [array firstObject];
    NSUInteger newCount = [[MDataManager sharedManager].managedObjectContext countForFetchRequest:request error:&error];
    
//    NSLog(@"newCount    =    %d",newCount);
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = newCount-oldCount;

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [timer invalidate];
//    [[MMailManager sharedManager] beginFetchingMail];
    [[MMailManager sharedManager] beginFetchingAllMail];
   
}


//Loading email addresses
-(void)getAddress{
    
    //    self.activityIndicator.hidden = NO;
    //    [self.activityIndicator startAnimating];
    
//    NSLog(@" ************ getAddress **************");
    
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                
                [self allContacts:addressBookRef];
                
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mailable" message:@"Please enable permission to access contact details from device in settings page" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                [alert show];
                
                //                NSLog(@"Not granted");
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        
        [self allContacts:addressBookRef];
        
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        //        NSLog(@"Not granted");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mailable" message:@"Please enable permission to access contact details from device in settings page" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    }
    
    //    NSLog(@"emailArray = %@",emailArray);
    
    //    [self performSelector:@selector(stopSpinner) withObject:Nil afterDelay:.1];
    
    
}

-(void)allContacts :(ABAddressBookRef)addressBookRef{
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBookRef,
                                             ^(bool granted, CFErrorRef error){
                                                 dispatch_semaphore_signal(sema);
                                             });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    [addressArray removeAllObjects];
    
    CFArrayRef people  = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    
    for(int i = 0;i<ABAddressBookGetPersonCount(addressBookRef);i++)
    {
        
        ABRecordRef ref = CFArrayGetValueAtIndex(people, i);
        
        ABMultiValueRef emails = ABRecordCopyValue(ref, kABPersonEmailProperty);
        
        NSArray *arrayEmail  =  (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emails);
        
        if (arrayEmail && [arrayEmail count]) {
            if([arrayEmail isKindOfClass:[NSArray class]]) {
                [addressArray addObjectsFromArray:arrayEmail];
            } else {
                NSLog(@"####ERROR!!!! arrayEmail is Not array:%@",arrayEmail);
            }
        }
        
    }
    
    NSArray *copy = [addressArray copy];
    NSInteger index = [copy count] - 1;
    for (id object in [copy reverseObjectEnumerator]) {
        if ([addressArray indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) {
            [addressArray removeObjectAtIndex:index];
        }
        index--;
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
//    NSLog(@"applicationDidBecomeActive");
    
    
    
//    dispatch_async(dispatch_queue_create("myqueue", 0), ^{
    
//        NSLog(@"************** Assign  dispatch_async ***************");
        
//        [self fetchingLocation];
    
    locTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                    target:self
                                                  selector:@selector(fetchingLocation)
                                                  userInfo:nil
                                                   repeats:YES];
    
    
    
    [[NSRunLoop currentRunLoop] addTimer:locTimer forMode:NSRunLoopCommonModes];
    
    //keep the runloop going as long as needed
//    while (!_done && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//                                              beforeDate:[NSDate distantFuture]]);
    
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//
//        });
//        
//        
//    });
//    
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//                                             (unsigned long)NULL), ^(void) {
//        
//    locationManager = [[CLLocationManager alloc] init];
//    locationManager.delegate = self;
//    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    geocoder = [[CLGeocoder alloc] init];
//        
//    [self fetchingLocation];
//
//
//    locTimer = [NSTimer scheduledTimerWithTimeInterval:60
//                                                 target:self
//                                               selector:@selector(fetchingLocation)
//                                               userInfo:nil
//                                                repeats:YES];
//    });
    
    
//    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
//    
//    dispatch_async(backgroundQueue, ^{
//
//        //        int result = <some really long calculation that takes seconds to complete>;
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            
////            [self updateMyUIWithResult:result];
//        });
//    });

}

-(void)fetchingLocation{
    
//    NSLog(@" fetchingLocation ");
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    geocoder = [[CLGeocoder alloc] init];
    
    [locationManager startUpdatingLocation];
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
//        NSLog(@"didFailWithError: %@", error);
//        UIAlertView *errorAlert = [[UIAlertView alloc]
//                                   initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [errorAlert show];
    
//    NSLog(@"_locationStr = %@",_locationStr);
    
    if ([_locationStr length]) {
        
        NSString *lastPlace = _locationStr;
        lastPlace = [lastPlace stringByReplacingOccurrencesOfString:@"around " withString:@""];
        
        _locationStr = [NSString stringWithFormat:@"around %@",lastPlace];
    }
    
  
    
}

//- (void)locationManager:(CLLocationManager *)manager
//monitoringDidFailForRegion:(CLRegion *)region
//              withError:(NSError *)error{
//    
//     NSLog(@"monitoringDidFailForRegion ");
//}
//- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manage{
//     NSLog(@"locationManagerDidPauseLocationUpdates ");
//}
//- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager{
//     NSLog(@"locationManagerDidResumeLocationUpdates ");
//}
//- (void)locationManager:(CLLocationManager *)manager
//didFinishDeferredUpdatesWithError:(NSError *)error{
//     NSLog(@"didFinishDeferredUpdatesWithError ");
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
//    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    //    if (currentLocation != nil) {
    
    //        NSString *longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
    //        NSString *latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    //
    ////        NSLog(@"longitude = %@",longitude);
    ////        NSLog(@"latitude = %@",latitude);
    ////
    ////
    //
    //    }
    //
    // Reverse Geocoding
    //    NSLog(@"Resolving the Address");
    
   
    
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        //        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        
        if (error == nil && [placemarks count] > 0) {
            
            NSString *location = @"";
            
            placemark = [placemarks lastObject];
            
//            NSString *addressStr = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
//                                 placemark.subThoroughfare, placemark.thoroughfare,
//                                 placemark.postalCode,
//                                 placemark.locality,
//                                 placemark.administrativeArea,
//                                 placemark.country];
//
//
//            NSLog(@"addressStr====%@",addressStr);
            
            if (([placemark.locality length])) {
                
                location = placemark.locality;
                
                if (([placemark.administrativeArea length])) {
                    
                    location = [location stringByAppendingString:[NSString stringWithFormat:@", %@",placemark.administrativeArea]];
                    
                }
                else{
                    if ([placemark.country length]){
                        
                         location = [location stringByAppendingString:[NSString stringWithFormat:@", %@",placemark.country]];
                        
                    }
                }
            }
            
            else{
                if (([placemark.administrativeArea length])) {
                    
                    location = placemark.administrativeArea;
                    
                    if ([placemark.country length]){
                        
                        location = [location stringByAppendingString:[NSString stringWithFormat:@", %@",placemark.country]];
                        
                    }
                    
                }
                else{
                    if ([placemark.country length]){
                        
                        location = placemark.country;
                        
                    }
                }
            }
            
            if ([location length]) {
                _locationStr = location;
            }
            
            
            
            
            
//            if ([placemark.locality length]) {
//                
//                location = placemark.locality;
//                
//                _locationStr = placemark.locality;
//            }
//            else if ([placemark.administrativeArea length]) {
//                
//                
//                
//                _locationStr = placemark.administrativeArea;
//            }
//            else if ([placemark.country length]){
//                _locationStr = placemark.country;
//            }
//            else{
//                _locationStr = @"";
//            }
            
        } else {
            
//                        NSLog(@"error====%@", error.debugDescription);
            
//            NSLog(@"_locationStr = %@",_locationStr);
            if ([_locationStr length]) {
                
                NSString *lastPlace = _locationStr;
                lastPlace = [lastPlace stringByReplacingOccurrencesOfString:@"around " withString:@""];
                
                _locationStr = [NSString stringWithFormat:@"around %@",lastPlace];
            }

            
        }
    }];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[MDataManager sharedManager] saveContextAndWait];
    [MagicalRecord cleanUp];
    
    if (fetchComplete != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:fetchComplete];
        fetchComplete = nil;
    }
    if (fetchError != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:fetchError];
        fetchError = nil;
    }

}

- (void)backgroundHandler {
    NSLog(@"### -->backgroundinghandler");
    UIApplication*    app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    // Start the long-running task
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSInteger counter = 0;
//        while (1) {
//            NSLog(@"counter:%ld", (long)counter++);
//            sleep(1);
//        }
//    });
}

@end
