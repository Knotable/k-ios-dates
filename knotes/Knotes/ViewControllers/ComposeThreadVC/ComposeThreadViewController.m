//
//  ComposeThreadViewController.m
//  Knotable
//
//  Created by backup on 13-12-20.
//
//

#import "ComposeThreadViewController.h"
#import "ThreadViewController.h"
#import "ShareListController.h"
#import "DataManager.h"
#import "AnalyticsManager.h"
#import "InputAccessViewManager.h"

#import "MessageEntity.h"
#import "AccountEntity.h"

#import "CItem.h"
#import "CDateItem.h"
#import "CVoteItem.h"

#import "NSString+Knotes.h"
#import "UIImage+Knotes.h"
#import "UIImage+Retina4.h"

#import "CUtil.h"
#import "KnoteNPMV.h"
#import "CEditVoteInfo.h"
#import "SVProgressHUD.h"
#import "ObjCMongoDB.h"
#import "ComposeExtendedNote.h"
#import "ComposeDate.h"
#import "ComposeVote.h"
#import "ComposeLock.h"
#import "ServerConfig.h"
#import "HybridDocument.h"

#import "TopicInfo.h"
#import "UIImage+FontAwesome.h"

#import "KnotesRichTextController.h"

NSString* lastComposeKey = @"last_compose";

@interface ComposeThreadViewController (KnoteNPMDelegate)<KnoteNPMDelegate>
@end

#define iOS7BlueColor [UIColor colorWithRed:0.0f green:0.49f blue:0.96f alpha:1.0f]

typedef void (^CompletionBlock)(BOOL isFinish, id userData);

@interface ComposeThreadViewController ()
<
UIAlertViewDelegate,
UITextFieldDelegate,
UIGestureRecognizerDelegate,
InputAccessViewManagerDelegate,
ShareListDelegateProtocol
>

@property (nonatomic, assign)   BOOL newPad;
@property (nonatomic, assign)   BOOL firstComming;
@property (nonatomic)           BOOL keynoteSelected;

@property (copy, nonatomic)     NSString *tempText;
//@property (copy, nonatomic)     NSString *title;
@property (nonatomic, strong)   NSString *previousTitle;
@property (nonatomic, strong)   NSMutableArray *sharingContacts;

@property (nonatomic, strong) UIToolbar *menuWithCamera;
@property (nonatomic, strong) UIToolbar *menuWithOutCamera;
@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UIBarButtonItem *voteItem;

@property (nonatomic, assign) CItemType itemType;
@property (nonatomic, strong) ComposeDate *cDate;
@property (nonatomic, strong) ComposeVote *cVote;
@property (nonatomic, strong) ComposeLock *cLock;
#if New_DrawerDesign
@property (nonatomic, strong) KnoteNPMV *knoteMenuView;
#endif
@property (nonatomic, strong) FileInfo *selectedInfo;
@property (strong, nonatomic) FileInfo *imageInfo;
@property (nonatomic) NSTimer* idleTimer;

@property (nonatomic) NSString* itemTitle;

//@property (strong, nonatomic) UITextField *textKnoteTitleField;

@property (strong, nonatomic) KnotableRichTextController *zssRichTextEditor;
@property (nonatomic) NSDictionary* composeData;

@end

@implementation ComposeThreadViewController
@synthesize currentView = _currentView;

#pragma mark ChildView Controller Handling 

-(CGRect) getFrameForRichTextEditor{

    return self.contentView.bounds;
}

- (void)addKnoteRichTextController:(KnotableRichTextController*)zssEditor{
    
//    //0. Remove the current Detail View Controller showed
//    if(self.zssRichTextEditor){
//        [self removeCurrentDetailViewController];
//    }
    
    //1. Add the detail controller as child of the container
    [self addChildViewController:zssEditor];
    
    //2. Define the detail controller's view size
    CGRect frame = [self getFrameForRichTextEditor];
    
    frame.size.height -= 45;
    
    frame.origin.x = 5;
    
    zssEditor.view.frame = frame;
    
    //3. Add the Detail controller's view to the Container's detail view and save a reference to the detail View Controller.
    [self.contentView addSubview:zssEditor.view];
    
    //4. Complete the add flow calling the function didMoveToParentViewController
    [zssEditor didMoveToParentViewController:self];
}

/*
- (void)removeCurrentDetailViewController{
    
    //1. Call the willMoveToParentViewController with nil
    //   This is the last method where your detailViewController can perform some operations before neing removed
    [self.currentDetailViewController willMoveToParentViewController:nil];
    
    //2. Remove the DetailViewController's view from the Container
    [self.currentDetailViewController.view removeFromSuperview];
    
    //3. Update the hierarchy"
    //   Automatically the method didMoveToParentViewController: will be called on the detailViewController)
    [self.currentDetailViewController removeFromParentViewController];
}
*/

#pragma mark - LifeCycle

- (id)init {
    self = [super init];
    
    if (self)
    {
        self.itemType = C_KNOTE;
        self.opType = ItemAdd;
        self.item = nil;
        
        self.keynoteSelected = NO;
        self.itemTitle = @"";
    }
    
    return self;
}

- (void)dealloc
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey: lastComposeKey];
    [defaults synchronize];
}

- (id)initForNewPad {
    self = [super init];
    
    if (self)
    {
        self.itemType = C_KNOTE;
        self.opType = ItemAdd;
        self.item = nil;
        self.newPad = YES;
        
        self.keynoteSelected = NO;
        self.itemTitle = @"";
    }
    
    return self;
}

- (id)initWithString:(NSString *)text {
    self = [super init];

    if (self) {
        self.itemType = C_KNOTE;
        self.opType = ItemAdd;
        self.item = nil;
        self.tempText = text;

        self.keynoteSelected = NO;
        self.itemTitle = @"";
    }
    return self;
}

- (id)initWithItemType:(int) type {
    self = [self init];
    if (self) {
        self.itemType = type;
        
        if (self.itemType == C_KEYKNOTE)
            self.keynoteSelected = YES;
        self.itemTitle = @"";
        
    }
    return self;
}

-(id)initWithItem:(CItem *)item {
    self = [super init];
    if (self) {
        self.item = item;
        self.itemType = item.type;
//		self.title = item.title;
        self.itemTitle = item.title;
        if (self.itemType == C_KEYKNOTE)
            self.keynoteSelected = YES;
        self.opType = ItemModify;
        [self.currentView setTitleContent:self.title];
        
    }
    return self;
}

- (id) initWithData: (NSDictionary*) data
{
    self = [super init];
    if (self) {
        self.composeData = data;
        NSString* typeStr = data[@"type"];
        int type = C_KNOTE;
        if ([typeStr isEqual: @"knote"])
        {
            type = C_KNOTE;
        }
        else if ([typeStr isEqual: @"messages_to_knote"])
        {
            type = C_MESSAGE;
        }
        else if ([typeStr isEqual:@"key_knote"])
        {
            type = C_KEYKNOTE;
        }
        else if ([typeStr isEqual: @"deadline"])
        {
            type = C_DATE;
        }
        else if ([typeStr isEqual: @"poll"])
        {
            type = C_VOTE;
        }
        else if ([typeStr isEqual:@"checklist"])
        {
            type = C_LIST;
        }
        else if ([typeStr isEqual: @"lock"])
        {
            type = C_LOCK;
        }
        
        self.itemType = type;
        
        if (self.itemType == C_KEYKNOTE)
            self.keynoteSelected = YES;
        
        self.itemTitle = data[@"title"];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    UIWindow *wn=[[UIApplication sharedApplication] keyWindow];
    for (int i=0; i<wn.subviews.count; i++)
    {
        UIView *ne=wn.subviews[i];
        if ([ne isKindOfClass:[UPStackMenu class]])
        {
            [ne removeFromSuperview];
            ne=nil;
        }
    }

    self.firstComming = YES;
    self.wasFirstKeyboardDisplayed=YES;
    CGFloat segmentHeight = 0;
 
    CGRect rect = self.contentView.frame;
    
    rect.origin.y += kNavigationBarH + kStatusbarH + segmentHeight;
    rect.size.height -= kNavigationBarH + kStatusbarH + 44.0f;
    
    //self.contentView.backgroundColor = [UIColor brownColor];
    
    self.contentView.frame =rect;

    if (self.newPad)
    {
        UIButton *peopleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [peopleBtn addTarget:self action:@selector(showShareList) forControlEvents:UIControlEventTouchUpInside];
        [peopleBtn setImage:[UIImage imageNamed:@"person-icon-gray"] forState:UIControlStateNormal];
        
        peopleBtn.frame = CGRectMake(0, 0, 40, 40);
        
        _sharingContacts = [[NSMutableArray alloc] init];

        if([DataManager sharedInstance].currentAccount.user.contact)
        {
            [_sharingContacts addObject:[DataManager sharedInstance].currentAccount.user.contact];
        }
        
        if(self.current_contact && ![_sharingContacts containsObject:self.current_contact])
        {
            [_sharingContacts addObject:self.current_contact];
        }
        
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPost)];
        self.navigationItem.leftBarButtonItem = cancel;
    }
    
    self.navigationController.toolbar.hidden = NO;
    [self setTopAndBottomBarDesign];
    if (self.opType == ItemAdd)
    {
#if 0
        segmentHeight = kSegmentBarH;
        
        if (!_selectControl)
        {
            NSArray *toolbarItems = @[
                                      @{@"icon":@"text-knote"},
                                      @{@"icon":@"date-knote"},
                                      @{@"icon":@"list-knote"},
                                      @{@"icon":@"vote-knote"},
                                      ];
        }
#else

#if New_DrawerDesign
        
        //[self setTopAndBottomBarDesign];
        
#endif
        
        // Lin - Ended
        
#endif
    }
    
    switch (self.itemLifeCycleStage)
    {
        case ItemSwapEditing:
        {
            self.navigationItem.leftBarButtonItem = [self getBackButton];
            break;
        }
            
        default:
            break;
    }
    
//    if (self.textKnoteTitleField == nil) {
//        
//        self.textKnoteTitleField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, 290, 40)];
//        
//        self.textKnoteTitleField.delegate = self;
////       self.textKnoteTitleField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
//        //self.textKnoteTitleField.backgroundColor = [UIColor orangeColor];
//        
//        //Adding Bottom border in UITextField
//        
//        CALayer *border = [CALayer layer];
//        CGFloat borderWidth = 1;
//        border.borderColor = [UIColor lightGrayColor].CGColor;
//        border.frame = CGRectMake(0, self.textKnoteTitleField.frame.size.height - borderWidth, self.textKnoteTitleField.frame.size.width, self.textKnoteTitleField.frame.size.height);
//        border.borderWidth = borderWidth;
//        [self.textKnoteTitleField.layer addSublayer:border];
//    }
//    
    [self changeTitle];
    
    [AppDelegate sharedDelegate].firstIn = NO;
    
    if ([self.menuWithCamera superview] && [self.menuWithOutCamera superview]) {
        
        [self.menuWithOutCamera mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@44);
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
        
        [self.menuWithCamera mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@44);
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    }
    
    [self addSwipeGestureRecognizer];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /*********Navigation Bar changes as per New Design************/
    NSDictionary *navBarTitleAttr =[NSDictionary dictionaryWithObjectsAndKeys:
                                    [DesignManager knoteTitleFont],NSFontAttributeName,
                                    [UIColor colorWithWhite:0.447 alpha:1.000], NSForegroundColorAttributeName, nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes: navBarTitleAttr];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
        /*for iOS 7 and newer*/
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:1.000 green:1.000 blue:0.996 alpha:1.000]];
    }
    else
    {
        /*for older versions than iOS 7*/
        [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:1.000 green:1.000 blue:0.996 alpha:1.000]];
    }
    
    [(KnotableNavigationController *)self.navigationController navBorder].hidden=YES;
    self.navigationController.navigationBarHidden = NO;

    /*********************/
    [InputAccessViewManager sharedInstance].delegate = self;
    
    if (self.itemType == C_KNOTE)
    {
//      [self.contentView addSubview:_currentView];
        self.currentView = (ComposeView *)self.cNewNote;
        [self.contentView bringSubviewToFront:self.zssRichTextEditor.view];
        
        [self.zssRichTextEditor focusTextEditor];
        
//        [self.textKnoteTitleField becomeFirstResponder];
    }
    
    /*navigation back button added*/
    
//    self.navigationItem.hidesBackButton = YES;
    
    /*--navigationback button added*/
    
    self.idleTimer = [NSTimer scheduledTimerWithTimeInterval: 2
                                                      target: self
                                                    selector: @selector(backupCurrentEdit)
                                                    userInfo: nil
                                                     repeats: YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.opType ==ItemModify)
    {
        [self UnsetCurrentlyEditing];
    }
    [InputAccessViewManager sharedInstance].delegate = nil;
    
    if (self.itemType == C_KNOTE)
    {
        [self.currentView removeFromSuperview];
    }
    
    [self.idleTimer invalidate];
    self.idleTimer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SwipeGesture
-(void)addSwipeGestureRecognizer {
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    if ([self.currentView isKindOfClass: [ComposeNewNote class]])
    {// for webview gesture.
        recognizer.delegate = self;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    return YES;
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer*)recognizer {
    [self.navigationController popViewControllerAnimated: YES];
    recognizer.delegate = nil;
}

#pragma mark - Methods

-(NSString *) stringByStrippingHTML:(NSString*)htmlString {
    NSRange r;
    NSString *s = [htmlString copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

-(UIBarButtonItem *)getBackButton {
    UIImage *backImage = [UIImage imageWithIcon:@"fa-angle-left" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithWhite:0.447 alpha:1.000]/*[UIColor whiteColor]*/ andSize:CGSizeMake(30, 30)];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);

    [backButton addTarget:self
                   action:@selector(ComposePopBack)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    return backButtonItem;
}

-(UIBarButtonItem *)getPostButton {
    UIButton *postBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    postBtn.frame = CGRectMake(0,0,42,25);
    [postBtn setTitleColor:[UIColor colorWithWhite:0.447 alpha:1.000] forState:UIControlStateNormal];
    [postBtn setTitle:@"Post" forState:UIControlStateNormal];
    [postBtn addTarget:self action:@selector(postButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *postBtnItem = [[UIBarButtonItem alloc] initWithCustomView:postBtn];
    
    return postBtnItem;
}

-(UIBarButtonItem *)getCameraAndPostButton {
    int spaceBetweenCameraAndPost = 12;
    
    UIImage *cameraImage = [UIImage imageWithIcon:@"fa-camera" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithWhite:0.447 alpha:1.000]/*[UIColor whiteColor]*/ andSize:CGSizeMake(24, 22)];

    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setImage:cameraImage forState:UIControlStateNormal];
    [cameraButton setFrame:CGRectMake(0, 0, cameraImage.size.width, cameraImage.size.height)];
    [cameraButton addTarget:self
                     action:@selector(cameraButtonClicked)
           forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *postBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    postBtn.frame = CGRectMake(cameraButton.frame.size.width + spaceBetweenCameraAndPost,0,42,cameraImage.size.height); // 42 25
    [postBtn setTitleColor:[UIColor colorWithWhite:0.447 alpha:1.000]/*[UIColor whiteColor]*/ forState:UIControlStateNormal];
    [postBtn setTitle:@"Post" forState:UIControlStateNormal];
    [postBtn addTarget:self action:@selector(postButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect unionRect = CGRectUnion(cameraButton.frame, postBtn.frame);
    UIView *cameraAndPostView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, unionRect.size.width, unionRect.size.height)];
    
    [cameraAndPostView addSubview:cameraButton];
    [cameraAndPostView addSubview:postBtn];
    UIBarButtonItem *cameraButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cameraAndPostView];
    
    return cameraButtonItem;
}

-(void)toolbarWithCameraVisibility:(BOOL)visibility {
    self.menuWithCamera.hidden = !visibility;
}

-(void)toolbarWithOutCameraVisibility:(BOOL)visibility {
    self.menuWithOutCamera.hidden = !visibility;
}

-(void)setTopAndBottomBarDesign{
    
    switch (self.itemLifeCycleStage) {
            
        case ItemNew:
        {
            if (!_knoteMenuView)
            {
                self.knoteMenuView = [[KnoteNPMV alloc] init];
                self.knoteMenuView.targetDelegate = self;
            }
            
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_knoteMenuView];
            
            [_knoteMenuView.m_btnText setBackgroundImage:[UIImage imageNamed:@"text_knote_selected"] forState:UIControlStateNormal];
        
//{ Adding Back button (X) for New Pads @Malik
            
            UIImage *backImage = [UIImage imageNamed:@"close_padWhite.png"];
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [backButton setImage:backImage forState:UIControlStateNormal];
            [backButton setFrame:CGRectMake(0, 0, 35, 35 )];
            [backButton addTarget:self
                           action:@selector(ComposePopBack)
                 forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
            self.navigationItem.rightBarButtonItem = backButtonItem;
//}

            self.menuWithCamera = [[InputAccessViewManager sharedInstance] inputAccessViewWithCameraDup];
            self.menuWithOutCamera = [[InputAccessViewManager sharedInstance] inputAccessViewWithOutCameraDup];
            
            [self.view addSubview:self.menuWithCamera];
            [self.view bringSubviewToFront:self.menuWithCamera];
            [self.view addSubview:self.menuWithOutCamera];
            [self.view bringSubviewToFront:self.menuWithOutCamera];
            
            [self toolbarWithCameraVisibility:YES];
            [self toolbarWithOutCameraVisibility:NO];
            
            self.itemType = C_KNOTE; //This is default overided type SET ??
            
            break;
        }
            
        case ItemExisting: {
            
            _knoteMenuView.hidden = YES;
            
            [self.menuWithCamera removeFromSuperview];
            [self.menuWithOutCamera removeFromSuperview];
            
//            self.navigationItem.leftBarButtonItem = [self getBackButton];
            
            switch (self.itemType) {
                    
                case C_KNOTE:{
                    NSLog(@" i m C_KNOTE ");
                    self.navigationItem.rightBarButtonItem = [self getCameraAndPostButton];
                    break;
                }
                    
                case C_DATE:{
                    NSLog(@" i m C_DATE ");
                    self.itemType = C_DATE;
                    self.navigationItem.rightBarButtonItem = [self getPostButton];
                    break;
                }
                    
                case C_VOTE:{
                    
                    NSLog(@" i m C_VOTE ");
                    self.itemType = C_VOTE;
                    self.navigationItem.rightBarButtonItem = [self getPostButton];
                    break;
                }
                    
                case C_LIST:{
                    NSLog(@" i m C_LIST ");
                    self.itemType = C_LIST;
                    self.navigationItem.rightBarButtonItem = [self getPostButton];
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        
        }
            
        default:
            _knoteMenuView.hidden = YES;
            
            [self.menuWithCamera removeFromSuperview];
            [self.menuWithOutCamera removeFromSuperview];
            
            self.navigationItem.leftBarButtonItem = [self getBackButton];
            
            switch (self.itemType) {
                    
                case C_KNOTE:{
                    NSLog(@" i m C_KNOTE ");
                    self.navigationItem.rightBarButtonItem = [self getCameraAndPostButton];
                    break;
                }
                    
                case C_DATE:{
                    NSLog(@" i m C_DATE ");
                    self.itemType = C_DATE;
                    self.navigationItem.rightBarButtonItem = [self getPostButton];
                    break;
                }
                    
                case C_VOTE:{
                    
                    NSLog(@" i m C_VOTE ");
                    self.itemType = C_VOTE;
                    self.navigationItem.rightBarButtonItem = [self getPostButton];
                    break;
                }
                    
                case C_LIST:{
                    NSLog(@" i m C_LIST ");
                    self.itemType = C_LIST;
                    self.navigationItem.rightBarButtonItem = [self getPostButton];
                    break;
                }
                    
                default:
                    break;
            }

            break;
    }
    
}

- (void) cancelPost {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)textItemSelected {
#if New_DrawerDesign
    [_knoteMenuView.m_btnText setBackgroundImage:[UIImage imageNamed:@"text_knote_selected"] forState:UIControlStateNormal];
    [_knoteMenuView.m_btnDeadline setBackgroundImage:[UIImage imageNamed:@"deadline_knote_normal"] forState:UIControlStateNormal];
    [_knoteMenuView.m_btnChecklist setBackgroundImage:[UIImage imageNamed:@"checklist_knote_normal"] forState:UIControlStateNormal];
    [_knoteMenuView.m_btnVote setBackgroundImage:[UIImage imageNamed:@"vote_knote_normal"] forState:UIControlStateNormal];
#endif
    self.itemType = C_KNOTE;

    [self changeTitle];
}

-(void)deadlineItemSelected {
#if New_DrawerDesign
    [_knoteMenuView.m_btnText setBackgroundImage:[UIImage imageNamed:@"text_knote_normal"] forState:UIControlStateNormal];
    [_knoteMenuView.m_btnDeadline setBackgroundImage:[UIImage imageNamed:@"deadline_knote_selected"] forState:UIControlStateNormal];
    [_knoteMenuView.m_btnChecklist setBackgroundImage:[UIImage imageNamed:@"checklist_knote_normal"] forState:UIControlStateNormal];
    [_knoteMenuView.m_btnVote setBackgroundImage:[UIImage imageNamed:@"vote_knote_normal"] forState:UIControlStateNormal];
#endif
    self.itemType = C_DATE;
    [self changeTitle];
}

-(void)checklistItemSelected {
#if New_DrawerDesign
    [_knoteMenuView.m_btnText setBackgroundImage:[UIImage imageNamed:@"text_knote_normal"] forState:UIControlStateNormal];
    [_knoteMenuView.m_btnDeadline setBackgroundImage:[UIImage imageNamed:@"deadline_knote_normal"] forState:UIControlStateNormal];
    [_knoteMenuView.m_btnChecklist setBackgroundImage:[UIImage imageNamed:@"checklist_knote_selected"] forState:UIControlStateNormal];
    [_knoteMenuView.m_btnVote setBackgroundImage:[UIImage imageNamed:@"vote_knote_normal"] forState:UIControlStateNormal];
#endif
    self.itemType = C_LIST;
    [self changeTitle];
}

-(void)voteItemSelected {
#if New_DrawerDesign
    [_knoteMenuView.m_btnText setBackgroundImage:[UIImage imageNamed:@"text_knote_normal"] forState:UIControlStateNormal];
    [_knoteMenuView.m_btnDeadline setBackgroundImage:[UIImage imageNamed:@"deadline_knote_normal"] forState:UIControlStateNormal];
    [_knoteMenuView.m_btnChecklist setBackgroundImage:[UIImage imageNamed:@"checklist_knote_normal"] forState:UIControlStateNormal];
    [_knoteMenuView.m_btnVote setBackgroundImage:[UIImage imageNamed:@"vote_knote_selected"] forState:UIControlStateNormal];
#endif
    self.itemType = C_VOTE;
    [self changeTitle];
}

- (void)showShareList {
    ShareListController *shareList = [[ShareListController alloc] initWithTopic:nil loginUser:[DataManager sharedInstance].currentAccount.user sharedContacts:_sharingContacts];
    
    shareList.delegate = self;
    
    [self.navigationController pushViewController:shareList animated:YES];
}

- (void)sharingWithContacts:(NSArray *)contacts {
    NSLog(@"sharing with contacts start: %@", contacts);
    
    NSMutableArray *mArray = [contacts mutableCopy];
    
    if([DataManager sharedInstance].currentAccount.user.contact
       && ![mArray containsObject:[DataManager sharedInstance].currentAccount.user.contact])
    {
        [mArray addObject:[DataManager sharedInstance].currentAccount.user.contact];
    }
    
    self.sharingContacts = mArray;
    self.cNewNote.userIds = mArray;
    
    NSLog(@"sharing with contacts end: %@", mArray);
}

- (void) ComposePopBack {
    if(self.shouldPopToMainView){
//        for(UIViewController * vc in self.navigationController.viewControllers){
//            if([vc canPerformAction:@selector(startAddTopic:) withSender:nil]){
//                //Dhruv : it causes delete pad
////                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
////                [userDefault setObject:self.topic_id forKey:@"auto_padID_to_remove"];
////                [userDefault synchronize];
//                
//                [self.navigationController popToViewController:vc animated:YES];
//                break;
//            }
//        }
        [self.navigationController popViewControllerAnimated: YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)UnsetCurrentlyEditing {
    NSMutableArray *changedKnotes = [[NSMutableArray alloc] init];
    
    MessageEntity *message = self.item.userData;
    
    [changedKnotes addObject:message];
    
    [[AppDelegate sharedDelegate] sendUpdatedKnoteUnsetCurrentlyEditing:[changedKnotes copy]];
    
    [AppDelegate saveContext];
}

-(void)setCurrentView:(ComposeView *)currentView {
    
    if (_currentView!=currentView)
    {
        [_currentView removeFromSuperview];
        _currentView  = currentView;
        [currentView updateConstraints];
    }
    
    _currentView.opType = self.opType;
    
    if (self.itemType == C_KNOTE || self.itemType == C_MESSAGE)
    {
        [self.contentView addSubview:currentView];
        
    }else
    {
        [self.contentView addSubview:currentView];
    }
}

- (void)changeTitle
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    rect.origin.y =   kVGap;
    rect.size.height = self.contentView.bounds.size.height - 2*kVGap;
    rect.origin.x += kHGap;
    rect.size.width -= 2*kHGap;

//    SEL buttonSelector = @selector(postData);
//    
//    if (self.itemType == C_LOCK)
//    {
//    }
//    else  if (self.itemType == C_VOTE || self.itemType == C_LIST)
//    {
//        buttonSelector = @selector(postDataForTask);
//    }
    
    NSString *placeHolder = nil;
    NSString *titleContent = nil;
    
    switch (self.itemType)
    {
        case C_KNOTE:
        case C_MESSAGE:
        {
//            CGRect contentViewFrame = self.contentView.frame;
//            CGRect textKnoteTitleViewFrame = self.textKnoteTitleField.frame;
            
//            textKnoteTitleViewFrame.origin.y = contentViewFrame.origin.y;
//            self.textKnoteTitleField.frame = textKnoteTitleViewFrame;
//            [self.view addSubview:self.textKnoteTitleField];
            
//            contentViewFrame.origin.y += kTextKnoteTitleHeight;
//            contentViewFrame.size.height -= kTextKnoteTitleHeight;
//            self.contentView.frame = contentViewFrame;
            
            if (!self.cNewNote)
            {
                self.zssRichTextEditor = [[KnotableRichTextController alloc] init];
                ComposeExtendedNote *note = [[ComposeExtendedNote alloc] initWithFrame:rect];
                note.keynoteSelected = NO;
                self.cNewNote = note;
                self.cNewNote.delegate = self;
                self.cNewNote.richTextView = self.zssRichTextEditor;
            }

            if (self.tempText)
            {
                titleContent = self.tempText;

            }
            else if ([AppDelegate sharedDelegate].needUseClipBoard)
            {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                
                if ([pasteboard.string length]>0)
                {
                    titleContent = [pasteboard.string copy];
                }
            }
            
            self.currentView = (ComposeView *)self.cNewNote;
            
            //self.currentView.backgroundColor = [UIColor blueColor];
            
            [self.currentView setTitleContent:self.title];
            
            [self addKnoteRichTextController:self.zssRichTextEditor];
            
            [self.contentView bringSubviewToFront:self.zssRichTextEditor.view];
            
//            [self loadLastContent];

            if (self.opType == ItemModify)
            {
//                NSString *textKnoteTitle = self.title;
//                
//                textKnoteTitle = [textKnoteTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                
//                if (textKnoteTitle.length > 0) {
//                    
//                    self.textKnoteTitleField.text = textKnoteTitle;
//                }
//                else{
//                    self.textKnoteTitleField.text = @"";
//                }
                
                if (self.item.userData.documentHTML.length > 0) {
                    
                    //Its Fine to use HTML document.
                }
                else{
                    
                    self.item.userData.documentHTML = @"";
                }
                
                NSMutableArray *imageInfos = [[NSMutableArray alloc] initWithCapacity:3];
                
                for (FileInfo *fInfo in [self.item files])
                {
                    FileEntity *file = [FileEntity MR_findFirstByAttribute:@"file_id" withValue:fInfo.imageId];
                    
                    if (file)
                    {
                        NSString *file_id = [[file.full_url componentsSeparatedByString:@"/"] lastObject];
                        
                        NSString * filePath = @"";
                        if(file_id.length > 0){
                            filePath = [kImageCachePath stringByAppendingPathComponent:file_id];
                        }
                        
                        
                        if (file_id && [[NSFileManager defaultManager] fileExistsAtPath:filePath])
                        {
                            fInfo.image = [UIImage imageWithContentsOfFile:filePath];
                            [imageInfos addObject:fInfo];
                        }
                    }
                }
                
                [self.currentView setCotent:imageInfos];
                [self.cNewNote.titleTextField setText:self.title];
                
            }
        }
            break;
            
        case C_KEYKNOTE:
        {
            ComposeExtendedNote *note = [[ComposeExtendedNote alloc] initWithFrame:rect];
            note.keynoteSelected = YES;
            self.cNewNote = note;

            self.cNewNote.delegate = self;
            
            self.currentView = (ComposeView *)self.cNewNote;
            [self.currentView setTitleContent:self.title];
            
            if (self.opType == ItemModify)
            {
                titleContent = self.item.body;
            }
            
            NSLog(@"%@",[self.cNewNote getTitle]);
            
            if (![self.currentView getTitle]||[[self.currentView getTitle] length]<=0)
            {
                if (self.keyItem)
                {
                    titleContent = self.keyItem.body;
                }
                
                NSMutableArray *imageInfos = [[NSMutableArray alloc] initWithCapacity:3];
                
                for (FileInfo *fInfo in [self.item files])
                {
                    FileEntity *file = [FileEntity MR_findFirstByAttribute:@"file_id" withValue:fInfo.imageId];
                    
                    if (file)
                    {
                        NSString *file_id = [[file.full_url componentsSeparatedByString:@"/"] lastObject];
                        
                        NSString * filePath = @"";
                        if(file_id.length > 0){
                            filePath = [kImageCachePath stringByAppendingPathComponent:file_id];
                        }
                        
                        if (file_id && [[NSFileManager defaultManager] fileExistsAtPath:filePath])
                        {
                            fInfo.image = [UIImage imageWithContentsOfFile:filePath];
                            [imageInfos addObject:fInfo];
                        }
                    }
                }
                
                [self.currentView setCotent:imageInfos];
            }
        }
            break;
            
        case C_DATE:
        {
            if (!self.cDate)
            {
                self.cDate = [[ComposeDate alloc] initWithFrame:rect];
                
                [self.cDate setCotent:[NSDate date]];//set default is current date
            }
            
            self.currentView = (ComposeView *)self.cDate;
            [self.currentView setTitleContent:self.title];
            
            placeHolder = @"Date";
            
            if (self.opType == ItemModify)
            {
                titleContent = self.item.body;
                
                [self.cDate setCotent:[(CDateItem *)self.item deadline]];
            }
        }
            break;
        case C_LIST:
        {
            if (!self.cVote)
            {
                self.cVote = [[ComposeVote alloc] initWithFrame:rect];
                
                self.cVote.lifeCycle = self.itemLifeCycleStage;
                
                NSLog(@"List Region :  %@", NSStringFromCGRect(rect));
                
                CEditVoteInfo* info = [[CEditVoteInfo alloc] init];
                
                info.editor = YES;
                
                if (!info.name)
                {
                    info.name = @"";
                }
                
                [self.cVote.itemArray addObject:info];

            }
            
            self.currentView = (ComposeView *)self.cVote;
            [self.currentView setTitleContent:self.title];
            
            placeHolder = @"List";
            
            if (self.opType == ItemModify)
            {
                titleContent = self.item.body;
                self.cVote.itemArray = [[(CVoteItem *)self.item voteList] mutableCopy];

            }

        }
            break;
        case C_VOTE:
        {
            if (!self.cVote)
            {
                self.cVote = [[ComposeVote alloc] initWithFrame:rect];
                
                self.cVote.lifeCycle = self.itemLifeCycleStage;
                
                CEditVoteInfo* info = [[CEditVoteInfo alloc] init];
                
                info.editor = YES;
                
                if (!info.name)
                {
                    info.name = @"";
                }
                
                [self.cVote.itemArray addObject:info];

            }
            
            self.currentView = (ComposeView *)self.cVote;
            [self.currentView setTitleContent:self.title];
            
            placeHolder = @"Vote";
            
            if (self.opType == ItemModify)
            {
                titleContent = self.item.body;
                
                self.cVote.itemArray = [[(CVoteItem *)self.item voteList] mutableCopy];
            }
        }
            break;

        case C_LOCK:
        {
            if (!self.cLock) {
                self.cLock = [[ComposeLock alloc] initWithFrame:rect];
            }
            
            self.currentView = (ComposeView *)self.cLock;
            if (self.opType == ItemModify) {
                titleContent = self.item.body;
            }
        }
            break;
        default:
            break;
    }
    
	// Do any additional setup after loading the view.
    
    NSString* documentHTML = nil;
    
    if (self.item && self.item.userData && self.item.userData.documentHTML)
    {
        documentHTML = self.item.userData.documentHTML;
    }
    else if (self.composeData)
    {
        documentHTML = self.composeData[@"htmlBody"];
    }
    
    if (documentHTML != nil)
    {
//        [self.currentView setDocument:[[HybridDocument alloc] initWithHTML: documentHTML]];
        NSString* title = self.itemTitle;
        if (title.length > 0)
        {
            documentHTML = [NSString stringWithFormat: @"<p>%@</p>%@", title, documentHTML];
        }
        [self.currentView setDocument:[[HybridDocument alloc] initWithHTML: documentHTML]];
    }
    else
    {
        //NSLog(@"STARTING WITH titleContent: %@", titleContent);
        [self.currentView setTitleContent:titleContent];
        
        // Lin - Added to fix Yan's crash issue
        
        if (titleContent)
        {
            // Yan added this code, but crashing when trying to add new knote from
            // new Pad.
            
            if ([self.currentView respondsToSelector:@selector(setDocument:)]) {
                [self.currentView setDocument:[[HybridDocument alloc] initWithHTML:titleContent]];
            }
            
            // Ended -- : Marked by Lin
        }
        
        // Lin - Ended
        
        [self.currentView setTitlePlaceHold:placeHolder];
    }
    
    if ((self.itemType == C_DATE || self.itemType == C_LIST || self.itemType == C_VOTE) && self.itemLifeCycleStage == ItemNew)
    {
        [self.currentView becomeFirstResponder];
    }
    
//    if ((self.itemType == C_KNOTE && self.itemLifeCycleStage == ItemNew) || (self.itemType == C_KNOTE && self.itemLifeCycleStage == ItemExisting))
//    {
//        [self.textKnoteTitleField becomeFirstResponder];
//    }
//    else
//    {
//        self.firstComming = NO;
//    }
//    
//    self.navigationItem.title = @" ";
//    self.navigationItem.titleView = nil;
}

-(void)postDataForTask {
    [self postData];
}

- (void)postData {
    if (self.newPad || self.topic_id.length == 0) {
        [self createNoteInNewPad];
    } else {
        [self addNoteToExistingPad];
    }
}

- (void)createNoteInNewPad {
    self.shouldPopToMainView = NO;
    [self createPad];
}

- (void)createPad {
    ThreadViewController *threadViewController = nil;
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[ThreadViewController class]]) {
            threadViewController = (ThreadViewController *)viewController;
        }
    }
        
    NSString *newPadTitle = [TopicInfo defaultName];//defaultTopicName;//[[TopicManager sharedInstance] generateNewTopicTitle];
    [[TopicManager sharedInstance] generateNewTopic:newPadTitle account:[DataManager sharedInstance].currentAccount sharedContacts:@[] andBeingAutocreated:YES withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
        TopicInfo *topicInfo = (TopicInfo *)userData;
        self.topic_id = topicInfo.topic_id;
        [threadViewController newTopicCreatedFromComposeView:topicInfo];
        
        [[TopicManager sharedInstance] recordTopicToServer:topicInfo withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData, id userData2) {
            NSString *newTopicId = userData;
            self.topic_id = newTopicId;
        }];
        
        [self addNoteToNewPad];
     }];
}

- (void)addNoteToNewPad {
    self.shouldPopToMainView = NO;

    NSMutableDictionary *postDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    NSString *typeStr = @"";
    NSString *body    = @"";
    NSString *cname   = @"knotes";
    NSString *title   = [self.currentView getTitle];
    
    if (self.currentView.document && self.item && self.item.userData) {
        self.item.userData.documentHTML = self.currentView.document.documentHTML;
        self.item.userData.documentHash = [self.currentView.document.documentHTML md5];
        
        self.item.body = self.currentView.document.text;
        self.item.userData.body = self.item.body;
    }
    
    id content = [self.currentView getCotent];
    
    if ((!title || [title length] == 0) && self.currentView.imageArray.count==0) {
        if (self.itemType == C_LIST) {
            title = @"List";
        } else {
            [self ComposePopBack];
            return;
        }
    }
    
    NSMutableArray *file_ids = nil;
    
    if ([self.currentView.imageArray count] > 0)
    {
        file_ids = [[NSMutableArray alloc] init];
        
        for (FileInfo *finfo in self.currentView.imageArray) {
            [file_ids addObject:finfo.imageId];
        }
        
        [postDic setObject:[file_ids copy] forKey:@"file_ids"];
    }
    
    switch (self.itemType) {
        case C_MESSAGE:
            
        case C_KNOTE: {
            
            typeStr = @"knote";
            if (self.itemType == C_MESSAGE) {
                typeStr = @"messages_to_knote";
            }
            
            body = [((ComposeNewNote *)self.currentView) getBody];

//            NSArray * auxArr = [body componentsSeparatedByString:@"<div>"];
//            
//            NSString * auxTitle = [auxArr objectAtIndex:0];
//            
//            NSString *tempTitle = [auxTitle copy];
//            
//            tempTitle = [self stringByStrippingHTML:tempTitle];
//            
//            int titleCharactersCount = tempTitle.length;
            
            // Titles can't be more than 150 Charcters.
            
//            if (titleCharactersCount > 150)
//            {
//                NSRange allowedTitleRange = NSMakeRange(0, 150);
//                tempTitle = [tempTitle substringWithRange:allowedTitleRange];
//                NSMutableArray *tempTitleWords = (NSMutableArray*)[tempTitle componentsSeparatedByString:@" "];
//                [tempTitleWords removeLastObject];
//                auxTitle = [tempTitleWords componentsJoinedByString:@" "];
//            }
//            
//            if (!auxTitle) {
//                auxTitle = [auxArr objectAtIndex:1];
//                
//                if (auxTitle.length > 0){
//                    auxTitle = [auxTitle stringByReplacingOccurrencesOfString:@"</div>" withString:@""];
//                }
//            }
//            
//            if(body.length > 0){
//                
//                body = [body stringByReplacingOccurrencesOfString:auxTitle
//                                                       withString:@""];
//            }
//            
//            auxTitle = [auxTitle stringByReplacingOccurrencesOfString:@"</u>"
//                                                           withString:@"</u> "];
//            
//            auxTitle = [self stringByStrippingHTML:auxTitle];
            
//            NSString *textKnoteTitle = self.textKnoteTitleField.text;
//            
//            textKnoteTitle = [textKnoteTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//            
//            if (textKnoteTitle.length > 0) {
//                
//                [postDic setObject:textKnoteTitle forKey:@"title"];
//            }
//            else{
//            
//                [postDic setObject:textKnoteTitle forKey:@""];
//            }
            
//          NSRange range = [body rangeOfString:auxTitle];
//          if ((body.length > 0) && (range.location != NSNotFound) ) {
//              body = [body stringByReplacingOccurrencesOfString:auxTitle withString:@"" options:NSLiteralSearch range:range];
//          }
            
            if (self.opType == ItemAdd) {
                body = [MessageEntity wrapTextInHTML:body];
            }
            
            if (file_ids && [file_ids count] > 0) {
                NSString *thumbnailStart =@"<p><div class=\"thumbnail-wrapper thumbnail3 uploading-thumb";
                NSRange range =   [body rangeOfString:thumbnailStart];
                
                if (range.location != NSNotFound) {
                    range =   [body rangeOfString:@"<div class=\"thumbnail-wrapper thumbnail3 uploading-thumb"];
                }
                
                if (range.location != NSNotFound) {
                    range.length = range.location;
                    range.location = 0;
                    body= [body substringWithRange:range];
                }
                
                NSMutableString * output = [NSMutableString new];
                [output appendString:@"<p>"];
                [MessageEntity addThumbnailsHTMLto:output forFileIDS:file_ids];
                [output appendString:@"</p>"];
                body = [body stringByAppendingString:output];
            }
            
            [postDic setObject:body forKey:@"htmlBody"];
            [postDic setObject:body forKey:@"body"];
            
            NSMutableArray *userTagsArray = [(ComposeNewNote *)self.currentView getUsertags];
            if (userTagsArray && userTagsArray.count>0) {
                [postDic setObject:userTagsArray forKey:@"usertags"];
            }
            if (self.opType == ItemModify) {
                [postDic setObject:self.item.itemId forKey:@"_id"];
            }
        }
            break;
            
        case C_KEYKNOTE: {
            typeStr = @"key_knote";
            cname   = @"key_notes";
            body    = title;
            [postDic setObject:body forKey:@"note"];
            if (self.opType == ItemModify) {
                [postDic setObject:self.item.itemId forKey:@"_id"];
                MessageEntity *message = self.item.userData;
                if (message.liked_account_ids != nil) {
                    NSArray *likedUsers = [message.liked_account_ids componentsSeparatedByString:@","];
                    [postDic setObject:likedUsers forKey:@"liked_account_ids"];
                }
            }
        }
            break;
            
        case C_DATE: {
            
            typeStr = @"deadline";
            NSDate *deadline = (NSDate *)content;
            
            [postDic setObject:title forKey:@"deadline_subject"];
            [postDic setObject:deadline forKey:@"deadline"];
            
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
            
            format.dateFormat =kCtlDateFormat;
            [format setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            
            [postDic setObject:[format stringFromDate:deadline] forKey:@"local_deadline"];//Tue Nov 26 14:19:00 2013
            
            if (self.opType == ItemModify) {
                [postDic setObject:self.item.itemId forKey:@"_id"];
            }
        }
            break;
            
        case C_VOTE: {
            typeStr = @"poll";
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:3];
            NSArray *voteArray = content;
            NSInteger num = 1;
            for (int i = 0 ; i< [voteArray count]; i++) {
                CEditVoteInfo *info = [voteArray objectAtIndex:i];
                if (info.name && [info.name length]>0) {
                    info.num = num++;
                    [array addObject:[info dictionary]];
                }
            }
            if (!array || [array count]<2) {
                [SVProgressHUD showErrorWithStatus:@"Enter at least two items" duration:3];
                return;
            }
            [postDic setObject:array forKey:@"options"];
            [postDic setObject:title forKey:@"title"];//title
            if (!self.subject || self.subject.length<1)
            {
                self.subject = @"Untitled";
            }
            [postDic setObject:self.subject forKey:@"message_subject"];
            [postDic setObject:[NSArray array] forKey:@"voted"];
            if (self.opType == ItemModify) {
                [postDic setObject:self.item.itemId forKey:@"_id"];
            }
        }
            break;
            
        case C_LIST: {
            typeStr = @"checklist";
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:3];
            NSArray *voteArray = content;
            NSInteger num = 1;
            
            for (int i = 0 ; i < [voteArray count]; i++) {
                CEditVoteInfo *info = [voteArray objectAtIndex:i];
                if (info.name && [info.name length] > 0) {
                    info.num = num++;
                    [array addObject:[info dictionary]];
                }
            }
            
            if (!array || [array count]<2) {
                [SVProgressHUD showErrorWithStatus:@"Enter at least two items" duration:3];
                return;
            }
            
            [postDic setObject:array forKey:@"options"];
            [postDic setObject:title forKey:@"title"];//title
            
            if (!self.subject || self.subject.length < 1) {
                self.subject = @"Untitled";
            }
            
            [postDic setObject:self.subject forKey:@"message_subject"];
            [postDic setObject:[NSArray array] forKey:@"voted"];
            
            if (self.opType == ItemModify) {
                [postDic setObject:self.item.itemId forKey:@"_id"];
            }
        }
            break;
        case C_LOCK: {
            typeStr = @"lock";
            [postDic setObject:title forKey:@"htmlBody"];
            [postDic setObject:title forKey:@"body"];
        }
            break;
            
        default:
            break;
    }
    
    NSDate * date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:kDateFormat1];
    [postDic setObject:[format stringFromDate:date] forKey:@"date"];
    NSTimeInterval timeStamp = [date timeIntervalSince1970] * 1000;
    [postDic setObject:[NSNumber numberWithLongLong:timeStamp]forKey:@"timestamp"];
    
    if (!self.subject || self.subject.length < 1) {
        self.subject = @"Untitled";
    }
    
    [postDic setObject:self.subject forKey:@"message_subject"];
    [postDic setObject:cname forKey:@"cname"];
    [postDic setObject:typeStr forKey:@"type"];
    [postDic setObject:@"ready" forKey:@"status"];
    
    
    if ([DataManager sharedInstance].currentAccount){
        [postDic setObject:[DataManager sharedInstance].currentAccount.user.email forKey:@"from"];
        [postDic setObject:[DataManager sharedInstance].currentAccount.user.name forKey:@"name"];
    }
    
    if (self.topic_id) {
        postDic[@"topic_id"] = self.topic_id;
    }
    
    if ([DataManager sharedInstance].currentAccount.account_id) {
        postDic[@"account_id"] = [DataManager sharedInstance].currentAccount.account_id;
    }
    
    postDic[@"topic_type"] = @(0);
    
    __block NSString *itemId = Nil;
    
    itemId = [[AppDelegate sharedDelegate] mongo_id_generator];
    
    NSMutableString *predicateString = [@"topic_id = %@" mutableCopy];
    
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithObjects:[self.topic_id noPrefix:kKnoteIdPrefix], nil];
    
    int local_knotes_topic_count = 0;
    
    if(arguments.count > 0)
    {
        local_knotes_topic_count = [MessageEntity MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:predicateString argumentArray:arguments]];
    }
    
    NSNumber *order = nil;
    
    if (local_knotes_topic_count == 0)
    {
        order = [NSNumber numberWithInt:-1];
    }
    else
    {
        order = [NSNumber numberWithInt:(local_knotes_topic_count+1) * -1];
    }
    
    if (!self.item) {
        [postDic setObject:[NSString stringWithFormat:@"%@%@",kKnoteIdPrefix,itemId] forKey:@"_id"];
        postDic[@"order"] = order;
    } else {
        [postDic setObject:self.item.itemId forKey:@"_id"];
        postDic[@"order"] = @(self.item.order);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        if ([self.delegate respondsToSelector:@selector(insertItem:withInfo:withOpType:files:contacts:)]) {
            // Insert new item on top
            [self.delegate insertItem:self.item withInfo:postDic withOpType:self.opType files:self.currentView.imageArray contacts:_sharingContacts];
        } else {
            // Update mode with same index from the list
            [self.delegate insertItem:self.item withInfo:postDic withOpType:self.opType];
        }
    });
    
    
    if (self.itemType == C_KNOTE && self.item) {
        // For Analytics
        NSDictionary *parameters = @{ @"topicId": self.item.topic.topic_id, @"noteId": self.item.itemId };
        [[AnalyticsManager sharedInstance] notifyTextKnoteEditedWithParameters:parameters];
    }
}

- (void)addNoteToExistingPad {

    self.shouldPopToMainView = NO;
    
    if (self.currentView.document &&
        self.item && self.item.userData)
    {
        self.item.userData.documentHTML = self.currentView.document.documentHTML;
        self.item.userData.documentHash = [self.currentView.document.documentHTML md5];
        
        self.item.body = self.currentView.document.text;
        self.item.userData.body = self.item.body;
    }
    
    NSDictionary *postDic = [self dataFromEditView];
    NSLog(@"OUTPUT DICT: %@", postDic);
    
    if (postDic == nil)
        return;
    
//    if (self.newPad)
//    {
//        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
//    }
//    else
//    {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//
//    if ([self.delegate isKindOfClass: [ThreadViewController class]])
//    {
//        ((ThreadViewController*)self.delegate).shouldReloadKnotes = YES;
//    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        if ([self.delegate respondsToSelector:@selector(insertItem:withInfo:withOpType:files:contacts:)])
        {
            // Insert new item on top
            [self.delegate insertItem:self.item
                             withInfo:postDic
                           withOpType:self.opType
                                files:self.currentView.imageArray
                             contacts:_sharingContacts];
        }
        else
        {
            // Update mode with same index from the list
            [self.delegate insertItem:self.item
                             withInfo:postDic
                           withOpType:self.opType];
        }
    });
    
    
    if (self.itemType == C_KNOTE && self.item )
    {
        // For Analytics
        NSDictionary *parameters = @{ @"topicId": self.item.topic.topic_id, @"noteId": self.item.itemId };
        [[AnalyticsManager sharedInstance] notifyTextKnoteEditedWithParameters:parameters];
    }
}

- (NSDictionary*) dataFromEditView
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    
    NSString *typeStr = @"";
    NSString *body = @"";
    NSString *cname = @"knotes";
    NSString *title = [self.currentView getTitle];
    
    id content = [self.currentView getCotent];
    
    if ((!title || [title length] == 0)
        && self.currentView.imageArray.count==0)
    {
        if (self.itemType == C_LIST)
        {
            title=@"List";
        }
        else
        {
            return nil;
        }
    }
    
    NSMutableArray *file_ids = nil;
    
    if ([self.currentView.imageArray count]>0)
    {
        file_ids = [[NSMutableArray alloc] init];
        
        for (FileInfo *finfo in self.currentView.imageArray)
        {
            [file_ids addObject:finfo.imageId];
        }
        
        [postDic setObject:[file_ids copy] forKey:@"file_ids"];
    }
    
    switch (self.itemType)
    {
        case C_MESSAGE:
        case C_KNOTE:
        {
            typeStr = @"knote";
            if (self.itemType == C_MESSAGE)
            {
                typeStr = @"messages_to_knote";
            }
            
            body = [((ComposeNewNote *)self.currentView) getBody];
            NSArray* titleAndContents = body.knotableTitleAndContent;
            
            title = titleAndContents[0];
            body = titleAndContents[1];
            
            if (self.item)
            {
                self.item.userData.documentHTML = [self.zssRichTextEditor getHTML];
                self.item.userData.documentHash = [self.item.userData.documentHTML md5];
                
                self.item.body = [self.zssRichTextEditor getText];
                self.item.userData.body = [self.zssRichTextEditor getText];
            }
            
            if (self.opType == ItemAdd)
            {
                //Wrap in basic HTML if new
                //body = [MessageEntity wrapTextInHTML:body];
            }
            
            if (file_ids && [file_ids count]>0)
            {
                NSString *thumbnailStart =@"<p><div class=\"thumbnail-wrapper thumbnail3 uploading-thumb";
                NSRange range =   [body rangeOfString:thumbnailStart];
                
                if (range.location != NSNotFound)
                {
                    range = [body rangeOfString:@"<div class=\"thumbnail-wrapper thumbnail3 uploading-thumb"];
                }
                
                if (range.location != NSNotFound)
                {
                    range.length = range.location;
                    range.location = 0;
                    body= [body substringWithRange:range];
                }
                
                NSMutableString * output = [NSMutableString new];
                [output appendString:@"<p>"];
                [MessageEntity addThumbnailsHTMLto:output forFileIDS:file_ids];
                [output appendString:@"</p>"];
                body = [body stringByAppendingString:output];
            }
            
            [postDic setObject:body forKey:@"htmlBody"];
            postDic[@"title"] = title;
            [postDic setObject:body forKey:@"body"];
            
            NSMutableArray *userTagsArray = [(ComposeNewNote *)self.currentView getUsertags];
            if (userTagsArray && userTagsArray.count>0) {
                [postDic setObject:userTagsArray forKey:@"usertags"];
            }
            if (self.opType == ItemModify)
            {
                [postDic setObject:self.item.itemId forKey:@"_id"];
            }
        }
            break;
        case C_KEYKNOTE:
        {
            typeStr = @"key_knote";
            cname = @"key_notes";
            body = title;
            [postDic setObject:body forKey:@"note"];
            if (self.opType == ItemModify) {
                [postDic setObject:self.item.itemId forKey:@"_id"];
                MessageEntity *message = self.item.userData;
                if (message.liked_account_ids != nil) {
                    NSArray *likedUsers = [message.liked_account_ids componentsSeparatedByString:@","];
                    [postDic setObject:likedUsers forKey:@"liked_account_ids"];
                }
            }
        }
            break;
        case C_DATE:
        {
            typeStr = @"deadline";
            NSDate *deadline = (NSDate *)content;
            
            [postDic setObject:title forKey:@"deadline_subject"];
            [postDic setObject:deadline forKey:@"deadline"];
            
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
            
            format.dateFormat =kCtlDateFormat;
            [format setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            
            [postDic setObject:[format stringFromDate:deadline] forKey:@"local_deadline"];//Tue Nov 26 14:19:00 2013
            
            if (self.opType == ItemModify)
            {
                [postDic setObject:self.item.itemId forKey:@"_id"];
            }
        }
            break;
        case C_VOTE:
        {
            typeStr = @"poll";
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:3];
            NSArray *voteArray = content;
            NSInteger num = 1;
            for (int i = 0 ; i< [voteArray count]; i++) {
                CEditVoteInfo *info = [voteArray objectAtIndex:i];
                if (info.name && [info.name length]>0) {
                    info.num = num++;
                    [array addObject:[info dictionary]];
                }
            }
            if (!array || [array count]<2) {
                [SVProgressHUD showErrorWithStatus:@"Enter at least two items" duration:3];
                return nil;
            }
            [postDic setObject:array forKey:@"options"];
            [postDic setObject:title forKey:@"title"];//title
            if (!self.subject || self.subject.length<1)
            {
                self.subject = @"Untitled";
            }
            [postDic setObject:self.subject forKey:@"message_subject"];
            [postDic setObject:[NSArray array] forKey:@"voted"];
            if (self.opType == ItemModify) {
                [postDic setObject:self.item.itemId forKey:@"_id"];
            }
        }
            break;
        case C_LIST:
        {
            typeStr = @"checklist";
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:3];
            NSArray *voteArray = content;
            NSInteger num = 1;
            for (int i = 0 ; i< [voteArray count]; i++) {
                CEditVoteInfo *info = [voteArray objectAtIndex:i];
                if (info.name && [info.name length]>0) {
                    info.num = num++;
                    [array addObject:[info dictionary]];
                }
            }
            if (!array || [array count]<2) {
                [SVProgressHUD showErrorWithStatus:@"Enter at least two items" duration:3];
                return nil;
            }
            [postDic setObject:array forKey:@"options"];
            [postDic setObject:title forKey:@"title"];//title
            if (!self.subject || self.subject.length<1)
            {
                self.subject = @"Untitled";
            }
            [postDic setObject:self.subject forKey:@"message_subject"];
            [postDic setObject:[NSArray array] forKey:@"voted"];
            if (self.opType == ItemModify) {
                [postDic setObject:self.item.itemId forKey:@"_id"];
            }
        }
            break;
        case C_LOCK:
        {
            typeStr = @"lock";
            [postDic setObject:title forKey:@"htmlBody"];
            [postDic setObject:title forKey:@"body"];
        }
            break;
            
        default:
            break;
    }
    
    NSDate * date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:kDateFormat1];
    [postDic setObject:[format stringFromDate:date] forKey:@"date"];
    NSTimeInterval timeStamp = [date timeIntervalSince1970]*1000;
    [postDic setObject:[NSNumber numberWithLongLong:timeStamp]forKey:@"timestamp"];
    
    if (!self.subject || self.subject.length<1){
        self.subject = @"Untitled";
    }
    
    [postDic setObject:self.subject forKey:@"message_subject"];
    [postDic setObject:cname forKey:@"cname"];
    [postDic setObject:typeStr forKey:@"type"];
    [postDic setObject:@"ready" forKey:@"status"];

    if([DataManager sharedInstance].currentAccount){
        [postDic setObject:[DataManager sharedInstance].currentAccount.user.email forKey:@"from"];
        [postDic setObject:[DataManager sharedInstance].currentAccount.user.name forKey:@"name"];
    }
    
    if (self.topic_id) {
        postDic[@"topic_id" ] = self.topic_id;
    }
    
    // Lin - Added for setting my_account_id for TopicEntity.
    // @"account_id"
    
    if ([DataManager sharedInstance].currentAccount.account_id)
    {
        postDic[@"account_id" ] = [DataManager sharedInstance].currentAccount.account_id;
    }
    
    // Lin - Ended
    
    postDic[@"topic_type"] = @(0);
    
    
    NSString *itemId = [[AppDelegate sharedDelegate] mongo_id_generator];
    NSString *predicateString = @"topic_id = %@";
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithObjects:[self.topic_id noPrefix:kKnoteIdPrefix], nil];
    
    int local_knotes_topic_count = 0;
    
    if (arguments.count > 0)
    {
        local_knotes_topic_count = (int)[MessageEntity MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:predicateString argumentArray:arguments]];
    }
    
    NSNumber *order = nil;
    
    if (local_knotes_topic_count == 0)
    {
        order = [NSNumber numberWithInt:-1];
    }
    else
    {
        
        order = [NSNumber numberWithInt:(local_knotes_topic_count+1) * -1];
    }
    
    if (!self.item)
    {
        [postDic setObject:[NSString stringWithFormat:@"%@%@",kKnoteIdPrefix,itemId] forKey:@"_id"];
        //      postDic[@"order"] = @(1);
        postDic[@"order"] = order;
    }
    else
    {
        [postDic setObject:self.item.itemId forKey:@"_id"];
        postDic[@"order"] = @(self.item.order);
    }

    return postDic;
}

#pragma mark -

- (NSDictionary*) netDataFromEditView
{
    if (self.itemType != C_KNOTE)
        return nil;
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    
    NSString *typeStr = @"";
    NSString *body = @"";
    NSString *cname = @"knotes";
    NSString *title = [self.currentView getTitle];
    NSString* subject = @"";
    
    id content = [self.currentView getCotent];
    if ((!title || [title length] == 0)
        && self.currentView.imageArray.count==0)
    {
        if (self.itemType == C_LIST)
        {
            title=@"List";
        }
        else
        {
            return nil;
        }
    }
    
    NSMutableArray *file_ids = nil;
    
    if ([self.currentView.imageArray count]>0)
    {
        file_ids = [[NSMutableArray alloc] init];
        
        for (FileInfo *finfo in self.currentView.imageArray)
        {
            [file_ids addObject:finfo.imageId];
        }
        
        [postDic setObject:[file_ids copy] forKey:@"file_ids"];
    }
    
    switch (self.itemType)
    {
        case C_MESSAGE:
        case C_KNOTE:
        {
            typeStr = @"knote";
            if (self.itemType == C_MESSAGE)
            {
                typeStr = @"messages_to_knote";
            }
            
            body = [((ComposeNewNote *)self.currentView) getBody];
            NSArray* titleAndContents = body.knotableTitleAndContent;
           
            title = titleAndContents[0];
            body = titleAndContents[1];
            
            if (file_ids && [file_ids count]>0)
            {
                NSString *thumbnailStart =@"<p><div class=\"thumbnail-wrapper thumbnail3 uploading-thumb";
                NSRange range =   [body rangeOfString:thumbnailStart];
                
                if (range.location != NSNotFound)
                {
                    range = [body rangeOfString:@"<div class=\"thumbnail-wrapper thumbnail3 uploading-thumb"];
                }
                
                if (range.location != NSNotFound)
                {
                    range.length = range.location;
                    range.location = 0;
                    body= [body substringWithRange:range];
                }
                
                NSMutableString * output = [NSMutableString new];
                [output appendString:@"<p>"];
                [MessageEntity addThumbnailsHTMLto:output forFileIDS:file_ids];
                [output appendString:@"</p>"];
                body = [body stringByAppendingString:output];
            }
            
            [postDic setObject:body forKey:@"htmlBody"];
            postDic[@"title"] = title;
            [postDic setObject:body forKey:@"body"];
            
            NSMutableArray *userTagsArray = [(ComposeNewNote *)self.currentView getUsertags];
            if (userTagsArray && userTagsArray.count>0) {
                [postDic setObject:userTagsArray forKey:@"usertags"];
            }
            if (self.opType == ItemModify)
            {
                [postDic setObject:self.item.itemId forKey:@"_id"];
            }
        }
            break;
        case C_KEYKNOTE:
        {
            typeStr = @"key_knote";
            cname = @"key_notes";
            body = title;
            [postDic setObject:body forKey:@"note"];
            if (self.opType == ItemModify) {
                [postDic setObject:self.item.itemId forKey:@"_id"];
                MessageEntity *message = self.item.userData;
                if (message.liked_account_ids != nil) {
                    NSArray *likedUsers = [message.liked_account_ids componentsSeparatedByString:@","];
                    [postDic setObject:likedUsers forKey:@"liked_account_ids"];
                }
            }
        }
            break;
        case C_DATE:
        {
            typeStr = @"deadline";
            NSDate *deadline = (NSDate *)content;
            
            [postDic setObject:title forKey:@"deadline_subject"];
            [postDic setObject:deadline forKey:@"deadline"];
            
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
            
            format.dateFormat =kCtlDateFormat;
            [format setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            
            [postDic setObject:[format stringFromDate:deadline] forKey:@"local_deadline"];//Tue Nov 26 14:19:00 2013
            
            if (self.opType == ItemModify)
            {
                [postDic setObject:self.item.itemId forKey:@"_id"];
            }
        }
            break;
        case C_VOTE:
        {
            typeStr = @"poll";
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:3];
            NSArray *voteArray = content;
            NSInteger num = 1;
            for (int i = 0 ; i< [voteArray count]; i++) {
                CEditVoteInfo *info = [voteArray objectAtIndex:i];
                if (info.name && [info.name length]>0) {
                    info.num = num++;
                    [array addObject:[info dictionary]];
                }
            }
            if (!array || [array count]<2) {
                return nil;
            }
            [postDic setObject:array forKey:@"options"];
            [postDic setObject:title forKey:@"title"];//title
            
            NSString* subject = self.subject;
            
            if (subject.length<1)
            {
                subject = @"Untitled";
            }
            [postDic setObject: subject forKey:@"message_subject"];
            [postDic setObject:[NSArray array] forKey:@"voted"];
            if (self.opType == ItemModify) {
                [postDic setObject:self.item.itemId forKey:@"_id"];
            }
        }
            break;
        case C_LIST:
        {
            typeStr = @"checklist";
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:3];
            NSArray *voteArray = content;
            NSInteger num = 1;
            for (int i = 0 ; i< [voteArray count]; i++) {
                CEditVoteInfo *info = [voteArray objectAtIndex:i];
                if (info.name && [info.name length]>0) {
                    info.num = num++;
                    [array addObject:[info dictionary]];
                }
            }
            if (!array || [array count]<2) {
                return nil;
            }
            [postDic setObject:array forKey:@"options"];
            [postDic setObject:title forKey:@"title"];//title
            NSString* subject = self.subject;
            if (subject.length<1)
            {
                subject = @"Untitled";
            }
            [postDic setObject: subject forKey:@"message_subject"];
            [postDic setObject:[NSArray array] forKey:@"voted"];
            if (self.opType == ItemModify) {
                [postDic setObject:self.item.itemId forKey:@"_id"];
            }
        }
            break;
        case C_LOCK:
        {
            typeStr = @"lock";
            [postDic setObject:title forKey:@"htmlBody"];
            [postDic setObject:title forKey:@"body"];
        }
            break;
            
        default:
            break;
    }
    
    NSDate * date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:kDateFormat1];
    [postDic setObject:[format stringFromDate:date] forKey:@"date"];
    NSTimeInterval timeStamp = [date timeIntervalSince1970]*1000;
    [postDic setObject:[NSNumber numberWithLongLong:timeStamp]forKey:@"timestamp"];
    
    subject = self.subject;
    if (subject.length < 1){
        subject = @"Untitled";
    }
    
    [postDic setObject: subject forKey:@"message_subject"];
    [postDic setObject:cname forKey:@"cname"];
    [postDic setObject:typeStr forKey:@"type"];
    [postDic setObject:@"ready" forKey:@"status"];
//    
//    if([DataManager sharedInstance].currentAccount){
//        [postDic setObject:[DataManager sharedInstance].currentAccount.user.email forKey:@"from"];
//        [postDic setObject:[DataManager sharedInstance].currentAccount.user.name forKey:@"name"];
//    }
//    
//    if (self.topic_id) {
//        postDic[@"topic_id" ] = self.topic_id;
//    }
//    
//    // Lin - Added for setting my_account_id for TopicEntity.
//    // @"account_id"
//    
//    if ([DataManager sharedInstance].currentAccount.account_id)
//    {
//        postDic[@"account_id" ] = [DataManager sharedInstance].currentAccount.account_id;
//    }
//    
//    // Lin - Ended
//    
//    postDic[@"topic_type"] = @(0);
//    NSString *itemId = [[AppDelegate sharedDelegate] mongo_id_generator];
//    NSString *predicateString = @"topic_id = %@";
//    NSMutableArray *arguments = [[NSMutableArray alloc] initWithObjects:[self.topic_id noPrefix:kKnoteIdPrefix], nil];
//    
//    int local_knotes_topic_count = 0;
//    
//    if (arguments.count > 0)
//    {
//        local_knotes_topic_count = (int)[MessageEntity MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:predicateString argumentArray:arguments]];
//    }
//    
//    NSNumber *order = nil;
//    
//    if (local_knotes_topic_count == 0)
//    {
//        order = @(-1);
//    }
//    else
//    {
//        order = @((local_knotes_topic_count+1) * -1);
//    }
//    
//    if (self.item == nil)
//    {
//        [postDic setObject:[NSString stringWithFormat:@"%@%@",kKnoteIdPrefix,itemId] forKey:@"_id"];
//        //      postDic[@"order"] = @(1);
//        postDic[@"order"] = order;
//    }
//    else
//    {
//        [postDic setObject:self.item.itemId forKey:@"_id"];
//        postDic[@"order"] = @(self.item.order);
//    }
    
    return postDic;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    switch (self.itemType) {
        case C_KNOTE:
            break;
        case C_KEYKNOTE:
            break;
        case C_DATE:
        case C_VOTE:
            break;
        case C_LOCK:
            break;
        default:
            break;
    }
    
    if ([self.titleField isEqual:textField])
    {
        NSString *text = textField.text;
        
        text = [text trimmed];
        
        if (!text || text.length == 0)
        {
            text = @"Untitled";
        }
        
        self.subject = text;
    }
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    
//    if (textField == self.textKnoteTitleField) {
//        [self.zssRichTextEditor focusTextEditor];
//        return NO;
//    }
//    else
//    {
//        return [textField resignFirstResponder];
//    }
//}
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    NSString *titleData = [textField.text stringByAppendingString:string];
//    
//    if (self.textKnoteTitleField == textField) {
//
//        if (titleData.length > 150) {
//            
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
//            [self.zssRichTextEditor focusTextEditor];
//            
//            [self.zssRichTextEditor insertHTML:remainTitleText];
//            
//            return NO;
//        }
//    }
//    
//    return YES;
//}

- (void)onKeynoteClicked:(BOOL)bSelected {
    NSString *titleContent = nil;
    NSString *placeHolder = nil;
    self.keynoteSelected = bSelected;
    
    NSString *title = @"";
    
    if (bSelected == NO)
    {
        self.itemType = C_KNOTE;
        
        if ([AppDelegate sharedDelegate].needUseClipBoard )
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            
            if ([pasteboard.string length]>0)
            {
                titleContent = [pasteboard.string copy];
            }
        }
        else
        {
            titleContent = [self.currentView getTitle];
        }
        
        //self.currentView = (ComposeView *)self.cNewNote;
        
        if (self.opType == ItemModify)
        {
            titleContent = self.item.body;
            
            NSMutableArray *imageInfos = [[NSMutableArray alloc] initWithCapacity:3];
            
            for (FileInfo *fInfo in [self.item files])
            {
                FileEntity *file = [FileEntity MR_findFirstByAttribute:@"file_id" withValue:fInfo.imageId];
                
                if (file)
                {
                    NSString *file_id = [[file.full_url componentsSeparatedByString:@"/"] lastObject];
                    
                    NSString * filePath = [kImageCachePath stringByAppendingPathComponent:file_id];
                    
                    if (file_id && [[NSFileManager defaultManager] fileExistsAtPath:filePath])
                    {
                        fInfo.image = [UIImage imageWithContentsOfFile:filePath];
                        
                        [imageInfos addObject:fInfo];
                    }
                }
            }
            
            [self.currentView setCotent:imageInfos];
        }
    }
    else
    {
        self.itemType = C_KEYKNOTE;
        
        title = @"Key Knote";
        
        if (self.opType == ItemModify)
        {
            titleContent = self.item.body;
        }
        else
        {
            titleContent = [self.currentView getTitle];
        }
        
        if (![self.currentView getTitle]
            || [[self.currentView getTitle] length] <= 0 )
        {
            if (self.keyItem)
            {
                titleContent = self.keyItem.body;
            }
            
            NSMutableArray *imageInfos = [[NSMutableArray alloc] initWithCapacity:3];
            
            for (FileInfo *fInfo in [self.item files])
            {
                FileEntity *file = [FileEntity MR_findFirstByAttribute:@"file_id" withValue:fInfo.imageId];
                
                if (file)
                {
                    NSString *file_id = [[file.full_url componentsSeparatedByString:@"/"] lastObject];
                    
                    NSString * filePath = [kImageCachePath stringByAppendingPathComponent:file_id];
                    
                    if (file_id && [[NSFileManager defaultManager] fileExistsAtPath:filePath])
                    {
                        fInfo.image = [UIImage imageWithContentsOfFile:filePath];
                        
                        [imageInfos addObject:fInfo];
                    }
                }
            }
            
            [self.currentView setCotent:imageInfos];
        }
    }
//  self.title = title;
    self.title = @"New Pad";

    [self.currentView setTitleContent:titleContent];
    [self.currentView setTitlePlaceHold:placeHolder];
}

- (void)infoItemTaped:(id)obj {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Would you like to remove this attachment?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Yes"
                                          otherButtonTitles:@"No", nil];
    alert.tag = 10;
    self.selectedInfo = obj;
    [alert show];
}

- (NSString*) contentText
{
    return [((ComposeNewNote *)self.currentView) getBody];
}

//- (void) loadLastContent
//{
//    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//    NSString* content = [defaults stringForKey: @"last_content"];
//    if (content.length > 0)
//    {
//        [((ComposeNewNote *)self.currentView) setBody: content];
//        [defaults removeObjectForKey: @"last_content"];
//    }
//}


- (void) backupCurrentEdit
{
    NSDictionary* currentDictionary = [self netDataFromEditView];
    [ComposeThreadViewController backupWithData: currentDictionary];
}

+ (void) backupWithData: (NSDictionary*) dict
{
    static NSDictionary* previousData = nil;
    NSDictionary* currentDictionary = dict;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (currentDictionary != nil)
    {
        if (previousData == nil)
        {
            previousData = currentDictionary;
            [defaults setObject: currentDictionary forKey: lastComposeKey];
        }
        else
        {
            NSMutableDictionary* prevMutable = [previousData mutableCopy];
            NSMutableDictionary* currentMutable = [currentDictionary mutableCopy];
            [prevMutable removeObjectForKey: @"_id"];
            [prevMutable removeObjectForKey: @"timestamp"];
            [prevMutable removeObjectForKey: @"date"];
            [currentMutable removeObjectForKey: @"_id"];
            [currentMutable removeObjectForKey: @"timestamp"];
            [currentMutable removeObjectForKey: @"date"];
            
            if ([prevMutable isEqualToDictionary: currentMutable] == NO)
            {
                previousData = currentDictionary;
                [defaults setObject: currentDictionary forKey: lastComposeKey];
            }
        }
    }
    else
    {
        [defaults removeObjectForKey: lastComposeKey];
    }
    [defaults synchronize];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10)
    {
        if (buttonIndex==0)
        {
            [self.selectedInfo removeSelfFromServer];
            ComposeExtendedNote *composeNote = (ComposeExtendedNote *)self.currentView;
            [composeNote.imageArray removeObject:self.selectedInfo];
            [composeNote.imageGridView reloadData];
            
            [self.currentView updateConstraints];
            
            self.selectedInfo = nil;
        }
    }
    else
    {
        if (buttonIndex==0)
        {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        else
        {
            NSString *text = [alertView textFieldAtIndex:0].text;
            text = [text trimmed];
            
            NSLog(@"button index: %d text: %@", (int)buttonIndex, text);
            
            if (!text || text.length == 0)
            {
                text = @"Untitled";
            }
            
            self.subject = text;
            
            [self.currentView becomeFirstResponder];
        }
    }
}

#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboardWillShow : Edit View Frame : %@", NSStringFromCGRect(self.currentView.frame));
    
    if (self.itemType != C_DATE)
    {
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
#endif
            
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
            
            NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
            
#else
            
            NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
            
#endif
            NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
            
            CGRect endFrame = keyboardBoundsValue.CGRectValue;
            
            if (self.wasFirstKeyboardDisplayed)
            {
                endFrame.size.height=endFrame.size.height;
                
                self.wasFirstKeyboardDisplayed=NO;
                
            }
            else
            {
                if (self.itemType == C_LIST
                    || self.itemType == C_VOTE)
                {
                    
                }
                else
                {
                    //endFrame.size.height=endFrame.size.height + 37;
                }
            }
            
            CGRect rect = self.contentView.frame;
            
            rect.origin.y = 0;
            
            if (self.itemType == C_KNOTE)
            {
//                rect.size.height = rect.size.height - endFrame.size.height - 2 - 40;
                
                rect.size.height = rect.size.height - endFrame.size.height;
                
                NSLog(@"%@",NSStringFromCGRect(self.zssRichTextEditor.view.frame));
                
            }
            else
            {
                rect.size.height= rect.size.height - endFrame.size.height + 40;
            }
            
            if ([self.currentView isKindOfClass:[ComposeNewNote class]])
            {
                [(ComposeNewNote *)self.currentView keyboardWillShowOrHide:notification];
                
                if (self.itemLifeCycleStage == ItemExisting) {
                    
                    [(ComposeNewNote *)self.currentView hideToolBar];
                }

            }
            
            [UIView animateWithDuration:duration.floatValue animations:^(void) {
                
                if (!self.currentView.showingKeyboard)
                {
                    self.currentView.showingKeyboard = YES;
                    self.currentView.frame = rect;
                }
            }];
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
        }
#endif

    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"keyboardWillHide : Edit View Frame : %@", NSStringFromCGRect(self.currentView.frame));
    
    if (self.itemType!=C_DATE) {
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
            NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
#else
            NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
#endif
            NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
            
            CGRect endFrame = keyboardBoundsValue.CGRectValue;
            
            CGRect rect = self.currentView.frame;
            
            rect.size.height += (endFrame.size.height);
            
            if ([self.currentView isKindOfClass:[ComposeNewNote class]])
			{
                [(ComposeNewNote *)self.currentView keyboardWillShowOrHide:notification];
            }
            
            [UIView animateWithDuration:duration.floatValue animations:^(void) {
                
                if (self.currentView.showingKeyboard)
                {
                    self.currentView.showingKeyboard = NO;
                    self.currentView.frame = rect;
                    [self.currentView updateConstraints];
                }
                
            }];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
        }
#endif
    }
    
    if (self.itemType != C_KNOTE) {
        self.menuWithCamera.hidden = YES;
        self.menuWithOutCamera.hidden = NO;
    } else {
        self.menuWithCamera.hidden = NO;
        self.menuWithOutCamera.hidden = YES;
    }
}

#pragma mark - InputAccessViewManagerDelegate

- (void)cameraButtonClicked {
    ComposeExtendedNote *composeNote = (ComposeExtendedNote *)self.currentView;
    if ([composeNote isKindOfClass:[ComposeExtendedNote class]] || [composeNote isKindOfClass:[ComposeNewNote class]]) {
        [composeNote onAddImage:nil];
    }
}

- (void)sharedButtonClicked {
    [self showShareList];
}

- (void)postButtonClicked {
//    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//    [defaults removeObjectForKey: @"last_content"];
    [self postData];
}

@end

#pragma mark - Navigation Pad Menu Action implemention

@implementation ComposeThreadViewController (KnoteNPMDelegate)

- (void)PadMenuActionIndex:(NSInteger)butIndex {
    switch (butIndex) {
        case 0:
            
            [self textItemSelected];
            
            break;
            
        case 1:
            
            [self deadlineItemSelected];
            
            break;
            
        case 2:
            
            [self checklistItemSelected];
            
            break;
            
        case 3:
            
            [self voteItemSelected];
            
            break;
    }
    
}

@end
