//
//  KnoteRecentVC.m
//  Knotable
//
//  Created by Lin on 10/8/14.
//
//

#import "KnoteRecentVC.h"
#import "AppDelegate.h"
#import "Global.h"
#import "Constant.h"
#import "DesignManager.h"

/////////////////////

#import "LoginViewController.h"
#import "ContactsEntity.h"
#import "single_mongodb.h"
#import "TopicsEntity.h"
#import "UserEntity.h"
#import "CUtil.h"
#import "AsyncDownload.h"
#import "AccountEntity.h"
#import "SVProgressHUD.h"
#import "UIImage+Retina4.h"
#import "MZFormSheetController.h"
#import "MyProfileController.h"
#import "NSString+Knotable.h"
#import "ThreadViewController.h"
#import "MessageEntity.h"
#import "DeadlineCell.h"
#import "LockCell.h"
#import "KeyKnoteCell.h"
#import "VoteCell.h"
#import "KnoteCell.h"
#import "DataManager.h"
#import "NewTopicViewController.h"
#import "TopicManager.h"
#import "TopicInfo.h"
#import "ThreadItemManager.h"
#import "TestFlight.h"
#import "NewKnoteCell.h"
#import "PictureCell.h"
#import "DesignManager.h"
#import "CustomSegmentedControl.h"
#import "ContactManager.h"
#import <OMPromises/OMPromises.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CSNotificationView.h>
#import "PostingManager.h"
#import "UIView+SubviewHunting.h"
#import "PadOwnerCell.h"
#import "UITabBarController+HideTabbar.h"

/////////////////////
@interface KnoteRecentVC()<
NSFetchedResultsControllerDelegate,
TopicProtocol,
TopicInfoDelegate,
ThreadViewControllerDelegate,
CTitleInfoBarDelegate,
MZFormSheetBackgroundWindowDelegate
>
{
    UIAlertView *_clipboardAlert;
    
    int _editingCount;
    
    ContactCell *_editingCell;
    NSIndexPath *_editingIndexPath;
    
    BOOL _justLoaded;
    
}

@property (nonatomic, strong) NSMutableArray *hotVoteTopicArray;
@property (nonatomic, strong) NSMutableArray *hotVoteMessageArray;

@property (strong, atomic) NSIndexPath *expIndexPath;

@property (nonatomic, strong) ContactsEntity* userContact;
@property (nonatomic, strong) ContactsEntity* currentContact;

@property (nonatomic, assign) BOOL isCurrentShow;

@end

@implementation KnoteRecentVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

        
        if([DataManager sharedInstance].currentAccount.user.contact)
        {
            _userContact = [DataManager sharedInstance].currentAccount.user.contact;
            
            if(!_currentContact)
            {
                [self setCurrentContact:_userContact];
            }
        }
        
        isFirstLoad = YES;
        
        self.isCurrentShow = NO;
        
        self.hotVoteTopicArray = [[NSMutableArray alloc] init];
        self.hotVoteMessageArray = [[NSMutableArray alloc] init];
        
        _justLoaded = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fetchedHotKnotes)
                                                     name:HOT_KNOTES_DOWNLOADED_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fetchedHotKnotes)
                                                     name:NEW_CONTACT_DOWNLOADED_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fileDownloaded:)
                                                     name:FILE_DOWNLOADED_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(relationshipsUpdated:)
                                                     name:RELATIONSHIPS_UPDATED_NOTIFICATION
                                                   object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cellExpanded:)
                                                 name:NEWS_CELL_EXPAND
                                               object:nil];
    
    [self InitUI];
    
    [self setCurrentContact:[DataManager sharedInstance].currentAccount.user.contact];
    
    [[DataManager sharedInstance] fetchRemoteHotKnotes];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    if (isFirstLoad)
    {
        isFirstLoad = NO;
    }
    else
    {
        if (SplitMode)
        {
            NSLog(@"Old Frame Rect : %@", NSStringFromCGRect(self.view.frame));
            
            CGSize  newSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - BottomMenuHeight);
            
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, newSize.width, newSize.height)];
            
            NSLog(@"New Frame Rect : %@", NSStringFromCGRect(self.view.frame));
            
            [[AppDelegate sharedDelegate] HideTabController:NO withAnimation:YES];
        }
    }
    
    self.isCurrentShow = YES;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    self.navigationController.navigationBar.tintColor = [DesignManager knoteHeaderTextColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [DesignManager navBarBackgroundColor];
    
    NSDictionary *titleAttr =[NSDictionary dictionaryWithObjectsAndKeys:
                              [DesignManager knoteTitleFont],NSFontAttributeName,
                              [DesignManager knoteUsernameColor], NSForegroundColorAttributeName, nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttr];
    
    [self clearEditingCell];
    
    [[DataManager sharedInstance] fetchRemoteHotKnotes];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isCurrentShow = NO;
    
    if (SplitMode)
    {
        NSLog(@"Old Frame Rect : %@", NSStringFromCGRect(self.view.frame));
        
        CGSize  newSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + BottomMenuHeight);
        
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, newSize.width, newSize.height)];
        
        NSLog(@"New Frame Rect : %@", NSStringFromCGRect(self.view.frame));
        
        [[AppDelegate sharedDelegate] HideTabController:YES withAnimation:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Utility Function
- (void)InitUI
{
    self.title = Nil;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    
    label.backgroundColor = [UIColor clearColor];
    
    label.numberOfLines = 1;
    label.font = [UIFont boldSystemFontOfSize: 20.0f];
    label.adjustsFontSizeToFitWidth=YES;
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [DesignManager KnoteSelectedColor];
    label.text = RECENT_TITLE;
    
    self.view.backgroundColor = [DesignManager appBackgroundColor];
    
    self.navigationItem.titleView    = label;
    
    // Recent Table
    _recentTbl.backgroundColor = [DesignManager appBackgroundColor];
    _recentTbl.separatorColor = [UIColor colorWithWhite:0.77 alpha:.6];
    _recentTbl.separatorStyle = UITableViewCellSeparatorStyleNone;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    
    if (IOS7_OR_LATER)
    {
        [_recentTbl setSeparatorInset:UIEdgeInsetsZero];//
    }
    
#endif
    
    // Recent View has Right Tabbar button for Edit Pad function
    
    self.navigationItem.leftBarButtonItem = Nil;
    self.navigationItem.leftBarButtonItems = Nil;
    
    self.navigationItem.rightBarButtonItem = Nil;
    self.navigationItem.rightBarButtonItems = Nil;
    
    _addBut = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_edit"] style:UIBarButtonItemStylePlain target:self action:@selector(onAddAction)];
    
    self.navigationItem.rightBarButtonItem = _addBut;
    
    self.refresh = [UIRefreshControl new];
    self.refresh.tintColor = [UIColor darkGrayColor];
    self.refresh.backgroundColor = _recentTbl.backgroundColor;
    [self.refresh addTarget:self action:@selector(refreshPulled) forControlEvents:UIControlEventValueChanged];
    [_recentTbl addSubview:self.refresh];
}

-(void)refreshPulled
{
    if ([DataManager sharedInstance].currentAccount)
    {
        [[DataManager sharedInstance] meteorFetchRemoteHotKnotes:^(BOOL success, NSError *error) {
            [self.refresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:1];
        }];
    }
    else
    {
        [self.refresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:1];
    }
    
    self.hotKnotes = [[DataManager sharedInstance] fetchLocalHotKnotes];
}

- (void)cellExpanded:(NSNotification *)note
{
    BaseKnoteCell *cell = note.object;
    
    if (cell.expandeMode == YES)
    {
        self.expIndexPath = [_recentTbl indexPathForCell:cell];
    }
    else
    {
        self.expIndexPath = NO;
    }

    [_recentTbl reloadData];
    
    // Need to check to count notification
}

- (void)setCurrentContact:(ContactsEntity *)currentContact
{
    _currentContact = currentContact;
}

- (void)clearEditingCell
{
    NSLog(@"clearEditingCell");
    
    if(_editingCell && _editingIndexPath)
    {
        [self setEditing:NO atIndexPath:_editingIndexPath cell:_editingCell animate:NO];
    }
    
}

- (NSIndexPath *)indexPathForHotKnote:(MessageEntity *)message
{
    //Compensate for New Knote Button
    NSUInteger index = [_hotKnotes indexOfObject:message];
    //NSUInteger row = index + 1;
    return [NSIndexPath indexPathForRow:index inSection:0];
}

#pragma mark -
#pragma mark - Fetch Functions

- (void)fetchedHotKnotes
{
    
    NSLog(@"fetchedHotKnotes");
    
    //    self.hotKnotes = [[MessageEntity MR_findByAttribute:@"hot" withValue:@(YES) andOrderBy:@"time" ascending:NO] mutableCopy];
    
    self.hotKnotes = [[DataManager sharedInstance] fetchLocalHotKnotes];
    
    [self.hotVoteMessageArray removeAllObjects];
    
    for (MessageEntity *message in self.hotKnotes)
    {
        if (message.type==C_VOTE)
        {
            [self.hotVoteMessageArray addObject:message];
        }
    }
    
    for (MessageEntity *message in self.hotVoteMessageArray)
    {
        BOOL find = NO;
        
        for (TopicsEntity *topic in self.hotVoteTopicArray)
        {
            if ([message.topic_id isEqualToString:topic.topic_id])
            {
                find = YES;
                break;
            }
        }
        
        if (!find)
        {
            TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:message.topic_id];
            
            if (topic)
            {
                [self.hotVoteTopicArray addObject:topic];
            }
        }
    }
    
    if(_justLoaded)
    {
        _justLoaded = NO;
        
        if(self.hotKnotes.count == 0)
        {
            if(_userContact)
            {
                self.currentContact = _userContact;
            }
            
            //            self.displayMode = DisplayModePads;
            
            return;
        }
    }
    
    [self.refresh endRefreshing];
    
    if (self.isCurrentShow)
    {
        [_recentTbl reloadData];
    }
    
    // Need to check to count notification
    
}

- (void)fileDownloaded:(NSNotification *)note
{
    NSString *downloaded_file_id = note.object;
    
    if(!downloaded_file_id){
        return;
    }
    
    for (MessageEntity *message in _hotKnotes)
    {
        if (!message.file_ids || message.file_ids.length == 0)
        {
            continue;
        }
        
        NSArray *file_ids = [message.file_ids componentsSeparatedByString:@","];
        
        if ([file_ids containsObject:downloaded_file_id])
        {
            [_recentTbl reloadRowsAtIndexPaths:@[[self indexPathForHotKnote:message]] withRowAnimation:UITableViewRowAnimationLeft];
            
            break;
        }
    }
}

- (void)relationshipsUpdated:(NSNotification *)note
{
    NSLog(@".");
}

- (void)setHotKnotes:(NSMutableArray *)hotKnotes
{
    _hotKnotes = hotKnotes;
}

#pragma mark -
#pragma mark - User Action

- (void)onAddAction
{
    [[AppDelegate sharedDelegate] AutoHiddenAlert:RECENT_TITLE messageContent:@"Add Pad Feature"];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self tableView:tableView messageHeightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)generateNewMessageCell
{
    NewKnoteCell *cell = [[NewKnoteCell alloc] init];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView messageCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageEntity *message = nil;
    
    if(indexPath.row<[_hotKnotes count])
    {
        message = _hotKnotes[indexPath.row];
    }
    
    Class cellClass = [self cellClassForMessage:message];
    
    BaseKnoteCell *cell = [cellClass new];
    
    cell.delegate = self;
    
    if (self.expIndexPath && [self.expIndexPath compare:indexPath] == NSOrderedSame)
    {
        cell.expandeMode = !cell.expandeMode;
    }
    
    if ([cell isKindOfClass:[VoteCell class]])
    {
        if (message.type == C_VOTE || message.type == C_LIST)
        {
            NSArray * shared_account_ids = nil;
            
            for (TopicsEntity *entity in self.hotVoteTopicArray)
            {
                if ([entity.topic_id isEqualToString:message.topic_id])
                {
                    shared_account_ids = [[entity.shared_account_ids componentsSeparatedByString:@","] mutableCopy];
                }
            }
            
            [(VoteCell *)cell setMy_account_id:[DataManager sharedInstance].currentAccount.user.contact.contact_id];
            
            [(VoteCell *)cell setParticipators:shared_account_ids];
        }
    }
    
    [cell setMessage:message];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    
    [cell setMaxWidth];
    cell.accessoryView = [[ UIImageView alloc ]
                          initWithImage:[UIImage imageNamed:@"Detail_arrow.png" ]];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    cell.titleInfoBar.delegate = self;
    cell.userPictureView.delegate = self;
    
    return cell;
}

#define MAXLABELWIDTH 300
#define ONELINEHEIGHT 20.281
#define BASESIZE      60

- (CGFloat) tableView:(UITableView *)tableView topicHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TopicInfo* p = (TopicInfo*)(_hotKnotes[indexPath.row]);
    
    UILabel * auxSizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    auxSizeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    auxSizeLabel.font = [UIFont systemFontOfSize:17.0];
    auxSizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    auxSizeLabel.numberOfLines = 0;
    auxSizeLabel.backgroundColor = [UIColor clearColor];
    auxSizeLabel.text = p.entity ? p.entity.topic : @"";
    
    CGSize maxSize = CGSizeMake(MAXLABELWIDTH, MAXFLOAT);
    
    CGRect labelRect = [auxSizeLabel.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:auxSizeLabel.font} context:nil];
    
    float h = BASESIZE + ONELINEHEIGHT * ((labelRect.size.height / ONELINEHEIGHT) - 1);
    
    return h;
}

- (Class)cellClassForMessage:(MessageEntity *)message
{
    Class cellClass;
    
    switch (message.type) {
        case C_DATE:
            cellClass = [DeadlineCell class];
            break;
        case C_LOCK:
            cellClass = [LockCell class];
            break;
        case C_KEYKNOTE:
            cellClass = [KeyKnoteCell class];
            break;
        case C_VOTE:
        case C_LIST:
            cellClass = [VoteCell class];
            break;
        default:
            if([message hasPhotoAvailable] || [message.loadedEmbeddedImages count]>0){
                cellClass = [PictureCell class];
            } else {
                cellClass = [KnoteCell class];
            }
            break;
    }
    
    return cellClass;
}

- (void)downloadedImageForHotKnote:(NSNotification *)note
{
    NSLog(@"downloadedImageForHotKnote");
    
    FileEntity *file = note.object;
    
    if (file.knote)
    {
        if([_hotKnotes containsObject:file.knote])
        {
            NSUInteger row = [_hotKnotes indexOfObject:file.knote];
            
            NSLog(@"reloading row %lu", (unsigned long)row);
            
            [_recentTbl reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAGE_DOWNLOADED_NOTIFICATION object:file];
}

#pragma mark -
#pragma mark - Table view delegate

- (void)setEditing:(BOOL)editing atIndexPath:indexPath cell:(UITableViewCell *)cell
{
    [self setEditing:editing atIndexPath:indexPath cell:cell animate:YES];
}

- (void)setEditing:(BOOL)editing atIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell animate:(BOOL)animate
{
    
}

- (CGFloat)tableView:(UITableView *)tableView messageHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageEntity *message = _hotKnotes[indexPath.row];
    
    Class cellClass = [self cellClassForMessage:message];
    
    BaseKnoteCell *prototypeCell = nil;
    
    if (prototypeCell == nil)
    {
        prototypeCell = [cellClass new];
        
        if ([prototypeCell isKindOfClass:[VoteCell class]])
        {
            if (message.type == C_VOTE || message.type == C_LIST)
            {
                NSArray * shared_account_ids = nil;
                
                for (TopicsEntity *entity in self.hotVoteTopicArray)
                {
                    if ([entity.topic_id isEqualToString:message.topic_id])
                    {
                        shared_account_ids = [[entity.shared_account_ids componentsSeparatedByString:@","] mutableCopy];
                    }
                }
                
                [(VoteCell *)prototypeCell setMy_account_id:[DataManager sharedInstance].currentAccount.user.contact.contact_id];
                [(VoteCell *)prototypeCell setParticipators:shared_account_ids];
            }
        }
    }
    
//    NSLog(@"%@", [[prototypeCell class] description]);
    
    [prototypeCell setMessage:message];
    
    
    [prototypeCell setNeedsUpdateConstraints];
    [prototypeCell updateConstraintsIfNeeded];
    
    [prototypeCell.contentView setNeedsLayout];
    [prototypeCell.contentView layoutIfNeeded];
    
    if (self.expIndexPath && [self.expIndexPath compare:indexPath] == NSOrderedSame) {
        prototypeCell.expandeMode = !prototypeCell.expandeMode;
    }
    
    [prototypeCell setMaxWidth];
    
    
    CGFloat height = [prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[BaseKnoteCell class]])
    {
        BaseKnoteCell *baseCell = (BaseKnoteCell *)cell;
        [baseCell willAppear];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[BaseKnoteCell class]]) {
        BaseKnoteCell *baseCell = (BaseKnoteCell *)cell;
        [baseCell didDissapear];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger   retRowCount = 0;
    
    retRowCount = [_hotKnotes count];
    
    return retRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    cell = [self tableView:tableView messageCellForRowAtIndexPath:indexPath];
    
    return cell;
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    return ;
}

- (void)openMessageRowInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    int row = (int)indexPath.row;
    
    [TestFlight passCheckpoint:@"Opened Hot Knote"];
    
    NSArray *data = _hotKnotes;
    
    if(data.count <= row)
    {
        NSLog(@"Error: data length %d looking for index %d", (int)data.count, (int)indexPath.row);
        
        return;
    }
    
    MessageEntity* message = data[row];
    
    [message MR_refresh];
    
    if(!message.topic_id)
    {
        NSLog(@"Error: empty topic ID for message ID: %@", message.message_id);
        return;
    }
    
    TopicsEntity* topic = nil;
    
    if(!topic)
    {
        topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:message.topic_id];
    }
    
    if(!topic)
    {
        [single_mongodb sendRequestTopic:message.topic_id withUserId:[DataManager sharedInstance].currentAccount.user.user_id withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
            
            NSArray *array = (NSArray *)userData;
            
            if ([array count]>0)
            {
                BSONDocument *dic = [array firstObject];
                
                TopicsEntity* topic = [[DataManager sharedInstance] insertOrUpdateNewTopicObject:[dic dictionaryValue]];
                
                TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:topic];
                ThreadViewController* threadController = [[ThreadViewController alloc] initWithTopic:tInfo];
                
                threadController.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:threadController animated:YES];
#if 0
                message.hot = NO;
                message.removedHot = YES;
                message.view_count++;
                NSInteger hotIndex = [_hotKnotes indexOfObject:message];
                [_hotKnotes removeObjectAtIndex:hotIndex];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:hotIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView reloadData];
                // Need to check to count notification
                
#endif
            }
            
        }];
        
        NSLog(@"ERROR: Can't find topic in memory or in core data for topic id: %@", message.topic_id);
        
        return;
    }
    
    TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:topic];
    ThreadViewController* threadController = [[ThreadViewController alloc] initWithTopic:tInfo];
    
    [self.navigationController pushViewController:threadController animated:YES];
    
#if 0
    
    message.hot = NO;
    message.removedHot = YES;
    message.view_count++;
    NSInteger hotIndex = [_hotKnotes indexOfObject:message];
    [_hotKnotes removeObjectAtIndex:hotIndex];
    [_recentTbl deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:hotIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [_recentTbl reloadData];
    
    // Need to check to count notification
    
#endif
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.expIndexPath = nil;
    
    [self openMessageRowInTableView:tableView atIndexPath:indexPath];
    
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSLog(@"commitEditingStyle Delete %@,%d", _hotKnotes ,(int)indexPath.row);
        // Delete the row from the data source
        
        [_hotKnotes removeObjectAtIndex:indexPath.row];
        
        {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
            
            [_recentTbl performSelector:@selector(reloadData) withObject:nil afterDelay:0];
        }
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark CTitleInfoBarDelegate

- (void) titleInfoClickeAtContact:(ContactsEntity *)entity
{
    MyProfileController *profile = [[MyProfileController alloc] initWithContact:entity];
    
    
    profile.removeFromPad.hidden=YES;
    __block MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:profile];
    CGFloat ctlHeight = self.view.bounds.size.height - 60;
    formSheet.presentedFormSheetSize = CGSizeMake(300, ctlHeight);
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    //    formSheet.shouldCenterVerticallyWhenKeyboardAppears = YES;
    [formSheet setPortraitTopInset:20];
    [formSheet setLandscapeTopInset:20];
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
    };
    
    [MZFormSheetController sharedBackgroundWindow].formSheetBackgroundWindowDelegate = self;
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
    
}

#pragma mark -
#pragma mark EditorViewControllerDelegate

- (void)insertItem:(CItem *)item withInfo:(id)info withOpType:(ItemOpType)type
{
    //not used
}

- (void)insertItem:(CItem *)item withInfo:(id)info withOpType:(ItemOpType)type files:(NSArray *)files contacts:(NSArray *)contacts
{
    NSLog(@"item: %@ info: %@", item, info);
    NSDictionary *dict = info;
    NSString *topicTitle = dict[@"message_subject"];
    
    //NSString *text = dict[@"htmlBody"];
    
        
    [[TopicManager sharedInstance] generateNewTopic:topicTitle content:dict files:files account:[DataManager sharedInstance].currentAccount sharedContacts:contacts withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
        
        TopicInfo *tInfo = userData;
        
        if (tInfo)
        {
            tInfo.entity = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:tInfo.topic_id];
            tInfo.item.userData = [MessageEntity MR_findFirstByAttribute:@"message_id" withValue:tInfo.message_id];
            
            NSMutableSet *topicContacts = [[NSMutableSet alloc] init];
            
            if ([DataManager sharedInstance].currentAccount.user.contact)
            {
                tInfo.entity.contact_id = [DataManager sharedInstance].currentAccount.user.contact.contact_id;
                [topicContacts addObject:[DataManager sharedInstance].currentAccount.user.contact];
            }
            
            if (_currentContact)
            {
                [topicContacts addObject:_currentContact];
            }
            
            if (contacts)
            {
                [topicContacts addObjectsFromArray:contacts];
            }
            
            tInfo.entity.contacts = [topicContacts copy];
            
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
//                    [self.topicArray insertObject:tInfo atIndex:0];
                    
//                    NSIndexPath *firstIndex = [NSIndexPath indexPathForRow:0 inSection:0];
                    
                    // Need to check about working
                    
//                    [self openTopicRowInTableView:_recentTbl atIndexPath:firstIndex animated:NO];
                    
                });
            }
        }
    }];
    
    
}

- (void)gotItem:(CItem *)item withInfo:(id)info withOpType:(ItemOpType)type
{
    //not used
}

#pragma mark -
#pragma mark - Topic Function Delegate
-(void) topicArchivOperate:(TopicInfo *)tInfo
{
    
}

-(void) topicEditCanceled
{
    
}

-(void)needChangeTopicTitle:(TopicInfo *)tInfo
{
    
}

-(void) topicAdded:(NSString*)title content:(NSString*)content fileIds:(NSArray*)fileArray contacts:(NSArray *)contacts
{
    
}
@end
