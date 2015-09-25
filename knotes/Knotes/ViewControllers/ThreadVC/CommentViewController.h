//
//  CommentViewController.h
//  Knotable
//
//  Created by Troy DeMar on 6/25/15.
//
//

#import <UIKit/UIKit.h>
#import "SLKTextViewController.h"
#import "CItem.h"
#import "CLatestReplyView.h"



//@interface CommentViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@interface CommentViewController : SLKTextViewController

@property (nonatomic, strong) UITableView *tblOfComments;

@property (nonatomic, strong) CItem *itemInfo;
@property (nonatomic, strong) CLatestReplyView *replyView;
@property (nonatomic, strong) NSArray *arrOfComments;


- (id)initWithTopic:(CItem *)item;

@end
