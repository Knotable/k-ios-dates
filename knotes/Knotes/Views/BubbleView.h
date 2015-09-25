//
//  BubbleView.h
//  Knotable
//
//  Created by Emiliano Barcia on 17/6/15.
//
//

#import <UIKit/UIKit.h>

#define UNREAD      1
#define FILES       2
#define BOOKMARKED  3

@protocol FilterPadsDelegate <NSObject>

-(void)filterWithFilter:(int)filter;

@end

@interface BubbleView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id <FilterPadsDelegate> delegate;

@end
