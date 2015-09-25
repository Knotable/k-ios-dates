//
//  KnotesViewController.h
//  Example
//
//  Created by wuli on 2/5/15.
//  Copyright (c) 2015 smart4c. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeteorClient.h"
@interface KnotesViewController : UITableViewController
@property (nonatomic, strong) NSDate *knotesDate;
@property (strong, nonatomic) MeteorClient *meteor;
@property (nonatomic, strong) NSString *topic_id;
@end
