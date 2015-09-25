//
//  ThreadSelectionViewController.h
//  Knotable
//
//  Created by Agus Guerra on 6/2/15.
//
//

#import <UIKit/UIKit.h>
#import "TopicInfo.h"

@protocol ThreadSelectionDelegate <NSObject>

- (void)threadWithTopicIdSelected:(TopicsEntity *)topic;

@end

@interface ThreadSelectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSString *tempPadTitle;
@property (nonatomic, strong) TopicsEntity *selectedTopic;

@end
