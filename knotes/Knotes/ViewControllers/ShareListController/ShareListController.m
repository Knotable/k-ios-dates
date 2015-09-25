//
//  ShareListController.m
//  Knotable
//
//  Created by Martin Ceperley on 3/17/14.
//
//

#import "ShareListController.h"
#import "MyProfileController.h"
#import "MZFormSheetController.h"

#import "ContactsEntity.h"
#import "TopicsEntity.h"
#import "UserEntity.h"

#import "DataManager.h"
#import "DesignManager.h"
#import "ContactManager.h"
#import "PostingManager.h"
#import "AnalyticsManager.h"

#import "Constant.h"
#import "AppDelegate.h"

#import "CUtil.h"
#import "KnoteNSCMV.h"
#import "ObjCMongoDB.h"
#import "OMPromises/OMPromises.h"

#import "ContactCell.h"
#import "SwipeTableView.h"

#import "UIImage+Retina4.h"
#import "UIImage+FontAwesome.h"

@interface ShareListController (KnoteNSCMDelegate)<KnoteNSCMDelegate>
@end

// Lin - Ended

@interface ShareListController (ContactCellDelegate)<ContactCellDelegate,
MZFormSheetBackgroundWindowDelegate,
MyProfileDelegateProtocol>
@end

extern NSString * const KnotebleTopicChange;

@interface ShareListController ()
{
    BOOL isFromThreadView;
}
@property (nonatomic, assign) BOOL justAddedContact;
@property (nonatomic, assign) BOOL sortAlphabetical;

@property (nonatomic,strong)    UserEntity          *login_user;
@property (nonatomic,strong)    SwipeTableView      *tableView;
#if !New_DrawerDesign
@property (nonatomic, strong)   KnoteNSCMV          *navCustomMenu;
#else
@property (nonatomic, strong)   UIBarButtonItem          *srchButton;
@property (nonatomic, strong)   UIBarButtonItem          *linkButton;
@property (nonatomic, strong)   UIBarButtonItem          *addContactButton;
#endif

@property (nonatomic, strong)   NSArray         *allContacts;
@property (nonatomic, strong)   NSArray         *originalUsersOnPad;
@property (nonatomic, strong)   NSArray         *sharedContacts;
@property (nonatomic, strong)   NSMutableSet    *usersToAdd;
@property (nonatomic, strong)   NSMutableSet    *usersToRemove;
@property (nonatomic, strong)   NSMutableArray  *usersOnPad;
//@property (nonatomic, strong)   NSMutableArray  *usersOffPad;
@property (nonatomic, strong)   NSMutableArray  *sortedUsers;
@property (nonatomic, strong)   NSMutableArray  *searchResults;
@property (nonatomic, strong)   NSMutableArray  *newlyAddedEmails;

@property (nonatomic,strong)    UISearchBar                 *searchBar;
@property (nonatomic,weak)      UITableView                 *currentTableView;
@property (nonatomic,strong)    UISearchDisplayController   *searchController;
#if New_DrawerDesign
@property (nonatomic) CGRect searchTableViewRect;
#endif
@end

@implementation ShareListController

- (id)initWithTopic:(TopicsEntity *)topic loginUser:(UserEntity *)loginUser sharedContacts:(NSArray *)sharedContacts
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {

        NSLog(@"sharedContacts: %@", sharedContacts);
#if New_DrawerDesign
#else
        self.title = @"Share Pad";
#endif
        self.topic = topic;
        
        self.sharedContacts = sharedContacts;
        
        self.login_user = loginUser;
        
        self.newlyAddedEmails = [[NSMutableArray alloc] init];
        
        self.justAddedContact = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fetchedContacts)
                                                     name:CONTACTS_DOWNLOADED_NOTIFICATION
                                                   object:nil];

        
        [self updateContacts];
        
    }
    return self;
}
- (id)initWithTopic:(TopicsEntity *)topic loginUser:(UserEntity *)loginUser sharedContacts:(NSArray *)sharedContacts isForCombinedView:(BOOL)isForThread
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        NSLog(@"sharedContacts: %@", sharedContacts);
#if New_DrawerDesign
#else
        self.title = @"Share Pad";
#endif
        self.topic = topic;
        
        self.sharedContacts = sharedContacts;
        
        self.login_user = loginUser;
        
        self.newlyAddedEmails = [[NSMutableArray alloc] init];
        
        self.justAddedContact = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fetchedContacts)
                                                     name:CONTACTS_DOWNLOADED_NOTIFICATION
                                                   object:nil];
        isFromThreadView=isForThread;
        
        [self updateContacts];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*********Navigation Bar changes as per New Design************/
    NSDictionary *navBarTitleAttr =[NSDictionary dictionaryWithObjectsAndKeys:
                                    [DesignManager knoteTitleFont],NSFontAttributeName,
                                    [UIColor darkGrayColor], NSForegroundColorAttributeName, nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes: navBarTitleAttr];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
        /*for iOS 7 and newer*/
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:0.847 alpha:1.000]];
    }
    else
    {
        /*for older versions than iOS 7*/
        [self.navigationController.navigationBar setTintColor:[UIColor colorWithWhite:0.847 alpha:1.000]];
    }
    /*********************/
    // Lin - Added Custom Menu
#if !New_DrawerDesign
    if (self.navCustomMenu == Nil)
    {
        self.navCustomMenu = [[KnoteNSCMV alloc] init];
        
        self.navCustomMenu.targetDelegate = self;
        [self.navCustomMenu.m_btnSort removeFromSuperview];
        /*[self.navCustomMenu.m_btnSort.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [self.navCustomMenu.m_btnSort setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];*/
    }

#endif
    // Lin - Ended
    
    CGRect frame = self.view.bounds;
    self.tableView = [[SwipeTableView alloc] initWithFrame:frame];
    
    self.currentTableView = self.tableView;
    self.tableView.swipeDelegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.tableView.backgroundColor = [DesignManager appBackgroundColor];
    
    self.tableView.separatorColor = [UIColor colorWithWhite:0.77 alpha:1.0];
#if New_DrawerDesign
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
#else
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
#endif
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    
    if (IOS7_OR_LATER)
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];//
    }
    
#endif
    
    //Hide empty separators
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = v;
    
    UIView *rootView = [[UIView alloc] initWithFrame:CGRectZero];
    [rootView addSubview:self.tableView];
    rootView.backgroundColor = [DesignManager appBackgroundColor];
    self.view = rootView;

    self.tableView.translatesAutoresizingMaskIntoConstraints = YES;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0.0);
    }];

    // Search Bar
#if New_DrawerDesign
    //self.searchBar = [[UISearchBar alloc] init];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 250, 44.0)];
#else
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.0)];
#endif
    if ([self.searchBar respondsToSelector:@selector(setSearchBarStyle:)])
        //self.searchBar.searchBarStyle = UISearchBarStyleDefault;
        self.searchBar.searchBarStyle = UISearchBarStyleMinimal;

    //self.searchBar.showsCancelButton = YES;
    self.searchBar.tintColor = [UIColor blackColor];
    self.searchBar.delegate=self;
#if New_DrawerDesign
    self.searchBar.backgroundImage = [[UIImage alloc] init];
#endif
    /*[self.tableView setTableHeaderView:self.searchBar];*/
    self.searchBgView = [UIView new];
    
#if New_DrawerDesign
    [_searchBgView setFrame:CGRectMake(0, 0, 250, 50)];
    _searchBgView.backgroundColor=[UIColor whiteColor];
    [_searchBgView addSubview:_searchBar];

#else
    [_searchBgView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44)];
#endif
    
    
    //UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //[_searchBgView addSubview:button];
    //[button addTarget:self action:@selector(SharePadSortAction) forControlEvents:UIControlEventTouchUpInside];
    //[button setFrame:CGRectMake(_searchBgView.frame.size.width/2 -22/2, 10, 22, 22)];

#if New_DrawerDesign
#else
    [_searchBar setFrame:CGRectMake(40, 0, CGRectGetWidth(self.tableView.frame)-40, 44)];
#endif
    //self.recordBtn = button;
    //[self.recordBtn setImage:[UIImage imageNamed:@"alphabetical_sorting-48-gray"] forState:UIControlStateNormal];

    self.tableView.tableHeaderView = _searchBgView;
    [self.tableView setContentOffset:CGPointMake(0, self.searchBar.frame.size.height) animated:NO];


    // SearchController
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    //self.searchController.displaysSearchBarInNavigationBar = YES;

    // Navigation Buttons
    
    self.navigationItem.hidesBackButton = YES;
#if !New_DrawerDesign
    UIButton *rightButn =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    rightButn.frame = CGRectMake(0, 0, 50, 30);
    [rightButn setTitle:@"Done" forState:UIControlStateNormal];
    [rightButn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]/*[UIFont boldSystemFontOfSize:15]*/];
    [rightButn setTintColor:[UIColor whiteColor]];
    [rightButn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc ]initWithCustomView:rightButn];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navCustomMenu];
#else
    //tmd
    UIImage * rightBarButnImg1 = [UIImage imageWithIcon:@"fa-search" backgroundColor:[UIColor clearColor] iconColor:[UIColor darkGrayColor] andSize:CGSizeMake(22, 22)];
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setImage:rightBarButnImg1 forState:UIControlStateNormal];
    [button1 setFrame:CGRectMake(0, 0, rightBarButnImg1.size.width, rightBarButnImg1.size.height)];
    [button1 addTarget:self action:@selector(showSearch) forControlEvents:UIControlEventTouchUpInside];
    self.srchButton = [[UIBarButtonItem alloc] initWithCustomView:button1];
    
    
    UIImage * rightBarButnImg2 = [UIImage imageWithIcon:@"fa-link" backgroundColor:[UIColor clearColor] iconColor:[UIColor darkGrayColor] andSize:CGSizeMake(22, 22)];
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setImage:rightBarButnImg2 forState:UIControlStateNormal];
    [button2 setFrame:CGRectMake(0, 0, rightBarButnImg2.size.width, rightBarButnImg2.size.height)];
    [button2 addTarget:self action:@selector(copyLink) forControlEvents:UIControlEventTouchUpInside];
    self.linkButton = [[UIBarButtonItem alloc] initWithCustomView:button2];
    
    
    UIImage * rightBarButnImg3 = [UIImage imageWithIcon:@"fa-user-plus" backgroundColor:[UIColor clearColor] iconColor:[UIColor darkGrayColor] andSize:CGSizeMake(24, 22)];
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 setImage:rightBarButnImg3 forState:UIControlStateNormal];
    [button3 setFrame:CGRectMake(0, 0, rightBarButnImg3.size.width, rightBarButnImg3.size.height)];
    [button3 addTarget:self action:@selector(SharePadAddAction) forControlEvents:UIControlEventTouchUpInside];
    self.addContactButton = [[UIBarButtonItem alloc] initWithCustomView:button3];
    
    self.navigationItem.rightBarButtonItems = @[self.addContactButton, self.linkButton];

#endif
    
    FloatingTrayView *tray = [[FloatingTrayView alloc] initWithFrame:CGRectZero];
    
    tray.delegate = self;
    
    [self.view addSubview:tray];
    
    [tray showArchived:NO];
    
    [tray installConstraints];
    
    tray.hidden = YES;
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)updateContacts
{
    BOOL sortFlag = NO,archiveFlag = NO;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"archived == %@", @(archiveFlag)];
    
    NSString *sortFields = sortFlag ? @"name:YES" : @"position:NO,total_topics:YES";
    
    // [ContactsEntity MR_fetchAllSortedBy:sortFields ascending:YES withPredicate:predicate groupBy:nil delegate:self];
    self.allContacts = [ContactsEntity MR_findAllSortedBy:sortFields ascending:NO withPredicate:predicate];
    
    self.usersOnPad = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)(self.allContacts.count/2.0)];
//    self.usersOffPad = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)(self.allContacts.count/2.0)];
    
    if (!self.usersToAdd) {
        self.usersToAdd = [[NSMutableSet alloc] init];
    }
    
    if (!self.usersToRemove) {
        self.usersToRemove = [[NSMutableSet alloc] init];
    }
    
    //self.usersOffPad = [allContacts mutableCopy];
    
    NSSet *participatorsEmails;
    NSSet *sharedAccounts;
    
    if (!self.topic && self.login_user.email) {
        participatorsEmails = [NSSet setWithObject:self.login_user.email];
        sharedAccounts = [NSSet set];
    } else {
        if (self.topic.participators && [self.topic.participators isKindOfClass:[NSArray class]]) {
            if([self.topic.participators componentsSeparatedByString:@","].count > 0){
                participatorsEmails = [NSSet setWithArray:[self.topic.participators componentsSeparatedByString:@","]];
            }
        }
        if (self.topic.shared_account_ids && [self.topic.shared_account_ids isKindOfClass:[NSArray class]]) {
            if([self.topic.shared_account_ids componentsSeparatedByString:@","].count > 0){
                sharedAccounts = [NSSet setWithArray:[self.topic.shared_account_ids componentsSeparatedByString:@","]];
            }
        }
    }
    
    NSMutableArray *justAddedContacts = [[NSMutableArray alloc] init];
    
    for(ContactsEntity *contact in self.allContacts){
        
        NSLog(@"CONTACT: %@ EMAIL: %@ ID: %@ IS_ME : %@ ACCOUNT_ID: %@", contact.name, contact.email, contact.contact_id, contact.isMe, contact.account_id);
        /*BOOL isLoginUser = (contact.user && contact.user == self.login_user) || (contact.email && [contact.email isEqualToString:self.login_user.email]);*/
        
//        if(isLoginUser){
//            //Do not show yourself
//            continue;
//        }
        
        /*if (!contact.account_id) {
            NSLog(@"excluding contact because no account_id");
            //Do not show contacts without account_ids
            continue;
        }*/
        
        BOOL inParticipators = [participatorsEmails containsObject:contact.mainEmail];
        BOOL inSharedAccounts = contact.account_id && [sharedAccounts containsObject:contact.account_id];
        BOOL inSharedContacts = self.sharedContacts && [self.sharedContacts containsObject:contact];
        
        BOOL inAdded = [self.usersToAdd containsObject:contact];
        BOOL inRemoved = [self.usersToRemove containsObject:contact];

        BOOL just_added = self.justAddedContact && [self.newlyAddedEmails containsObject:contact.mainEmail];

        
        if(!inRemoved && (inParticipators || inSharedAccounts || inSharedContacts || inAdded)){
            [self.usersOnPad addObject:contact];
        } else {
//            [self.usersOffPad addObject:contact];
        }
        
        if (just_added) {
            [justAddedContacts addObject:contact];
        }
        
        
    }
    
    NSLog(@"usersOnPad: %@", self.usersOnPad);
    
    self.originalUsersOnPad = [self.usersOnPad copy];
    
    for (ContactsEntity *addedContact in justAddedContacts) {
        if (![self.usersOnPad containsObject:addedContact]) {
            [self.usersOnPad insertObject:addedContact atIndex:0];
//            [self.usersOffPad removeObject:addedContact];
            [self.usersToAdd addObject:addedContact];
        }
    }
    
    self.sortAlphabetical = NO;
    self.sortedUsers = [[self.allContacts sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]]] mutableCopy];
    
    self.searchResults = [[NSMutableArray alloc] initWithCapacity:self.allContacts.count];
    
}

- (void)done
{
    if ([self.delegate respondsToSelector:@selector(addContactPressedFromSharelist)])
    {
        [self.delegate addContactPressedFromSharelist];
    }
    //[self.navigationController popViewControllerAnimated:YES];
}
-(void)proceedToContact
{
    if (!_topic) {

        if (self.delegate && [self.delegate respondsToSelector:@selector(sharingWithContacts:)]) {
            
            NSMutableArray *sharingContacts = [self.usersOnPad mutableCopy];
            
            if (self.login_user
                && self.login_user.contact
                && ![sharingContacts containsObject:self.login_user.contact])
            {
                [sharingContacts insertObject:self.login_user.contact atIndex:0];
            }
            
            NSLog(@"sharingWithContacts: %@", sharingContacts);
            
            [self.delegate sharingWithContacts:[sharingContacts copy]];
        }
        
       // [self.navigationController popViewControllerAnimated:YES];
        
        return;
    }

    NSArray *emailsToAdd = [[self.usersToAdd allObjects] valueForKey:@"mainEmail"];
    NSArray *emailsToRemove = [[self.usersToRemove allObjects] valueForKey:@"mainEmail"];


    NSString *topicID = [self.topic.topic_id copy];

    OMPromise *addPromise = nil, *removePromise = nil;
    
    if(emailsToAdd.count > 0){
        NSLog(@"emails to add: %@", emailsToAdd);

        NSArray *addParams = @[self.topic.topic_id, emailsToAdd];

        addPromise = [[PostingManager sharedInstance] enqueueMeteorMethod:@"addContactsToTopic" parameters:addParams];
        
        [addPromise fulfilled:^(id result) {
            NSLog(@"addContactsToTopic success response: %@", result);

        }];
        
        [addPromise failed:^(NSError *error) {
            NSLog(@"addContactsToTopic error: %@", error);
            //[[NSNotificationCenter defaultCenter] postNotificationName:KnotebleShowPopUpMessage object:@"Network is failed, please try again." userInfo:nil];
        }];
        

    }
    
    if(emailsToRemove.count > 0)
    {
        for(NSString *email in emailsToRemove)
        {
            NSLog(@"email to remove: %@", email);
            
            NSArray *removeParams = @[topicID, email];

            removePromise = [[PostingManager sharedInstance] enqueueMeteorMethod:@"removeContactFromThread"
                                                                      parameters:removeParams];

            [removePromise fulfilled:^(id result) {
                
                NSLog(@"removeContactFromThread success main thread? %d response: %@", [[NSThread currentThread] isMainThread],result);
                
                NSNumber *didRemoveNum = result;
                
                BOOL didRemove = didRemoveNum.boolValue;
                
                if(didRemove)
                {
                    NSDictionary *parameters = @{ @"topicId": topicID, @"contactEmail": email };
                    
                    [[AnalyticsManager sharedInstance] notifyContactWasRemovedFromPadWithParameters:parameters];
                    
                    //Remove locally from core data
                    NSLog(@"did remove contact: %@", email);
                }
                else
                {
                    NSLog(@"did not remove contact: %@", email);
                }
                
            }];
            [removePromise failed:^(NSError *error) {
                NSLog(@"removeContactFromThread error: %@", error);

            }];
            
        }

    }
    
    OMPromise *allDonePromise;
    if (addPromise && removePromise) {
        allDonePromise = [OMPromise all:@[addPromise, removePromise]];
    } else {
        allDonePromise = addPromise ? addPromise : removePromise;
    }
    
    [allDonePromise fulfilled:^(id result)
    {
        
    }];
    
    NSLog(@"updating local contacts");
    
    if (_topic &&
        (self.usersToAdd.count > 0 || self.usersToRemove.count > 0))
    {
        NSMutableArray *shared_account_ids = [[_topic.shared_account_ids componentsSeparatedByString:@","] mutableCopy];
        
        for (ContactsEntity *userToAdd in self.usersToAdd)
        {
            if (userToAdd.account_id
                && userToAdd.account_id != (id)[NSNull null])
            {
                if (![shared_account_ids containsObject:userToAdd.account_id])
                {
                    NSLog(@"adding contact with account_id: %@", userToAdd.account_id);
                    
                    [shared_account_ids addObject:userToAdd.account_id];
                }
            }
        }
        
        for (ContactsEntity *userToRemove in self.usersToRemove)
        {
            if (userToRemove.account_id && userToRemove.account_id != (id)[NSNull null])
            {
                if ([shared_account_ids containsObject:userToRemove.account_id])
                {
                    NSLog(@"removing contact with account_id: %@", userToRemove.account_id);
                    [shared_account_ids removeObject:userToRemove.account_id];
                }
            }
        }
                
        NSString *new_account_ids = [shared_account_ids componentsJoinedByString:@","];
        
        NSLog(@"new account ids: %@", new_account_ids);
        
        _topic.shared_account_ids = new_account_ids;
        
        [AppDelegate saveContext];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateSharedTopicContacts)]) {
            [self.delegate updateSharedTopicContacts];
        }
    }
}

- (void)gotTopicResult:(id)obj userData:(id)data withCode:(NSInteger)code
{
    if(code != NetworkSucc)
    {
        NSLog(@"ShareListController gotTopicResult not successful");
        [[NSNotificationCenter defaultCenter] postNotificationName:KnotebleShowPopUpMessage object:@"Add person failed, please try again." userInfo:nil];
        return;
    }
    NSArray *bsonTopics = (NSArray *)obj;

    NSLog(@"ShareListController gotTopicResult successful count %d", (int)bsonTopics.count);

    for(BSONDocument *bsonDocument in bsonTopics)
    {
        NSMutableDictionary *resultDict = [[bsonDocument dictionaryValue] mutableCopy];
        
        TopicsEntity *topic = [[DataManager sharedInstance] insertOrUpdateNewTopicObject:resultDict];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KnotebleTopicChange object:nil userInfo:nil];

    [AppDelegate saveContext];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSearch {
    
#if New_DrawerDesign
    
    self.searchBar.showsCancelButton = YES;
    self.navigationItem.rightBarButtonItems = nil;
    
    self.navigationItem.titleView = _searchBar;
    self.searchController.displaysSearchBarInNavigationBar = YES;
    
    [_searchBar becomeFirstResponder];
    
#endif

}

- (void)copyLink {
    Utilities *util = [[Utilities alloc]init];

    [UIPasteboard generalPasteboard].string = [util getTopicURLFrom:self.topic];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Link Copied" message:[util getTopicURLFrom:self.topic] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}


#pragma mark - Table view data source

- (ContactsEntity *)contactForRow:(NSInteger)row tableView:(UITableView *)tableView
{
    if (tableView == self.searchController.searchResultsTableView){
        return self.searchResults[row];
    }
    
    if (_sortAlphabetical) {
        return self.sortedUsers[row];
    }
    
    NSInteger onPadCount = self.usersOnPad.count;
    if (row < onPadCount) {
        return self.usersOnPad[row];
    }
    row -= onPadCount;
//    if (row < self.usersOffPad.count){
//        return self.usersOffPad[row];
//    }
    return nil;
}

- (NSIndexPath *)indexPathForContact:(ContactsEntity *)contact tableView:(UITableView *)tableView
{
    NSInteger row;
    if (tableView == self.searchController.searchResultsTableView){
        row = [self.searchResults indexOfObject:contact];
    } else if (_sortAlphabetical) {
        row = [self.sortedUsers indexOfObject:contact];
    } else if ([self.usersOnPad containsObject:contact]){
        row = [self.usersOnPad indexOfObject:contact];
//    } else if ([self.usersOffPad containsObject:contact]){
//        row = [self.usersOffPad indexOfObject:contact] + self.usersOnPad.count;
    } else {
        row = 0;
    }
    return [NSIndexPath indexPathForRow:row inSection:0];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchController.searchResultsTableView) {
        return self.searchResults.count;
    }
    if (_sortAlphabetical) {
        return self.sortedUsers.count;
    }
    return self.usersOnPad.count/* + self.usersOffPad.count*/;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if New_DrawerDesign
    return 55.0;
#else
    return 60.0;
#endif
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if New_DrawerDesign
    SharePeopleCell *cell = (SharePeopleCell*)[tableView dequeueReusableCellWithIdentifier:ContactCellIdentifier];
#else
    ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier:ContactCellIdentifier];
#endif
    if (cell == nil)
    {
#if New_DrawerDesign

        cell = [[SharePeopleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContactCellIdentifier];
#else
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContactCellIdentifier];
#endif
    }
    cell.indexPath = indexPath;
    
    ContactsEntity *contact = [self contactForRow:indexPath.row tableView:tableView];
    cell.contactItem = contact;
    cell.lbTitle.text = contact.name;
    cell.lbDescription.text = @"";
    
    cell.targetDelegate = self;
    cell.contactItem = contact;
    
    if ([contact.username isEqualToString:@"angusd"])
    {
        NSLog(@"Need to debug");
    }
    
    [ContactsEntity getAsyncImage:contact WithBlock:^(id img, BOOL flag) {
        
        [cell.imgView setOriginalImage:Nil];
        [cell.imgView setOriginalImage:img];
        [cell.imgView draw];
        
    }];
    
    UIImage *accessoryImage;
    
    NSString *title;
    
    if ([self.usersOnPad containsObject:contact])
    {
        accessoryImage = [UIImage imageNamed:@"eye-open-gray-80"];
        title = @"Remove";
    }
    else
    {
        accessoryImage = [UIImage imageNamed:@"eye-closed-gray-80"];
        
        title = @"Add";
    }
    
    NSAttributedString *attTitle = [[NSAttributedString alloc] initWithString:title attributes:@{
                        NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:9]/*[UIFont systemFontOfSize:9.0]*/,
                        NSForegroundColorAttributeName:[DesignManager knoteHeaderTextColor]
                                              }];
    
    UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [accessoryButton setBackgroundImage:accessoryImage forState:UIControlStateNormal];
    [accessoryButton setAttributedTitle:attTitle forState:UIControlStateNormal];
#if New_DrawerDesign
    CGFloat buttonSize = 36.0;
#else
    CGFloat buttonSize = 40.0;
#endif
    [accessoryButton setFrame:CGRectMake(0, 0, buttonSize, buttonSize)];
    
    [accessoryButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [accessoryButton setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];

    //[accessoryButton setImageEdgeInsets:UIEdgeInsetsMake(0, 12, 6, 0)];
    [accessoryButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, -4, 0)];

    //accessoryButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    accessoryButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    AccountEntity* currentAccout = [DataManager sharedInstance].currentAccount;
    if ([currentAccout.account_id isEqual: contact.account_id])
    {
        accessoryButton.enabled = NO;
    }
    else
    {
        [accessoryButton addTarget:self action:@selector(contactActionPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.accessoryView = accessoryButton;
    
    [cell setNeedsUpdateConstraints];


    return cell;
}

- (void)contactActionPressed:(id)sender
{
    UIView *senderView = sender;
#if New_DrawerDesign
    while(senderView && ![senderView isKindOfClass:[SharePeopleCell class]]){
        senderView = [senderView superview];
    }
    if(!senderView){
        return;
    }
    
    SharePeopleCell *cell = (SharePeopleCell *)senderView;
    ContactsEntity *contact = cell.contactItem;

    if(!contact){
        return;
    }
    
    [self contactPressed:contact];
#else
    while(senderView && ![senderView isKindOfClass:[ContactCell class]]){
        senderView = [senderView superview];
    }
    if(!senderView){
        return;
    }
    
    ContactCell *cell = (ContactCell *)senderView;
    ContactsEntity *contact = cell.contactItem;
    
    if(!contact){
        return;
    }
    
    [self contactPressed:contact];
#endif
}

- (void)contactPressed:(ContactsEntity *)contact {
    NSIndexPath *indexPath = [self indexPathForContact:contact tableView:self.currentTableView];
    
    NSIndexPath *newIndexPath = nil;
    UITableViewRowAnimation deleteAnimation, insertAnimation;
    
    if([self.usersOnPad containsObject:contact])
    {
        //remove from pad
#if 1
        [self.usersOnPad removeObject:contact];
//        [self.usersOffPad insertObject:contact atIndex:0];
        
        if([self.originalUsersOnPad containsObject:contact])
        {
            //Need to remove from DB
            [self.usersToRemove addObject:contact];
        }
        
        [self.usersToAdd removeObject:contact];
        
        if(!(_sortAlphabetical || self.currentTableView == self.searchController.searchResultsTableView)){
            newIndexPath = [NSIndexPath indexPathForRow:self.usersOnPad.count inSection:0];
            
            deleteAnimation = UITableViewRowAnimationBottom;
            insertAnimation = UITableViewRowAnimationTop;
        }
#else
        NSUInteger index = [self.usersOnPad indexOfObject: contact];
        [self.usersOnPad removeObject:contact];
        [self.usersToRemove addObject:contact];
        [self.usersToAdd removeObject: contact];
        
        [self.tableView deleteRowsAtIndexPaths: @[[NSIndexPath indexPathForRow: index inSection: 0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        
        [[PostingManager sharedInstance] enqueueLocalMethod:DELETE_CONTACT_BY_ID
                                                 parameters:@[@{@"_id"    : contact.contact_id}]];
        
        [contact MR_deleteEntity];
        [AppDelegate saveContext];
        
        return;
#endif
    }
    else
    {
        //add to pad
//        [self.usersOffPad removeObject:contact];
        [self.usersOnPad insertObject:contact atIndex:0];
        
        if(![self.originalUsersOnPad containsObject:contact]){
            //Need to add to DB
            [self.usersToAdd addObject:contact];
        }
        [self.usersToRemove removeObject:contact];
        
        
        if(!(_sortAlphabetical || self.currentTableView == self.searchController.searchResultsTableView)){
            newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            deleteAnimation = UITableViewRowAnimationTop;
            insertAnimation = UITableViewRowAnimationBottom;
        }
    }
    
    if (self.currentTableView != self.tableView){
        [self.tableView reloadData];
        [self.searchDisplayController setActive:NO animated:YES];
        return;
    }
    
    
    if(!newIndexPath || newIndexPath.row == indexPath.row){
        [self.currentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.currentTableView beginUpdates];
        [self.currentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:deleteAnimation];
        [self.currentTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:insertAnimation];
        [self.currentTableView endUpdates];
    }
    
    [self proceedToContact];
    
   
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)setEditing:(BOOL)editing atIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell
{
    NSLog(@"setEditing %d atIndexPath: %@ cell: %@", editing, indexPath, cell);
}

-(void)floatingTraySetAlphabetical:(BOOL)alphabetical
{
    self.sortAlphabetical = alphabetical;
    if (!self.sortAlphabetical)
    {
        [self.recordBtn setImage:[UIImage imageNamed:@"alphabetical_sorting-48-gray"]
                        forState:UIControlStateNormal];
    }
    else
    {
        [self.recordBtn setImage:[[UIImage imageNamed:@"alphabetical_sorting-48-gray"] imageTintedWithColor:[UIColor blueColor]] forState:UIControlStateNormal];
    }
    /*if (self.sortAlphabetical)
    {
        
        ///[self.recordBtn setTitleColor:[DesignManager KnoteSelectedColor] forState:UIControlStateNormal];
    }
    else
    {
        //[self.recordBtn setTitleColor:[DesignManager KnoteNormalColor] forState:UIControlStateNormal];
    }*/
    
    [self.tableView reloadData];
}
- (void) showSearchLeftButton
{
    self.recordBtn.alpha = 0.0;
    
    [self.searchBgView addSubview:self.recordBtn];
    
    [UIView animateKeyframesWithDuration:.2 delay:0.3 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        _searchBar.alpha = 1;
        self.recordBtn.alpha = 0.5;
    } completion:^(BOOL finished) {
        
        [UIView animateKeyframesWithDuration:.3 delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
            self.recordBtn.alpha = 0.8;
            //[self.recordBtn setFrame:CGRectMake(14, 10, 22, 22)];
            [self.recordBtn setFrame:CGRectMake(_searchBgView.frame.size.width/2 -22/2, 10, 22, 22)];

#if New_DrawerDesign
            //[_searchBar setFrame:CGRectMake(0, 0, 250-40, 44)];

#else
            [_searchBar setFrame:CGRectMake(40, 0, CGRectGetWidth([UIScreen mainScreen].bounds)-40, 44)];
#endif
            _searchBar.alpha = 1;
        } completion:^(BOOL finished) {
            
            self.recordBtn.alpha = 1.0;
            
            _searchBar.alpha = 1.0;
            
           /* [_searchBar removeFromSuperview];
                
                self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0)];*/
            
            
        }];
    }];
}
- (void) hiddenSearchLeftButton
{
    [UIView animateKeyframesWithDuration:.2 delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        //[self.recordBtn setFrame:CGRectMake(14, 10, 10, 22)];
        [self.recordBtn setFrame:CGRectMake(_searchBgView.frame.size.width/2 -22/2, 10, 22, 22)];
        self.recordBtn.alpha = 0.0;
    } completion:^(BOOL finished) {
        
    }];
}


#pragma mark UISearchDisplayDelegate methods

- (void)updateSearchResultsForString:(NSString *)searchString
{
    [self.searchResults removeAllObjects];
    
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    
    for (ContactsEntity *contact in self.allContacts) {
        NSString *searchAgainst = contact.name;
        if(!searchAgainst || searchAgainst.length == 0){
            continue;
        }
        NSRange foundRange = [searchAgainst rangeOfString:searchString options:searchOptions range:NSMakeRange(0, searchAgainst.length)];
        if (foundRange.length > 0){
            [self.searchResults addObject:contact];
        }
    }
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [self searchBarCancelButtonClicked:_searchBar];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateSearchResultsForString:searchString];
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"didLoadSearchResultsTableView");
    
    tableView.backgroundColor = [UIColor clearColor];
    //tableView.backgroundView = [DesignManager appBackgroundView];
    tableView.backgroundColor = [DesignManager appBackgroundColor];
    
    tableView.separatorColor = [UIColor colorWithWhite:0.77 alpha:1.0];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    
    if (IOS7_OR_LATER)
    {
        [tableView setSeparatorInset:UIEdgeInsetsZero];//
    }
#endif
    
    //Hide empty separators
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = v;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    self.currentTableView = controller.searchResultsTableView;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    self.currentTableView = self.tableView;
}
-(void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"willShowSearchResultsTableView");

    //tmd
//#if New_DrawerDesign
//    [tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
//    
//    if (CGRectIsEmpty(self.searchTableViewRect)) {
//        
//        CGRect tableViewFrame = tableView.frame;
//        
//        tableViewFrame.origin.y = tableViewFrame.origin.y + 66; // + 66
//        tableViewFrame.size.height =  tableViewFrame.size.height - 66;  // - 66
//        
//        self.searchTableViewRect = tableViewFrame;
//        
//    }
//    [tableView setFrame:self.searchTableViewRect];
//#endif
}
- (void)addPersonPressed
{
    if (isFromThreadView)
    {
        if ([self.delegate respondsToSelector:@selector(makeViewFullScreen)])
        {
            [self.delegate makeViewFullScreen];
        }
    }
    else
    {
        [[[ContactManager sharedInstance] startAddPerson:self] fulfilled:^(id result) {
            
            NSString *email = result;
            self.justAddedContact = YES;
            [self.newlyAddedEmails addObject:email];
            [[DataManager sharedInstance] fetchRemoteContacts];
        }];
    }
}
-(void)getAtON:(id)result
{
    NSString *email = result;
    self.justAddedContact = YES;
    [self.newlyAddedEmails addObject:email];
    [[DataManager sharedInstance] fetchRemoteContacts];
}
- (void)fetchedContacts
{
    [self updateContacts];
    [self.tableView reloadData];
}

- (void)updateSharedTopicContact:(ContactsEntity *)contact Removed:(BOOL)bRemove {
    [self contactPressed:contact];
}


#pragma mark - Search Bar Delegate
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
//    self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(searchBarCancelButtonClicked:)];
//    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];

    [self hiddenSearchLeftButton];
    return YES;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self showSearchLeftButton];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //tmd
    //[self.searchDisplayController setActive:NO];
    //self.navigationItem.rightBarButtonItem = self.addContactButton;
}

@end


#pragma mark -
#pragma mark - ContactCellDelegate implemention

@implementation ShareListController (ContactCellDelegate)

- (void)ShowProfile:(ContactsEntity*)contact
{
    // Lin - Added to
    /*
     Show profile
     Button Style : Remove from contact
     */
    // Lin - Ended
    
    MyProfileController *profile = [[MyProfileController alloc] initWithContact:contact];
    
    [profile setProfile_remove_buttonType:RemoveFromNone];
    
    profile.delegate = self;
    
    if (![self.usersOnPad containsObject:contact]) {
        
    }
    else
    {
        
    }
    
    __block MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:profile];
    
    CGFloat ctlHeight = self.view.bounds.size.height - 60;
    
    formSheet.presentedFormSheetSize = CGSizeMake(300, ctlHeight);
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    
    [formSheet setPortraitTopInset:20];
    [formSheet setLandscapeTopInset:20];
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
    };
    
    [MZFormSheetController sharedBackgroundWindow].formSheetBackgroundWindowDelegate = self;
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
}

@end


#pragma mark - Navigation Custom Menu ActionDelegate implemention

@implementation ShareListController (KnoteNSCMDelegate)

- (void) SharePadAddAction
{
    [self addPersonPressed];
}

- (void) SharePadSortAction
{
    BOOL    senderFlag = !self.sortAlphabetical;
    
    [self floatingTraySetAlphabetical:senderFlag];
}

@end


