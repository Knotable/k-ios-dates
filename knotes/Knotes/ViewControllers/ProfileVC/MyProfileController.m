//
//  MyProfileController.m
//  Knotable
//
//  Created by Martin Ceperley on 1/2/14.
//
//

#import "MyProfileController.h"
#import "ProfileDetailVC.h"

#import "Constant.h"
#import "Global.h"

#import "UserEntity.h"
#import "TopicsEntity.h"
#import "AccountEntity.h"
#import "ContactsEntity.h"

#import "UIImage+Retina4.h"
#import "NSString+Knotes.h"
#import "UIImage+ImageEffects.h"
#import "OMPromises/OMPromises.h"
#import <Masonry/View+MASAdditions.h>

#import "CUtil.h"
#import "ObjCMongoDB.h"
#import "SDImageCache.h"

#import "GBPathImageView.h"
#import "EmailEditorView.h"

#import "DataManager.h"
#import "DesignManager.h"
#import "AnalyticsManager.h"

#import "UIImageView+AFNetworking.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"

#define LABELS_PADDING 8
#define DATA_PADDING 70
#define DIAMETER_LOSS_35 30
#define HEIGHT_LOSS_35 40

@interface MyProfileController (){
    
@private
    UIResponder *currentResponder;
}

@property (nonatomic, strong) AccountEntity     *account;
@property (nonatomic, strong) UserEntity        *user;
@property (nonatomic, strong) ContactsEntity    *contact;

@property (nonatomic) BOOL                      isPopover;
@property (nonatomic, strong)   GBPathImageView *userImageView;

@property (nonatomic, strong)   IBOutlet UIView             *scrollViewContent;
@property (nonatomic, strong)   IBOutlet UILabel            *usernameLabel;
@property (nonatomic, strong)   IBOutlet UIScrollView       *scrollView;
@property (nonatomic, strong)   IBOutlet UIImageView        *backgroundImageView;
@property (weak, nonatomic)     IBOutlet UITableView        *userDataTableView;
@property (weak, nonatomic)     IBOutlet NSLayoutConstraint *userDataHeightConstraint;
@property (weak, nonatomic)     IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic)     IBOutlet NSLayoutConstraint *blurredImageHeightConstraint;

@end

@implementation MyProfileController

@synthesize profile_remove_buttonType;

- (id)initWithAccount:(AccountEntity *)account
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self)
    {
        self.account = account;
        self.user = account.user;
        self.contact = account.user.contact;
        self.isPopover = NO;
    }
    
    return self;
}

- (id)initWithContact:(ContactsEntity *)contact
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self)
    {
        self.contact = contact;
        self.isPopover = YES; // If init is used somewhere else, needs to be updated.
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Profile";
    
    [self updateViewFormat];
    
    self.view.backgroundColor = [DesignManager appBackgroundColor];

    self.usernameLabel.text = _contact.name;
    
    [self updateProfileImage];
    
    self.btn_remove_contact.layer.cornerRadius = 6;
    
    if (self.profile_remove_buttonType == RemoveFromContact)
    {
        [self.btn_remove_contact setHidden:NO];
        
        [self.btn_remove_contact setTitle:@"Remove Contact" forState:UIControlStateNormal];
    }
    else if (self.profile_remove_buttonType == RemoveFromPad)
    {
        [self.btn_remove_contact setHidden:NO];
        
        [self.btn_remove_contact setTitle:@"Remove from pad" forState:UIControlStateNormal];
    }
    else if (self.profile_remove_buttonType == RemoveFromNone)
    {
        [self.btn_remove_contact setHidden:YES];
    }
    
    if(!self.user)
    {
        //Read-only profile
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    // Doesn't work on ios 8, changed for "willdisplaycell" approach
    //[self.userDataTableView setSeparatorInset:UIEdgeInsetsZero];
    
    self.userDataTableView.delegate=self;
    self.userDataTableView.dataSource=self;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    NSLog(@"%@", NSStringFromCGSize(screenSize));
    
    if( ( screenSize.height <= 480.0f ) && self.isPopover)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.blurredImageHeightConstraint.constant = 160;
            [self.view setNeedsUpdateConstraints];
        }];
    }
    
    [self adjustHeightOfTableviews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Utilify Functions

- (void)adjustHeightOfTableviews
{
    // Mail tableview first
    float height = [self.userDataTableView numberOfRowsInSection:0] * 44;
    
    if([self.userDataTableView numberOfRowsInSection:0] > 3)
    {
        self.userDataTableView.scrollEnabled = YES;
        height = 4 * 44;
    }
}

-(void)createBlurredImageWithUserImage:(UIImage *)userImage
{
    self.blurredProfileImageView.image =[userImage applyDarkEffect];
}

-(void)updateViewFormat
{
    if (!self.bDisplayMenu)
    {
        for (UIView *view in [self.scrollView subviews])
        {
            view.hidden = NO;
            
            if ([view isKindOfClass:[UIView class]])
            {
                for (UIView *vw in [view subviews])
                {
                    vw.hidden = NO;
                }
            }
        }
        self.usernameLabel.hidden = NO;
    }
    else
    {
        self.userDataTableView.hidden = YES;
    }
}

- (void) updateProfileImage
{
    /********************************************************
     
     Function :
     
     1. check the user profile image.
     2. If there is not user profile image, then try to find gravatar image
     3. In other case, app would use
     
     ********************************************************/
    
    [ContactsEntity getAsyncImage:self.contact WithBlock:^(id img, BOOL flag) {
        
        [self loadProfileImage:img];
        
    }];
    
    return;
    
    NSString* profileImageUrl = Nil;
    
    if (self.contact.fullURL)
    {
        profileImageUrl = self.contact.fullURL;
    }
    
    if (profileImageUrl)
    {
        UIImage* img = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:GET_CACHE_KEY_FOR_FULLURL(self.contact.account_id)];
        
        if (img)
        {
            [self loadProfileImage:img];
        }
        else
        {
            [self.blurredProfileImageView sd_setImageWithURL:[NSURL URLWithString:profileImageUrl]
                                            placeholderImage:Nil
                                                     options:SDWebImageRefreshCached
                                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                       
                                                       if (image)
                                                       {
                                                           [[SDImageCache sharedImageCache] storeImage:image forKey:GET_CACHE_KEY_FOR_FULLURL(self.contact.account_id) toDisk:YES];
                                                           
                                                           [self loadProfileImage:image];
                                                       }
                                                       else
                                                       {
                                                           [self loadProfileImage:[self generatePlaceHolderImage]];
                                                       }
                                                   }];
            
            [self loadProfileImage:[self generatePlaceHolderImage]];
        }
    }
    else
    {
        [self loadProfileImage:[self generatePlaceHolderImage]];
    }
    
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@64.0f);
        make.size.equalTo([NSNumber numberWithInt:120]);
        make.left.equalTo(self.blurredProfileImageView.mas_left).offset(100);
    }];
}

- (void) loadProfileImage : (UIImage* )profileImage
{
    [self performSelectorInBackground:@selector(createBlurredImageWithUserImage:) withObject:profileImage];
    
    UIColor *edgeColor = [UIColor grayColor];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    float userImageDiameter = 120;
    float imageYPosition = ((self.blurredProfileImageView.frame.size.height - userImageDiameter) / 2);
    
    if( (screenSize.height <= 480.0f) && (self.isPopover) )
    {
        userImageDiameter -= DIAMETER_LOSS_35;
        imageYPosition -= HEIGHT_LOSS_35;
        
        UIView * v = self.usernameLabel.superview;
        
        [self.usernameLabel removeFromSuperview];
        
        float auxHeight = self.usernameLabel.frame.origin.y - DIAMETER_LOSS_35 - HEIGHT_LOSS_35;
        
        self.usernameLabel.frame = CGRectMake(self.usernameLabel.frame.origin.x, auxHeight,
                                              self.usernameLabel.frame.size.width, self.usernameLabel.frame.size.height);
        
        [v addSubview:self.usernameLabel];
    }
    
    self.userImageView = [[GBPathImageView alloc] initWithFrame:CGRectMake(((self.blurredProfileImageView.frame.size.width - userImageDiameter) / 2), imageYPosition, userImageDiameter, userImageDiameter)
                                                          image:profileImage
                                                       pathType:GBPathImageViewTypeCircle
                                                      pathColor:edgeColor
                                                    borderColor:edgeColor
                                                      pathWidth:1.5];
    
    [self.blurredProfileImageView addSubview:self.userImageView];
}

- (UIImage* ) generatePlaceHolderImage
{
    UIImage* retImg = Nil;
    
    if (_contact.gravatar_exist)
    {
        NSString *path  = [CUtil pathForCachedImage:_contact.email];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            retImg = [UIImage imageWithData:[NSData dataWithContentsOfFile:path] scale:[UIScreen mainScreen].scale];
        }
    }
    else
    {
        retImg =  [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_account.account_id];
    }
    
    if(!retImg)
    {
        if (_contact.name && [_contact.name length]>0)
        {
            retImg = [CUtil imageText:[[_contact.name substringWithRange:NSMakeRange(0,1)] uppercaseString]
                       withBackground:_contact.bgcolor
                                 size:CGSizeMake(120, 120)
                                 rate:0.6];
        }
    }
    
    
    return retImg;
}

-(IBAction)removeContact:(UIButton*)sender
{    
    if (self.profile_remove_buttonType == RemoveFromContact)
    {
        // Need to implement here
        
        if ([AppDelegate sharedDelegate].meteor
            && [AppDelegate sharedDelegate].meteor.connected)
        {
            NSArray * mailsArray = [self.contact.email componentsSeparatedByString:@","];
            
            if ([mailsArray count] > 0)
            {
                NSArray *params = @[[DataManager sharedInstance].currentAccount.account_id,
                                    [mailsArray firstObject]];
                
                [[AppDelegate sharedDelegate].meteor callMethodName:@"remove_contact"
                                                         parameters:params
                                                   responseCallback:^(NSDictionary *response, NSError *error)
                {
                    if (error == Nil)
                    {
                        if (response)
                        {
                            NSInteger result = [response[@"result"] integerValue];
                            
                            if (result == 1)
                            {
                                NSLog(@"Success");
                                
                                if (self.delegate &&
                                    [self.delegate respondsToSelector:@selector(removedContact:)])
                                {
                                    [self.delegate removedContact:self.contact];
                                }
                            }
                            else
                            {
                                NSLog(@"Failed");
                            }
                        }
                    }
                    
                    
                }];
            }
        }
        
    }
    else if (self.profile_remove_buttonType == RemoveFromPad)
    {
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(removedContactFromPad:)])
        {
            [self.delegate removedContactFromPad:self.contact];
        }
    }
    else if (self.profile_remove_buttonType == RemoveFromNone)
    {
        
    }
    
}



#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    // Only COMPILE this if compiled against BaseSDK iOS8.0 or greater
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
#endif
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger retVal = -1;
    
    NSInteger contactMailcount = -1;
    
    NSLog(@"Contact mail : %@", self.contact.email);
    
    contactMailcount = [self.contact.email componentsSeparatedByString:@","].count ;
    
    if ( contactMailcount == 0)
    {
        retVal = 3;
    }
    else
    {
        retVal = contactMailcount + 2;
    }
    
    retVal =  contactMailcount + 2;
    
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *CellIdentifier = @"cell";
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    NSArray * mailsArray = [self.contact.email componentsSeparatedByString:@","];
    
    UILabel *label = [[UILabel alloc ] initWithFrame:CGRectMake(LABELS_PADDING, cell.frame.origin.y,
                                                                50, cell.frame.size.height)];
    label.textAlignment =  NSTextAlignmentRight;
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]/*[UIFont systemFontOfSize:14]*/;
    
    UILabel *dataLabel = [[UILabel alloc ] initWithFrame:CGRectMake(DATA_PADDING, cell.frame.origin.y,
                                                                    cell.frame.size.width - DATA_PADDING - 28, cell.frame.size.height)];
    dataLabel.textAlignment =  NSTextAlignmentLeft;
    dataLabel.textColor = [UIColor blackColor];
    dataLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]/*[UIFont systemFontOfSize:14]*/;
    dataLabel.numberOfLines = 3;
    
    if (indexPath.row < ( [mailsArray count] + 2 ) )
    {
        if(indexPath.row < mailsArray.count)
        {
            if(indexPath.row == 0)
            {
                label.text = @"Email";
                
                [cell addSubview:label];
            }
            
            dataLabel.text = [mailsArray objectAtIndex:indexPath.row];
        }
        else if (indexPath.row == mailsArray.count)
        {
            label.text = @"Phone";
            [cell addSubview:label];
            
            dataLabel.text = self.contact.phone;
        }
        else if (indexPath.row == (mailsArray.count + 1))
        {
            label.text = @"Site";
            [cell addSubview:label];
            dataLabel.text = self.contact.website;
        }
        
        [cell addSubview:dataLabel];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row ==0)
    {
        ProfileDetailVC *profileInfo =[[ProfileDetailVC alloc] initWithAccount:self.account];
        [self.navigationController pushViewController:profileInfo animated:YES];
    }
}

@end
