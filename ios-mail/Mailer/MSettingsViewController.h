//
//  MSettingsViewController.h
//  Mailer
//
//  Created by Mac 7 on 30/01/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountInfo.h"

@class MHomeViewController;

@interface MSettingsViewController : UIViewController<UIActionSheetDelegate>{
    IBOutlet UITableView *userTableVw;
    
}

@property (nonatomic, strong)NSMutableArray *userArray;
@property (nonatomic , strong)MHomeViewController *home;

@end
