//
//  AccountSettings.m
//  Knotable
//
//  Created by darshana on 14/08/14.
//
//

#import "AccountSettings.h"
#import "AccountEntity.h"
#import "UserEntity.h"
#import "ContactsEntity.h"
#import "Constant.h"
#import "CUtil.h"
#import "SDImageCache.h"
#import <Masonry/View+MASAdditions.h>
#import "DataManager.h"
#import "UIImage+imageEffects.h"
@interface AccountSettings ()

@property(strong,nonatomic)NSMutableArray *settingItems;

@property (weak, nonatomic) IBOutlet UIImageView *blurredImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTableViewHeightConstraint;

@end

@implementation AccountSettings

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
    //self.title=@"Account Settings";
    
    [self insertUserImage];
    
    self.settingItems =[[NSMutableArray alloc] init];
    
    NSUserDefaults *deflts= [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dct =[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                               @"Notification", @"title",
                               [DataManager sharedInstance].currentAccount.notificationStatus.boolValue?@"on":@"off", @"subtitle",
                               @"switch",@"Accessory",
                               nil];
    
    [dct setObject:@([DataManager sharedInstance].currentAccount.notificationStatus.boolValue) forKey:@"SwitchSatus"];
    
    [self.settingItems addObject:dct];
    
    dct = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
           @"Notification Preview", @"title",
           @"Show name and message", @"subtitle",
           @"switch", @"Accessory",
           nil];
    
    BOOL preview= [deflts boolForKey:knotificationPreview];
    
    [dct setObject:@(preview) forKey:@"SwitchSatus"];
    
    [self.settingItems addObject:dct];
    
    BOOL sounds=  [deflts boolForKey:knotificationsound];
    
    dct = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
           @"In-App Sound", @"title",
           sounds?@"on":@"off", @"subtitle",
           @"switch", @"Accessory",
           nil];
    
    [dct setObject:@(sounds) forKey:@"SwitchSatus"];
    
    [self.settingItems addObject:dct];
    
    BOOL vibrate= [deflts boolForKey:knotificationvibrate];
    
    dct = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
           @"In-App Vibrate", @"title",
           vibrate?@"on":@"off", @"subtitle",
           @"switch", @"Accessory",
           nil];
    
    [dct setObject:@(vibrate) forKey:@"SwitchSatus"];
    
    [self.settingItems addObject:dct];
    
    self.username.text = [DataManager sharedInstance].currentAccount.user.contact.name;
    self.userphone.text= [DataManager sharedInstance].currentAccount.user.contact.phone;
    self.userphone.hidden = YES;
    
    // Do any additional setup after loading the view from its nib.
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if(screenSize.height > 480.0f)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.settingsTableViewHeightConstraint.constant = 328;
            [self.view setNeedsUpdateConstraints];
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

#define USER_IMAGE_DIAMETER 120

- (void)insertUserImage
{
    UIImage *userImage = nil;
    
    ContactsEntity *_contact = [DataManager sharedInstance].currentAccount.user.contact;
    
    AccountEntity *_account = [DataManager sharedInstance].currentAccount;
    
     if (_contact.fullURL.length>0)
    {
        NSString *path  = [CUtil pathForCachedImage:_contact.email];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            userImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:path] scale:[UIScreen mainScreen].scale];
        }
    }
    else
    {
        userImage =  [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_account.account_id];
    }
    
    if(!userImage)
    {
        if (_contact.name && [_contact.name length]>0)
        {
            userImage = [CUtil imageText:[[_contact.name substringWithRange:NSMakeRange(0,1)] uppercaseString]
                          withBackground:_contact.bgcolor
                                    size:CGSizeMake(USER_IMAGE_DIAMETER, USER_IMAGE_DIAMETER)
                                    rate:0.6];
        }
    }
    
    if(userImage)
    {
        self.blurredImageView.image = [userImage applyDarkEffect];
        
        //UIColor *edgeColor = [UIColor colorWithRed:0.99 green:0.82 blue:0.77 alpha:1.0];
        
        UIColor *edgeColor = [UIColor grayColor];
        
        _userImageView = [[GBPathImageView alloc] initWithFrame:CGRectMake(0, (self.blurredImageView.frame.size.height - USER_IMAGE_DIAMETER) / 2 , USER_IMAGE_DIAMETER, USER_IMAGE_DIAMETER)
                                                          image:userImage
                                                       pathType:GBPathImageViewTypeCircle
                                                      pathColor:edgeColor
                                                    borderColor:edgeColor
                                                      pathWidth:1.5];
        
        [self.blurredImageView addSubview:_userImageView];
        
        [_userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@64.0);
            make.size.equalTo([NSNumber numberWithInt:USER_IMAGE_DIAMETER]);
            make.centerX.equalTo(@0.0);
        }];
        //[_userImageView draw];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableviewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.settingItems.count;///need to change
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tblAccountSettings cellForRowAtIndexPath:indexPath];
    
    if(cell==nil)
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    NSMutableDictionary *dataDict=[self.settingItems objectAtIndex:indexPath.row];
    
    if([[dataDict objectForKey:@"Accessory"] isEqualToString:@"switch"])
    {
        UISwitch *onOff =[[UISwitch alloc] initWithFrame:CGRectZero];
        onOff.tag=indexPath.row;
        onOff.on=[[dataDict objectForKey:@"SwitchSatus"] boolValue];
        [onOff addTarget:self action:@selector(onOffSettingChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView =onOff;
        
    }
    
    cell.textLabel.text=[dataDict objectForKey:@"title"];
    
    cell.detailTextLabel.text =[dataDict objectForKey:@"subtitle"];
    
    return cell;
}

-(void)onOffSettingChanged:(UISwitch*)onOffSwitch
{
    NSMutableDictionary *dctData =[self.settingItems objectAtIndex:onOffSwitch.tag];
    
    [dctData setObject:@(onOffSwitch.on) forKey:@"SwitchSatus"];
    
    NSUserDefaults *deflts =[NSUserDefaults standardUserDefaults];
    
    switch (onOffSwitch.tag)
    {
        case 0:
            [DataManager sharedInstance].currentAccount.notificationStatus=@(onOffSwitch.on);
            [AppDelegate saveContext];
            [dctData setObject:[DataManager sharedInstance].currentAccount.notificationStatus.boolValue?@"on":@"off" forKey:@"subtitle"];
            break;
    
        case 1:
            [deflts setBool:onOffSwitch.on forKey:knotificationPreview];
            break;
            
        case 2:
            [deflts setBool:onOffSwitch.on forKey:knotificationsound];
            [dctData setObject:onOffSwitch.on?@"on":@"off" forKey:@"subtitle"];
            break;
            
        case 3:
            [deflts setBool:onOffSwitch.on forKey:knotificationvibrate];
            [dctData setObject:onOffSwitch.on?@"on":@"off" forKey:@"subtitle"];
            break;
            
        default:
            break;
    }
    
    [deflts synchronize];
    
    [self.tblAccountSettings reloadData];
}
@end
