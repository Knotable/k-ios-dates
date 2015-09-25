//
//  MMailListSessionTableViewController.h
//  Mailer
//
//  Created by wuli on 14-6-12.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
@interface MMailListSessionTableViewController : UITableViewController
@property (strong, nonatomic) Message *message;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end
