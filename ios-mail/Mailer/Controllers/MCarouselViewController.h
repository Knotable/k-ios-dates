//
//  MCarouselViewController.h
//  Mailer
//
//  Created by Martin Ceperley on 10/16/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@class MMessageListController, iCarousel;

@interface MCarouselViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, UIWebViewDelegate>{
    
    MMessageListController *_master;
    iCarousel *_carousel;
    NSArray *_messages;
    NSFetchedResultsController *_frc;
    NSArray *_backgroundColors;
    NSUInteger _backgroundColorIndex;
}

@property (nonatomic, strong) IBOutlet UILabel *subjectLabel;

-(IBAction)exitGallery:(id)sender;


@end
