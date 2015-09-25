//
//  MKnotesViewController.h
//  Mailer
//
//  Created by Mac 7 on 17/02/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKnotesViewController : UIViewController<UITextViewDelegate>{
    
    IBOutlet UITableView *tablevw;
    IBOutlet UIView *containerView;
    IBOutlet UITextView *txtvw;
    
}


@property(nonatomic , strong) NSMutableArray *tableListArray;
@property(nonatomic , strong) NSMutableArray *accountArray;
@property(nonatomic , strong) NSMutableArray *knoteArray;


@end
