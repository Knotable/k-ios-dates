//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import "SideMenuViewController.h"
#import "UserEntity.h"
#import "AccountEntity.h"
#import "UIImage+FontAwesome.h"

@implementation SideMenuViewController

#pragma mark -
#pragma mark - UITableViewDataSource
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor clearColor];
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    UIView *ne=[[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    ne.backgroundColor=[UIColor whiteColor];
    self.tableView.tableFooterView=ne;
    self.tableView.scrollEnabled=NO;
    self.Cur_user=self.Cur_account.user;
    if(!self.Cur_contact)
    {
        self.Cur_contact = [ContactsEntity MR_findFirstByAttribute:@"mainEmail"
                                                     withValue:[[self.Cur_user.email componentsSeparatedByString:@","] firstObject]];
        
        if(!self.Cur_contact){
            self.Cur_contact = [ContactsEntity MR_findFirstByAttribute:@"mainEmail"
                                                         withValue:[[self.Cur_user.email componentsSeparatedByString:@","] lastObject]];
        }
    }
    
    if(!self.Cur_contact)
    {
        self.Cur_contact = self.Cur_user.contact;
    }

}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [NSString stringWithFormat:@"Section %d", section];
//}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 150;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"Cell";
//    
//    SideTableViewCell *cell = (SideTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil)
//    {
//        cell = [[SideTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        //cell.textLabel.textColor=DarkBlueColor;
//        cell.textLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:12]/*[UIFont systemFontOfSize:12]*/;
//    }
//
//    if(indexPath.row==0)
//    {
//        cell.lbl_text.text=@"People";
//        cell.imgMenu.image = [UIImage imageWithIcon:@"fa-user" backgroundColor:[UIColor clearColor] iconColor:[UIColor blackColor] fontSize:24];
//    }
//    else if (indexPath.row==1)
//    {
//        cell.lbl_text.text=@"Pads";
//        cell.imgMenu.image=[UIImage imageNamed:@"entypo_text"];
//    }
//    else if (indexPath.row==2)
//    {
//        cell.lbl_text.text=@"Settings";
//        cell.imgMenu.image = [UIImage imageWithIcon:@"fa-cog" backgroundColor:[UIColor clearColor] iconColor:[UIColor blackColor] fontSize:24];
//    }
//    
//    cell.selectionStyle=UITableViewCellSelectionStyleNone;
//    cell.backgroundColor=[UIColor whiteColor];
//    if (indexPath.row==_selectedRow)
//    {
//        cell.backgroundColor=[UIColor colorWithWhite:0.961 alpha:1.000];
//        cell.lbl_text.textColor=[UIColor colorWithRed:0.094 green:0.557 blue:0.996 alpha:1.000];
//        cell.imgMenu.image=[cell.imgMenu.image imageTintedWithColor:[UIColor colorWithRed:0.094 green:0.557 blue:0.996 alpha:1.000]];
//    }
//    else
//    {
//        cell.imgMenu.image=[cell.imgMenu.image imageTintedWithColor:[UIColor blackColor]];
//    }
//   
//    return cell;
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    SideTableViewCell *cell = (SideTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[SideTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell.textLabel.textColor=DarkBlueColor;
        cell.textLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:12]/*[UIFont systemFontOfSize:12]*/;
    }
    
    if(indexPath.row==0)
    {
        cell.lbl_text.text=@"About";
        cell.imgMenu.image = [UIImage imageWithIcon:@"fa-info-circle" backgroundColor:[UIColor clearColor] iconColor:[UIColor blackColor] fontSize:24];
    }
    else if (indexPath.row==1)
    {
        cell.lbl_text.text=@"Settings";
        cell.imgMenu.image = [UIImage imageWithIcon:@"fa-cog" backgroundColor:[UIColor clearColor] iconColor:[UIColor blackColor] fontSize:24];
    }
    
//    cell.selectionStyle=UITableViewCellSelectionStyleNone;
//    cell.backgroundColor=[UIColor whiteColor];
//    if (indexPath.row==_selectedRow)
//    {
//        cell.backgroundColor=[UIColor colorWithWhite:0.961 alpha:1.000];
//        cell.lbl_text.textColor=[UIColor colorWithRed:0.094 green:0.557 blue:0.996 alpha:1.000];
//        cell.imgMenu.image=[cell.imgMenu.image imageTintedWithColor:[UIColor colorWithRed:0.094 green:0.557 blue:0.996 alpha:1.000]];
//    }
//    else
//    {
//        cell.imgMenu.image=[cell.imgMenu.image imageTintedWithColor:[UIColor blackColor]];
//    }
    
    return cell;
}


#pragma mark - Shortcut
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 150)];
    UIImageView *newView=[[UIImageView alloc]initWithFrame:view.frame];
    //newView.image=[UIImage imageNamed:@"shortback"];
    newView.backgroundColor=[UIColor colorWithWhite:0.259 alpha:1.000];
    [view addSubview:newView];
  __block  UIImageView *ProfileImage=[[UIImageView alloc]initWithFrame:CGRectMake(20, 30, 70, 70)];
    ProfileImage.layer.cornerRadius=ProfileImage.frame.size.height/2;
    ProfileImage.layer.masksToBounds=YES;
    [view addSubview:ProfileImage];
    [ContactsEntity getAsyncImage:self.Cur_contact WithBlock:^(id img, BOOL flag) {
        ProfileImage.image=img;
    }];
    CGRect getrect=[CUtil getTextRect:self.Cur_contact.name Font:[DesignManager knoteLoginButtonFonts] Width:view.frame.size.width-50];
    getrect.origin.x=20;
    getrect.origin.y=ProfileImage.frame.origin.y+ProfileImage.frame.size.height+20;

    UILabel *lbl_Name=[[UILabel alloc]initWithFrame:getrect];
    lbl_Name.font=[DesignManager knoteLoginButtonFonts];
    lbl_Name.textColor=[UIColor whiteColor];
    lbl_Name.text=self.Cur_contact.name;
    lbl_Name.numberOfLines=0;
    [view addSubview:lbl_Name];
    UIImage * BarButnImg = [[UIImage imageNamed:@"entypo_log-out"] imageTintedWithColor:[UIColor whiteColor]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:BarButnImg forState:UIControlStateNormal];



    [button setFrame:CGRectMake(view.frame.size.width-30, ProfileImage.frame.origin.y+ProfileImage.frame.size.height+28, 20, 20)];
    [button addTarget:self action:@selector(openAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    return view;
}
-(void)openAction
{
    UIActionSheet *action=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Logout", nil];
    [action showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
    {
        [DataManager sharedInstance].fetchedContacts = NO;
        [[self targetDelegate]loggingOutExtras];
        [glbAppdel logout];
        
        [glbAppdel.navController popToRootViewControllerAnimated:YES];
    }
}
#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[self targetDelegate]respondsToSelector:@selector(BottomMenuActionIndex:)])
    {
        switch (indexPath.row) {
                
            case 0:
                
                [[self targetDelegate] BottomMenuActionIndex:1];
                
                break;
                
            case 1:
                
                [[self targetDelegate] BottomMenuActionIndex:2];
                
                break;
                
            case 2:
                [[self targetDelegate] BottomMenuActionIndex:3];
                break;
        }
        
    }
}

@end
