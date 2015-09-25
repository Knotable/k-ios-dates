//
//  SideMenuViewController.h
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import <UIKit/UIKit.h>
#import "SideTableViewCell.h"
#import "CombinedViewController.h"
#import "UIImage+Tint.h"
#import "DataManager.h"

@protocol SideMenuDelegate <NSObject>
-(void) BottomMenuActionIndex:(NSInteger)butIndex;
-(void)loggingOutExtras;
@end
@interface SideMenuViewController : UITableViewController<UIActionSheetDelegate>
@property (nonatomic)NSInteger selectedRow;
@property (nonatomic, strong) AccountEntity *Cur_account;
@property (nonatomic,strong)ContactsEntity *Cur_contact;
@property (nonatomic,strong)UserEntity *Cur_user;

@property (readwrite,weak) id<SideMenuDelegate> targetDelegate;
//@property (nonatomic, strong) RNFrostedSidebar *targetresign;

@end