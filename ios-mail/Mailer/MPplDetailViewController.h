//
//  MPplDetailViewController.h
//  Mailer
//
//  Created by Mac 7 on 22/01/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Address;
@interface MPplDetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate>{
    
    IBOutlet UITableView *emailListTableView;
}

@property (nonatomic, retain) Address *info;
@property (nonatomic,retain)NSMutableArray *emailArray;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;



@end
