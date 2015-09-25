//
//  MPeopleViewController.h
//  Mailer
//
//  Created by Mac 7 on 22/01/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCyclingViewController.h"

#import "MSwipedButtonManager.h"
@interface MPeopleViewController : MCyclingViewController<NSFetchedResultsControllerDelegate,MSwipedButtonManagerDelegate>{
    
    IBOutlet UITableView *pplListTableView;
     UIStoryboard *storyboard;
   
}

@property(nonatomic,strong) NSMutableArray *pplListArray;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL isIndicating;

//@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;



@end
