//
//  MHomeViewController.h
//  Mailer
//
//  Created by Mac 7 on 21/01/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAccountViewCell.h"
#import "DemoTableController.h"
#import "FPPopoverController.h"
#define kAllAccountIndex 100

@interface MHomeViewController : UIViewController<UIActionSheetDelegate>{
    
    IBOutlet UITableView *listtableView;
    UIActivityIndicatorView *spinner;
    
    int selectedIndex;

}

@property(nonatomic,strong) NSMutableArray *accountListArray;//,*nameListArray;

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue;

@end
