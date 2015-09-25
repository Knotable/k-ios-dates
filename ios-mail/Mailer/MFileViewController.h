//
//  MFileViewController.h
//  Mailer
//
//  Created by Mac 7 on 22/01/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCyclingViewController.h"
#import "MSwipedButtonManager.h"

@interface MFileViewController : MCyclingViewController<NSFetchedResultsControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate>{
    
    NSArray *_allFileAttachments;
    IBOutlet UICollectionView *collctnView;

    
}

@property (nonatomic) BOOL isIndicating;

@end
