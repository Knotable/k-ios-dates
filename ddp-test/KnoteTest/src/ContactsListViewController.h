//
//  ContactsListViewController.h
//  Example
//
//  Created by wuli on 2/9/15.
//  Copyright (c) 2015 smart4c. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeteorClient.h"
@interface ContactsListViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (strong, nonatomic) MeteorClient *meteor;
@property (strong, nonatomic) UISearchDisplayController *searchController;
@end
