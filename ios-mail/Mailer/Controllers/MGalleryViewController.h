//
//  MGalleryViewController.h
//  Mailer
//
//  Created by Martin Ceperley on 10/28/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCyclingCollectionViewController.h"
#import "MSwipedButtonManager.h"
@interface MGalleryViewController : MCyclingCollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate,MSwipedButtonManagerDelegate>{
    
    NSArray *imageAttachments;
    UIActivityIndicatorView *spinner;
}
@property (nonatomic) BOOL isIndicating;
@end
