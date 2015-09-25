#import "LoginViewController.h"
#import "ListViewController.h"
#import <ObjectiveDDP/MeteorClient.h>
#import "LoginViewCell.h"
#import "TopicsListViewController.h"
#import "ContactsListViewController.h"
#define kAdvanceTest 1

typedef NS_OPTIONS(NSInteger, UIButtonState) {
    UIButtonStatePress,
    UIButtonStateNormal,
    UIButtonStateDisable,

};
#define MUTE_KNOTE_FETCH_LIMIT 10000
#define kFunName @"kFunName"
#define kFunContent @"kFunContent"
#define kDevServer @"ws://dev.knotable.com/websocket"
#define kStatingServer @"ws://staging.knotable.com/websocket"
#define kBetaServer @"ws://beta.knotable.com/websocket"
@interface LoginViewController ()<UITableViewDataSource,UITableViewDelegate,LoginViewCellDelegate>
{
    NSInteger _fetchContactsLimit;
    NSInteger _fetchContactsOffset;
}
@property (weak, nonatomic) IBOutlet UIButton *betaBtn;
@property (weak, nonatomic) IBOutlet UIButton *staginBtn;
@property (weak, nonatomic) IBOutlet UIButton *devBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UIButton *sessionLoginButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) NSInteger currentOrder;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *account_id;

@property (nonatomic, strong) NSDate *connectDate;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, strong) NSDate *userPrivateDataDate;
@property (nonatomic, assign) BOOL isPrivateDataReady;
@property (nonatomic, assign) BOOL privateDataTaped;
@property (nonatomic, strong) NSDictionary *loginContacts;

@property (nonatomic, strong) NSDate *contactsDate;
@property (nonatomic, strong) NSMutableArray *contactsArray;
@property (nonatomic, assign) NSInteger contactsCount;
@property (nonatomic, assign) BOOL contactsTaped;

@property (nonatomic, strong) NSDate *topicsDate;
@property (nonatomic, strong) NSMutableArray *topicsArray;
@property (nonatomic, assign) NSInteger topicsCount;
@property (nonatomic, assign) BOOL topicsTaped;


@property (nonatomic, strong) NSDate *archivedTopicsDate;
@property (nonatomic, strong) NSMutableArray *archivedTopicsArray;
@property (nonatomic, assign) NSInteger archivedTopicsCount;
@property (nonatomic, assign) BOOL archivedTopicsTaped;


@end
@implementation LoginViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.email.text = @"angusd";
    self.password.text = @"knotable";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(meteorClientDisconnect) name:MeteorClientDidDisconnectNotification object:nil];
    [self setStats];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    self.dateFormatter.dateFormat =@"yyyy-MM-dd'T'HH:mm:ss.SSS";
    [self.dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [self setLoginButton:nil enable:NO level:UIButtonStateDisable];
    [self setLogoutButton:nil enable:NO level:UIButtonStateDisable];
    [self setSessionLoginButton:nil enable:NO level:UIButtonStateDisable];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(meteorConnected:)
                                                 name:@"connected"
                                               object:nil];
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isLogin = NO;
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)initData
{
    self.dataArray = [NSMutableArray new];
    self.archivedTopicsArray = [NSMutableArray new];
    self.topicsArray = [NSMutableArray new];
    self.contactsArray = [NSMutableArray new];
    self.isLogin = NO;
    self.user_id = @"";
    
    self.userPrivateDataDate = nil;
    self.contactsDate= nil;
    self.topicsDate= nil;
    self.archivedTopicsDate= nil;
    self.connectDate= nil;
    self.currentOrder = 0;
    self.account_id = @"";
    self.loginContacts = nil;
    self.archivedTopicsCount = 0;
    self.topicsCount = 0;
    self.contactsCount = 0;
    self.isPrivateDataReady = NO;
    self.privateDataTaped = NO;
    self.contactsTaped = NO;
    self.topicsTaped = NO;
    self.archivedTopicsTaped = NO;
}
- (void)clearData
{
    [self.dataArray removeAllObjects];
    [self.archivedTopicsArray removeAllObjects];
    [self.topicsArray removeAllObjects];
    [self.contactsArray removeAllObjects];
    self.loginStatusText.text = @"";
    self.isLogin = NO;
    self.user_id = @"";
    
    self.userPrivateDataDate = nil;
    self.contactsDate= nil;
    self.topicsDate= nil;
    self.archivedTopicsDate= nil;
    self.connectDate= nil;
    self.currentOrder = 0;
    self.account_id = @"";
    self.loginContacts = nil;
    self.archivedTopicsCount = 0;
    self.topicsCount = 0;
    self.contactsCount = 0;
    self.isPrivateDataReady = NO;
    self.privateDataTaped = NO;
    self.contactsTaped = NO;
    self.topicsTaped = NO;
    self.archivedTopicsTaped = NO;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
- (void)setLoginButton:(NSString *)title enable:(BOOL)enable level:(UIButtonState)level
{
    self.loginBtn.userInteractionEnabled = enable;
    if (!enable) {
        if (level == UIButtonStateDisable) {
            self.loginBtn.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
        } else if (level == UIButtonStatePress)  {
            self.loginBtn.backgroundColor = [UIColor colorWithRed:12.0/255.0 green:107.0/255.0 blue:105.0/255.0 alpha:1];
        } else {
            self.loginBtn.backgroundColor = [UIColor lightGrayColor];
        }
    } else {
        self.loginBtn.backgroundColor = [UIColor colorWithRed:32.0/255.0 green:157.0/255.0 blue:255.0/255.0 alpha:1];
        
    }
    if (title) {
        [self.loginBtn setTitle:title forState:UIControlStateNormal];
    }
}
- (void)setLogoutButton:(NSString *)title enable:(BOOL)enable level:(UIButtonState)level
{
    self.logoutBtn.userInteractionEnabled = enable;
    if (!enable) {
        if (level == UIButtonStateDisable) {
            self.logoutBtn.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
        } else if (level == UIButtonStatePress)  {
            self.logoutBtn.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:10.0/255.0 blue:10.0/255.0 alpha:1];
        } else {
            self.logoutBtn.backgroundColor = [UIColor lightGrayColor];
        }
    } else {
        self.logoutBtn.backgroundColor = [UIColor colorWithRed:202.0/255.0 green:10.0/255.0 blue:10.0/255.0 alpha:1];
        
    }
    if (title) {
        [self.logoutBtn setTitle:title forState:UIControlStateNormal];
    }
}
- (void)setSessionLoginButton:(NSString *)title enable:(BOOL)enable level:(UIButtonState)level
{
    self.sessionLoginButton.userInteractionEnabled = enable;
    if (!enable) {
        if (level == UIButtonStateDisable) {
            self.sessionLoginButton.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
        } else if (level == UIButtonStatePress)  {
            self.sessionLoginButton.backgroundColor = [UIColor colorWithRed:12.0/255.0 green:107.0/255.0 blue:105.0/255.0 alpha:1];
        } else {
            self.sessionLoginButton.backgroundColor = [UIColor lightGrayColor];
        }
    } else {
        self.sessionLoginButton.backgroundColor = [UIColor colorWithRed:32.0/255.0 green:157.0/255.0 blue:255.0/255.0 alpha:1];
        
    }
    if (title) {
        [self.sessionLoginButton setTitle:title forState:UIControlStateNormal];
    }
}
-(void)setStats
{
    self.privateDataTaped = NO;
    self.contactsTaped = NO;
    self.topicsTaped = NO;
    self.archivedTopicsTaped = NO;
}
- (IBAction)clearStats:(id)sender {
    [self setStats];
}
- (void)meteorClientDisconnect
{
    self.isLogin = NO;
    [self setStats];
}
-(void)displaySocketReady:(BOOL)ready
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ready) {
            UIImage *image = [UIImage imageNamed: @"green_light.png"];
            [self.connectionStatusLight setImage:image];
            self.connectionStatusText.text = [NSString stringWithFormat:@"Socket Connected Cost:%0.1fms",([self.connectDate  timeIntervalSinceNow]*-1000)];
            if (self.meteor.sessionToken) {
                self.loginStatusText.text = @"SessionLogin";
            } else {
                self.loginStatusText.text = @"NameLogin";
            }
            
            if (self.meteor.authState == AuthStateLoggedIn) {
                [self setLogoutButton:nil enable:self.meteor.websocketReady level:UIButtonStateNormal];
            } else {
                [self setLogoutButton:nil enable:NO level:UIButtonStateNormal];
            }
            
            [self setLoginButton:nil enable:ready level:UIButtonStateNormal];
        } else {
            UIImage *image = [UIImage imageNamed: @"red_light.png"];
            [self.connectionStatusLight setImage:image];
            self.connectionStatusText.text = [NSString stringWithFormat:@"Socket DisConnected"];
            self.connectDate = [NSDate date];
            self.isLogin = NO;
            
            [self setLogoutButton:nil enable:ready level:UIButtonStateNormal];
            [self setLoginButton:nil enable:ready level:UIButtonStateNormal];
        }

    });
}

#pragma mark <NSKeyValueObserving>

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"websocketReady"]) {
        [self displaySocketReady:self.meteor.websocketReady];
    } else if ([keyPath isEqualToString:@"sessionToken"]) {
        if (self.meteor.sessionToken) {
            [self setSessionLoginButton:nil enable:YES level:UIButtonStateNormal];
        } else {
            [self setSessionLoginButton:nil enable:NO level:UIButtonStateNormal];
        }
    }
}
-(void)meteorConnected:(NSNotification *)note
{
    self.userPrivateDataDate = [NSDate date];
    self.contactsDate= [NSDate date];
    self.topicsDate= [NSDate date];
    self.archivedTopicsDate= [NSDate date];
    self.connectDate= [NSDate date];
}
#pragma mark UI Actions
-(BOOL)checkMeteorStats
{
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    if (!self.meteor.websocketReady) {
        UIAlertView *notConnectedAlert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                                    message:@"Can't find the Todo server, try again"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
        [notConnectedAlert show];
        return NO;
    }
    return YES;
}
- (IBAction)didTapSessionLoginButton:(id)sender {
    if (![self checkMeteorStats]) {
        return;
    }
#if PRE_DDP_FEATURE
    if (self.meteor.sessionToken) {
        __block NSDate *loginDate = [NSDate date];
        [self setSessionLoginButton:nil enable:NO level:UIButtonStateNormal];
        [self.meteor logonWithSessionToken:self.meteor.sessionToken responseCallback:^(NSDictionary *response, NSError *error) {
            if (error) {
                [self handleFailedAuth:error];
                self.loginStatusText.text = [NSString stringWithFormat:@"Login Failed Cost:%0.1fms",([loginDate  timeIntervalSinceNow]*-1000)];
                [self setLoginButton:nil enable:YES level:UIButtonStateNormal];
                [self setSessionLoginButton:nil enable:NO level:UIButtonStateNormal];
                return;
            }
            self.isLogin = YES;
            self.user_id = response[@"result"][@"id"];
            self.loginStatusText.text = [NSString stringWithFormat:@"Login Success Cost:%0.1fms",([loginDate  timeIntervalSinceNow]*-1000)];
            [self handleSuccessfulAuth];
            [self setLoginButton:nil enable:NO level:UIButtonStateNormal];
            [self setLogoutButton:nil enable:YES level:UIButtonStateNormal];
        }];
    } else {
        [self showAlertInfo:@"not got session Token"];
    }
#else
    [self meteorLoginWithSessionToken:self.meteor.sessionToken];
#endif
}
- (IBAction)didTapLoginButton:(id)sender {
    
    if (![self checkMeteorStats]) {
        return;
    }
#if PRE_DDP_FEATURE
    __block NSDate *loginDate = [NSDate date];
    [self setLoginButton:nil enable:NO level:UIButtonStatePress];
    self.isPrivateDataReady = NO;
    if ([self.email.text rangeOfString:@"@"].location != NSNotFound) {
        
        [self.meteor logonWithEmail:self.email.text password:self.password.text responseCallback:^(NSDictionary *response, NSError *error) {
            if (error) {
                [self handleFailedAuth:error];
                self.loginStatusText.text = [NSString stringWithFormat:@"Login Failed Cost:%0.1fms",([loginDate  timeIntervalSinceNow]*-1000)];
                [self setLoginButton:nil enable:YES level:UIButtonStateNormal];
                return;
            }
            self.isLogin = YES;
            self.user_id = response[@"result"][@"id"];
            self.loginStatusText.text = [NSString stringWithFormat:@"Login Success Cost:%0.1fms",([loginDate  timeIntervalSinceNow]*-1000)];
            [self handleSuccessfulAuth];
            [self setLoginButton:nil enable:NO level:UIButtonStateNormal];
            [self setLogoutButton:nil enable:YES level:UIButtonStateNormal];
        }];
    } else {
        
        [self.meteor logonWithUsername:self.email.text password:self.password.text responseCallback:^(NSDictionary *response, NSError *error) {
            if (error) {
                [self handleFailedAuth:error];
                self.loginStatusText.text = [NSString stringWithFormat:@"Login Failed Cost:%0.1fms",([loginDate  timeIntervalSinceNow]*-1000)];
                [self setLoginButton:nil enable:YES level:UIButtonStateNormal];
                return;
            }
            self.isLogin = YES;
            self.user_id = response[@"result"][@"id"];
            self.loginStatusText.text = [NSString stringWithFormat:@"Login Success Cost:%0.1fms",([loginDate  timeIntervalSinceNow]*-1000)];
            [self handleSuccessfulAuth];
            [self setLoginButton:nil enable:NO level:UIButtonStateNormal];
            [self setLogoutButton:nil enable:YES level:UIButtonStateNormal];
        }];
    }
#else
    [self meteorLoginWithUserName];
#endif
}
- (IBAction)didTapLogoutButton:(id)sender {
    [self clearData];
    [self serverButtonClicked:nil];
    [self.tableView reloadData];
#if 0
    [self.meteor logout];
    [self closePreMeteor];

#else
//    [self.meteor removeSubscription:@"contacts"];
//    [self.meteor removeAllSubscription];
    [self.meteor logout];
#endif
    [self setLoginButton:nil enable:YES level:UIButtonStateDisable];
    [self setLogoutButton:nil enable:NO level:UIButtonStateDisable];
    [self setSessionLoginButton:nil enable:NO level:UIButtonStateDisable];
}
- (void)meteorLoginWithUserName
{
    __block NSDate *loginDate = [NSDate date];
    NSString *usernameField = @"username";
    NSDictionary *loginParams = @{@"user"       : @{usernameField:self.email.text},
                                  @"password"   : self.password.text};
    [self setLoginButton:nil enable:NO level:UIButtonStateDisable];
    self.isPrivateDataReady = NO;
    self.loginStatusText.text = @"NameLogin";
    [self.meteor callMethodName:@"login"
                     parameters:@[loginParams]
               responseCallback:^(NSDictionary *response, NSError *error) {
                   if (error) {
                       [self handleFailedAuth:error];
                       self.loginStatusText.text = [NSString stringWithFormat:@"Login Failed Cost:%0.1fms",([loginDate  timeIntervalSinceNow]*-1000)];
                       [self setLoginButton:nil enable:YES level:UIButtonStateNormal];
                       return;
                   }
                   
                   NSTimeInterval timeTook = -[loginDate timeIntervalSinceNow];
                   
                   NSLog(@"login took: %f", timeTook);
                   [self handleSuccessfulAuth];
                   self.isLogin = YES;
                   self.user_id = response[@"result"][@"id"];
#if !PRE_DDP_FEATURE
                   self.meteor.sessionToken = response[@"result"][@"token"];
#endif

                   dispatch_async(dispatch_get_main_queue(), ^{
                       self.loginStatusText.text = [NSString stringWithFormat:@"Name Login Success Cost:%0.1fms",([loginDate  timeIntervalSinceNow]*-1000)];
                       [self.tableView reloadData];
                       [self setLoginButton:nil enable:NO level:UIButtonStateDisable];
                   });
               }];
}
- (void)meteorLoginWithSessionToken:(NSString *)token
{    
    self.loginStatusText.text = @"TokenLogin";
    NSDictionary *loginParams = @{@"resume":token};
    __block NSDate *loginDate = [NSDate date];
    [self setLogoutButton:nil enable:NO level:UIButtonStatePress];
    [self.meteor callMethodName:@"login"
                     parameters:@[loginParams]
               responseCallback:^(NSDictionary *response, NSError *error) {
                   if (error)
                   {
                       NSString *reason = nil;
                       NSDictionary *dic = error.userInfo[NSLocalizedDescriptionKey];
                       if ([dic isKindOfClass:[NSDictionary class]])
                       {
                           reason = dic[@"reason"];
                       }
                       else if ([dic isKindOfClass:[NSString class ]])
                       {
                           reason = (NSString *)dic;
                       }
                       [self showAlertInfo:reason];
                       [self setLogoutButton:nil enable:YES level:UIButtonStateNormal];
                   }
                   else
                   {
                       NSDictionary *result = response[@"result"];
                       self.user_id = result[@"id"];
#if !PRE_DDP_FEATURE
                       self.meteor.authState = AuthStateLoggedIn;
                       self.meteor.userId = self.user_id;
                       self.meteor.sessionToken = token;
#endif
                       self.isLogin = YES;
                       [self handleSuccessfulAuth];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self setLogoutButton:nil enable:NO level:UIButtonStateDisable];
                           self.loginStatusText.text = [NSString stringWithFormat:@"Token Login Success Cost:%0.1fms",([loginDate  timeIntervalSinceNow]*-1000)];
                       });
                   }
               }];
}

- (IBAction)didTapExitButton:(id)sender {
    exit(0);
}
//#define kServer @"ws://dev.knotable.com/websocket"
//#define kServer @""
-(void)disableAllBtn
{
}
-(void)closePreMeteor
{
    [self clearData];
    [self displaySocketReady:NO];
    [self.meteor removeObserver:self forKeyPath:@"websocketReady"];
    [self.meteor removeObserver:self forKeyPath:@"sessionToken"];
    
    self.meteor.ddp.delegate = nil;
    self.meteor.ddp.webSocket.delegate = nil;
    self.meteor.ddp = nil;
    [self.meteor disconnect];
    self.meteor = nil;
}
-(void)connectServer:(NSString *)server
{
    [self setSessionLoginButton:nil enable:NO level:UIButtonStateDisable];

    if (!self.meteor) {
        self.meteor = [[MeteorClient alloc] initWithDDPVersion:@"pre2"];
        ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:server delegate:self.meteor];
        self.meteor.ddp = ddp;
        [self.meteor.ddp connectWebSocket];
        [self.meteor addObserver:self
                      forKeyPath:@"websocketReady"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
        [self.meteor addObserver:self
                      forKeyPath:@"sessionToken"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    } else if (![self.meteor.ddp.urlString isEqualToString:server]) {
        [self closePreMeteor];
        self.meteor = [[MeteorClient alloc] initWithDDPVersion:@"pre2"];
        ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:server delegate:self.meteor];
        self.meteor.ddp = ddp;
        [self.meteor.ddp connectWebSocket];
        [self.meteor addObserver:self
                      forKeyPath:@"websocketReady"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
        [self.meteor addObserver:self
                      forKeyPath:@"sessionToken"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    } else if (!self.meteor.connected) {
#if PRE_DDP_FEATURE
        [self.meteor reconnect];
#endif
    }
}
-(void)serverButtonClicked:(UIButton *)button
{
    self.staginBtn.backgroundColor = [UIColor lightGrayColor];
    self.devBtn.backgroundColor = [UIColor lightGrayColor];
    self.betaBtn.backgroundColor = [UIColor lightGrayColor];
    button.backgroundColor = [UIColor blueColor];
}

- (IBAction)stagingButton:(id)sender {
    [self connectServer:kStatingServer];
    [self serverButtonClicked:sender];
    
    self.connectDate = [NSDate date];
    self.email.text = @"angusk";
    self.password.text = @"Alcibiades1";
    [self disableAllBtn];
}
- (IBAction)devButton:(id)sender {
    [self connectServer:kDevServer];
    [self serverButtonClicked:sender];

    self.connectDate = [NSDate date];
    self.staginBtn.backgroundColor = [UIColor lightGrayColor];
    self.devBtn.backgroundColor = [UIColor blueColor];
    self.betaBtn.backgroundColor = [UIColor lightGrayColor];
    self.email.text = @"angusd";
    self.password.text = @"knotable";
    [self disableAllBtn];
}

- (IBAction)betaButton:(id)sender {
    [self connectServer:kBetaServer];
    [self serverButtonClicked:sender];

    self.connectDate = [NSDate date];
    self.staginBtn.backgroundColor = [UIColor lightGrayColor];
    self.devBtn.backgroundColor = [UIColor lightGrayColor];
    self.betaBtn.backgroundColor = [UIColor blueColor];
    self.email.text = @"angus";
    self.password.text = @"Aristotle1";

    [self disableAllBtn];
}
#pragma mark - Internal

- (void)handleSuccessfulAuth {
#if 0
    [self.dataArray addObject:[@{kFunName:@"getMuteKnotes"}mutableCopy]];
    [self.dataArray addObject:[@{kFunName:@"getHotKnotes"}mutableCopy]];
    [self.dataArray addObject:[@{kFunName:@"getPeople"}mutableCopy]];
    [self.dataArray addObject:[@{kFunName:@"getPads"}mutableCopy]];
#endif
    [self.dataArray removeAllObjects];
    [self.dataArray addObject:[@{kFunName:@"userPrivateData"}mutableCopy]];
    [self.dataArray addObject:[@{kFunName:@"contacts"}mutableCopy]];
    [self.dataArray addObject:[@{kFunName:@"topics"}mutableCopy]];
    [self.dataArray addObject:[@{kFunName:@"archivedTopics"}mutableCopy]];
    
    _fetchContactsLimit = 10;
    _fetchContactsOffset = 0;
    [self setStats];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });

}
-(IBAction)getMuteKnotes:(id)sender cell:(LoginViewCell *)cell
{
    __block double timeStamp = 0;
    NSArray *pama = @[@(MUTE_KNOTE_FETCH_LIMIT), @(timeStamp)];
    __block NSDate *date = [NSDate date];
    [self.meteor callMethodName:@"getMuteKnotes"
                     parameters:pama
               responseCallback:^(NSDictionary *response, NSError *error) {
               cell.detailLabel.text = [NSString stringWithFormat:@"Cost:%0.1fms",([date  timeIntervalSinceNow]*-1000)];
               }
     ];
}

-(IBAction)getHotKnotes:(id)sender cell:(LoginViewCell *)cell
{
    __block double timeStamp = 0;
    NSArray *pama = @[@(MUTE_KNOTE_FETCH_LIMIT), @(timeStamp)];
    __block NSDate *date = [NSDate date];
    [self.meteor callMethodName:@"getHotKnotes"
                     parameters:pama
               responseCallback:^(NSDictionary *response, NSError *error) {
                   cell.detailLabel.text = [NSString stringWithFormat:@"Cost:%0.1fms",([date  timeIntervalSinceNow]*-1000)];
               }
     ];
}
-(IBAction)getPeople:(id)sender cell:(LoginViewCell *)cell
{
    __block NSDate *date = [NSDate date];
    [self.meteor callMethodName:@"getPeople"
                     parameters:@[@(_fetchContactsLimit), @(_fetchContactsOffset)]
               responseCallback:^(NSDictionary *response, NSError *error) {
                   NSArray *resultDocArray = (NSArray *)response[@"result"];
                   if (_fetchContactsOffset == 0) {
                       cell.detailLabel.text = [NSString stringWithFormat:@"Cost:%0.1fms",([date  timeIntervalSinceNow]*-1000)];
                   } else {
                       cell.detailLabel.text = [NSString stringWithFormat:@"%@|%0.1fms",cell.detailLabel.text,([date  timeIntervalSinceNow]*-1000)];
                   }
                   if ([resultDocArray count]>0) {
                       _fetchContactsOffset += [resultDocArray count];
                       [self getPeople:nil cell:cell];
                   }
               }
     ];
}
-(IBAction)getPads:(id)sender cell:(LoginViewCell *)cell
{
    NSMutableArray *param = [NSMutableArray new];
    
    [param addObject:self.user_id];
    
    if (self.currentOrder!=0)
    {
        [param addObject:@(self.currentOrder)];
    }
    __block NSDate *date = [NSDate date];

    [self.meteor callMethodName:@"getPads"
                     parameters:[param copy]
               responseCallback:^(NSDictionary *response, NSError *error) {
                   if (!error)
                   {
                       if (self.currentOrder == 0) {
                           cell.detailLabel.text = [NSString stringWithFormat:@"Cost:%0.1fms",([date  timeIntervalSinceNow]*-1000)];
                       } else {
                           cell.detailLabel.text = [NSString stringWithFormat:@"%@|%0.1fms",cell.detailLabel.text,([date  timeIntervalSinceNow]*-1000)];
                       }
                       
                       NSArray *resultDocArray = (NSArray *)response[@"result"];
                       for(NSDictionary *dic in resultDocArray)
                       {
                           
                           if (self.currentOrder == 0
                               || [dic[@"order"][self.user_id] integerValue] < self.currentOrder )
                           {
                               self.currentOrder = [dic[@"order"][self.user_id] integerValue];
                               NSLog(@"Current Order : %d", (int)self.currentOrder);
                           }
                       }
                       if (resultDocArray.count>0) {
                           [self getPads:nil cell:cell];
                       }
                   }
               }
     ];
}
#pragma mark - topics Subscription

-(IBAction)addSubTopics:(id)sender cell:(LoginViewCell *)cell
{
    self.topicsDate = [NSDate date];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"topics_added" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TopicsCount_added" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicsAdded:)
                                                 name:@"topics_added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicsCountAdded:)
                                                 name:@"TopicsCount_added"
                                               object:nil];
    [self.meteor addSubscription:@"topics" withParameters:nil];
    cell.detailLabel.text = [NSString stringWithFormat:@"total:%d current:%d Cost:%0.1fms",(int)self.topicsCount,(int)self.topicsArray.count,([self.topicsDate  timeIntervalSinceNow]*-1000)];
    cell.timeLabel.text = [NSString stringWithFormat:@"Start:%@",[self.dateFormatter stringFromDate:self.topicsDate]];
}

-(void)topicsCountAdded:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    if (note.userInfo)
    {
        serverData = note.userInfo;
    }
    if (serverData[@"count"]) {
        self.topicsCount = [serverData[@"count"] integerValue];
    }
    for (int i = 0; i<[self.tableView numberOfRowsInSection:0]; i++) {
        NSDictionary *dic = self.dataArray[i];
        if ([dic[kFunName] isEqualToString:@"topics"]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            LoginViewCell *cell = ( LoginViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.detailLabel.text = [NSString stringWithFormat:@"total:%d current:%d",(int)self.topicsCount,(int)self.topicsArray.count];
            [self.topicsArray removeAllObjects];
            break;
        }
    }
}
-(void)topicsAdded:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    if (note.userInfo)
    {
        serverData = note.userInfo;
    }
    BOOL isArchived = NO;
    if (serverData[@"_id"]) {
        NSArray *archivedArray = serverData[@"archived"];
        for (NSString *_id in archivedArray) {
            if ([_id isEqualToString:self.account_id]) {
                isArchived = YES;
                break;
            }
        }
        if (isArchived) {
            [self.archivedTopicsArray addObject:serverData];
        } else {
            [self.topicsArray addObject:serverData];
        }
    }
    for (int i = 0; i<[self.tableView numberOfRowsInSection:0]; i++) {
        NSDictionary *dic = self.dataArray[i];
        if (isArchived) {
            if ([dic[kFunName] isEqualToString:@"archivedTopics"]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                LoginViewCell *cell = ( LoginViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                cell.detailLabel.text = [NSString stringWithFormat:@"total:%d current:%d",(int)self.archivedTopicsCount,(int)self.archivedTopicsArray.count];
                if (self.archivedTopicsCount>0) {
                    cell.detailLabel.text = [NSString stringWithFormat:@"total:%d current:%d Cost:%0.1fms",(int)self.archivedTopicsCount,(int)self.archivedTopicsArray.count,([self.archivedTopicsDate  timeIntervalSinceNow]*-1000)];
                    self.archivedTopicsTaped = NO;
#if 0
                    if (self.archivedTopicsArray.count>0 && self.archivedTopicsCount>0 ) {
                        cell.progressBarRoundedFat.hidden = NO;
                        [cell.progressBarRoundedFat setProgress:((self.archivedTopicsArray.count-1)*1.0)/(self.archivedTopicsCount*1.0) animated:YES];
                    }  else {
                        [cell.progressBarRoundedFat setProgress:0 animated:YES];
                    }
#endif
                }
                break;
            }
        } else {
            if ([dic[kFunName] isEqualToString:@"topics"]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                LoginViewCell *cell = ( LoginViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                cell.detailLabel.text = [NSString stringWithFormat:@"total:%d current:%d",(int)self.topicsCount,(int)self.topicsArray.count];
                
                if (self.topicsCount>0) {
                    cell.detailLabel.text = [NSString stringWithFormat:@"total:%d current:%d Cost:%0.1fms",(int)self.topicsCount,(int)self.topicsArray.count,([self.topicsDate  timeIntervalSinceNow]*-1000)];
                    self.topicsTaped = NO;
#if 0
                    if (self.topicsArray.count>0 && self.topicsCount>0 ) {
                        cell.progressBarRoundedFat.hidden = NO;
                        [cell.progressBarRoundedFat setProgress:((self.topicsArray.count-1)*1.0)/(self.topicsCount*1.0) animated:YES];
                    }  else {
                        [cell.progressBarRoundedFat setProgress:0 animated:YES];
                    }
#endif
                }
                break;
            }            
        }
    }
}
-(void)willEntryTopics:(NSString *)str
{
    BOOL find = NO;
    for (NSDictionary *dic in self.dataArray) {
        if ([dic[kFunName] isEqualToString:@"knotes"]) {
            find = YES;
        }
    }
    if (!find) {
        [self.dataArray addObject:[@{kFunName:@"knotes"}mutableCopy]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}
#pragma mark - archived topics Subscription

-(IBAction)addSubArchivedTopics:(id)sender cell:(LoginViewCell *)cell
{
    self.archivedTopicsDate = [NSDate date];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"topics_added" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ArchivedTopicsCount_added" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicsAdded:)
                                                 name:@"topics_added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(archivedTopicsCountAdded:)
                                                 name:@"ArchivedTopicsCount_added"
                                               object:nil];
    
    [self.meteor addSubscription:@"archivedTopics" withParameters:nil];
    cell.detailLabel.text = [NSString stringWithFormat:@"total:%d current:%d Cost:%0.1fms",(int)self.archivedTopicsCount,(int)self.archivedTopicsArray.count,([self.archivedTopicsDate  timeIntervalSinceNow]*-1000)];
    cell.timeLabel.text = [NSString stringWithFormat:@"Start:%@",[self.dateFormatter stringFromDate:self.archivedTopicsDate]];
}


-(void)archivedTopicsCountAdded:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    
    if (note.userInfo)
    {
        serverData = note.userInfo;
    }
    if (serverData[@"count"]) {
        self.archivedTopicsCount = [serverData[@"count"] integerValue];
    }
    for (int i = 0; i<[self.tableView numberOfRowsInSection:0]; i++) {
        NSDictionary *dic = self.dataArray[i];
        if ([dic[kFunName] isEqualToString:@"archivedTopics"]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            LoginViewCell *cell = ( LoginViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.detailLabel.text = [NSString stringWithFormat:@"total:%d current:%d",(int)self.archivedTopicsCount,(int)self.archivedTopicsArray.count];
            [self.archivedTopicsArray removeAllObjects];
            break;
        }
    }
}
#pragma mark - contacts Subscription

-(IBAction)addSubContacts:(id)sender cell:(LoginViewCell *)cell
{
    self.contactsDate = [NSDate date];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contacts_added" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OtherContactsCount_added" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactsAdded:)
                                                 name:@"contacts_added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactsCountAdded:)
                                                 name:@"OtherContactsCount_added"
                                               object:nil];
    cell.detailLabel.text = [NSString stringWithFormat:@"total:%d current:%d Cost:%0.1fms",(int)self.contactsCount,(int)self.contactsArray.count,([self.contactsDate  timeIntervalSinceNow]*-1000)];

    [self.meteor addSubscription:@"contacts" withParameters:nil];
    cell.timeLabel.text = [NSString stringWithFormat:@"Start:%@",[self.dateFormatter stringFromDate:self.contactsDate]];
}
-(void)contactsAdded:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    
    if (note.userInfo)
    {
        serverData = note.userInfo;
    }

    if (self.account_id && [self.account_id isEqualToString:serverData[@"_id"]]) {
        self.loginContacts = serverData;
    } else {
        if (serverData[@"_id"]) {
            [self.contactsArray addObject:serverData];
        }
        for (int i = 0; i<[self.tableView numberOfRowsInSection:0]; i++) {
            NSDictionary *dic = self.dataArray[i];
            if ([dic[kFunName] isEqualToString:@"contacts"]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                LoginViewCell *cell = ( LoginViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                cell.detailLabel.text = [NSString stringWithFormat:@"total:%d current:%d Cost:%0.1fms",(int)self.contactsCount,(int)self.contactsArray.count,([self.contactsDate  timeIntervalSinceNow]*-1000)];
#if 0
                if (self.contactsArray.count>0 && self.contactsCount>0 ) {
                    cell.progressBarRoundedFat.hidden = NO;
                    [cell.progressBarRoundedFat setProgress:((self.contactsArray.count-1)*1.0)/(self.contactsCount*1.0) animated:YES];
                }  else {
                    [cell.progressBarRoundedFat setProgress:0 animated:YES];
                }
#endif
                break;
            }
        }
    }
}
-(void)contactsCountAdded:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    
    if (note.userInfo)
    {
        serverData = note.userInfo;
    }
    if (serverData[@"count"]) {
        self.contactsCount = [serverData[@"count"] integerValue];
    }
    for (int i = 0; i<[self.tableView numberOfRowsInSection:0]; i++) {
        NSDictionary *dic = self.dataArray[i];
        if ([dic[kFunName] isEqualToString:@"contacts"]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            LoginViewCell *cell = ( LoginViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [self.contactsArray removeAllObjects];
            cell.detailLabel.text = [NSString stringWithFormat:@"total:%d current:%d",(int)self.contactsCount,(int)self.contactsArray.count];
            if (self.contactsCount == self.contactsArray.count) {
                cell.detailLabel.text = [NSString stringWithFormat:@"total:%d current:%d Cost:%0.1fms",(int)self.contactsCount,(int)self.contactsArray.count,([self.contactsDate  timeIntervalSinceNow]*-1000)];
            }
            break;
        }
    }
}
#pragma mark - user private data Subscription

-(IBAction)addUserPrivateData:(id)sender cell:(LoginViewCell *)cell
{
    self.userPrivateDataDate = [NSDate date];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contacts_added" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"users_changed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"user_accounts_added" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"userPrivateData_ready" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactsAdded:)
                                                 name:@"contacts_added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(usersChanged:)
                                                 name:@"users_changed"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userAccountsAdded:)
                                                 name:@"user_accounts_added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userPrivateDataReady:)
                                                 name:@"userPrivateData_ready"
                                               object:nil];
    
    [self.meteor addSubscription:@"userPrivateData" withParameters:nil];
    cell.detailLabel.text = @"";
    cell.timeLabel.text = [NSString stringWithFormat:@"Start:%@",[self.dateFormatter stringFromDate:self.userPrivateDataDate]];
}
-(void)usersChanged:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    
    if (note.userInfo)
    {
        serverData = note.userInfo;
    }
}
-(void)userAccountsAdded:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    
    if (note.userInfo)
    {
        serverData = note.userInfo;
    }
    self.account_id = serverData[@"_id"];
}
-(void)userPrivateDataReady:(NSNotification *)note
{
    self.privateDataTaped = NO;
    self.isPrivateDataReady = YES;
    for (int i = 0; i<[self.tableView numberOfRowsInSection:0]; i++) {
        NSDictionary *dic = self.dataArray[i];
        if ([dic[kFunName] isEqualToString:@"userPrivateData"]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            LoginViewCell *cell = ( LoginViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.detailLabel.text = [NSString stringWithFormat:@"Cost:%0.1fms",([self.userPrivateDataDate  timeIntervalSinceNow]*-1000)];
            break;
        }
    }

}
#pragma mark - Internal

- (void)handleFailedAuth:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Meteor" message:[error description] delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil] show];
}
#pragma mark <UITableViewDataSource>
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
#if 0
    static NSString *cellIdentifier = @"list";
#else
    NSString *cellIdentifier = [self.meteor description];
#endif
    LoginViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[LoginViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    NSDictionary *dic = self.dataArray[indexPath.row];
    cell.funName.text = dic[kFunName];
#if kAdvanceTest
    if ([cell.funName.text isEqualToString:@"topics"] || [cell.funName.text isEqualToString:@"archivedTopics"] || [cell.funName.text isEqualToString:@"contacts"] )
#else
    if ([cell.funName.text isEqualToString:@"topics"] || [cell.funName.text isEqualToString:@"archivedTopics"] )
#endif
    {
        cell.button.hidden = NO;
    } else {
        cell.button.hidden = YES;
    }
    cell.delegate = self;

    return cell;
}

#pragma mark <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    LoginViewCell *cell = (LoginViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *dic = self.dataArray[indexPath.row];
    if ([dic[kFunName] isEqualToString:@"getMuteKnotes"]) {
        [self getMuteKnotes:nil cell:cell];
    } else if ([dic[kFunName] isEqualToString:@"getPeople"]) {
        [self getPeople:nil cell:cell];
    } else if ([dic[kFunName] isEqualToString:@"getHotKnotes"]) {
        [self getHotKnotes:nil cell:cell];
    } else if ([dic[kFunName] isEqualToString:@"getPads"]) {
        [self getPads:nil cell:cell];
    } else if ([dic[kFunName] isEqualToString:@"topics"]) {
        if (self.isPrivateDataReady) {
            if (self.topicsTaped || ![self isMeteorAutoLogin]) {
                //            [self showAlertInfo:@"You have taped!!!"];
                return;
            }
            self.topicsTaped = YES;
            [self addSubTopics:nil cell:cell];
        } else {
            NSLog(@"userPrivateData need first download!!!!");
            [self showAlertInfo:@"userPrivateData need first download!!!!"];
        }
    } else if ([dic[kFunName] isEqualToString:@"archivedTopics"]) {
        if (self.isPrivateDataReady) {
            if (self.archivedTopicsTaped || ![self isMeteorAutoLogin]) {
                //            [self showAlertInfo:@"You have taped!!!"];
                return;
            }
            self.archivedTopicsTaped = YES;
            [self addSubArchivedTopics:nil cell:cell];
        } else {
            NSLog(@"userPrivateData need first download!!!!");
            [self showAlertInfo:@"userPrivateData need first download!!!!"];
        }
    } else if ([dic[kFunName] isEqualToString:@"contacts"]) {
        if (self.isPrivateDataReady) {
            if (self.contactsTaped || ![self isMeteorAutoLogin]) {
                //            [self showAlertInfo:@"You have taped!!!"];
                return;
            }
            self.contactsTaped = YES;
            [self addSubContacts:nil cell:cell];
        } else {
            NSLog(@"userPrivateData need first download!!!!");
            [self showAlertInfo:@"userPrivateData need first download!!!!"];
        }
    } else if ([dic[kFunName] isEqualToString:@"userPrivateData"]) {
        if (self.privateDataTaped || ![self isMeteorAutoLogin]) {
//            [self showAlertInfo:@"You have taped!!!"];
            return;
        }
        self.privateDataTaped = YES;
        [self addUserPrivateData:nil cell:cell];
    }else if ([dic[kFunName] isEqualToString:@"todo"]) {
        if (![self isMeteorAutoLogin]) {
            return;
        }
    }
}
#pragma mark LoginViewCellDelegate
-(void)detailButtonClicked:(LoginViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *dic = self.dataArray[indexPath.row];
 
    if ([dic[kFunName] isEqualToString:@"topics"]) {
        TopicsListViewController *vc = [[TopicsListViewController alloc] init];
        vc.meteor = self.meteor;
        vc.dataArray = self.topicsArray;
        [self.navigationController pushViewController:vc animated:YES];
    } else  if ([dic[kFunName] isEqualToString:@"archivedTopics"]) {
        TopicsListViewController *vc = [[TopicsListViewController alloc] init];
        vc.meteor = self.meteor;
        vc.dataArray = self.topicsArray;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([dic[kFunName] isEqualToString:@"contacts"]) {
        ContactsListViewController *vc = [[ContactsListViewController alloc] init];
        vc.meteor = self.meteor;
        vc.dataArray = self.contactsArray;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
-(BOOL)isMeteorAutoLogin
{
    return (self.meteor.connected && self.meteor.sessionToken);
}
-(void)showAlertInfo:(NSString *)str
{
    UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"" message:str delegate:nil cancelButtonTitle:@"SURE" otherButtonTitles: nil];
    [alert show];
}
@end
